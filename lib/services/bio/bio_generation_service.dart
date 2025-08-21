import '../../utils/app_logger.dart';
import '../ai_service_manager.dart';
import '../../models/bio/biographical_insight.dart';
import '../../models/bio/generated_bio.dart';
import '../../utils/privacy/privacy_levels.dart';
import '../../utils/bio/insight_source_type.dart';
import 'bio_storage_service.dart';

/// Service for generating cohesive biographical narratives from insights
class BioGenerationService {
  static const String _component = 'BioGenerationService';
  static const int _minInsightsForBatchGeneration = 10;
  static const int _batchGenerationInterval = 3;
  
  static BioGenerationService? _instance;
  static BioGenerationService get instance => _instance ??= BioGenerationService._();
  
  BioGenerationService._();
  
  BioStorageService? _bioStorageService;
  
  /// Initialize the service with dependencies
  Future<void> initialize() async {
    try {
      _bioStorageService ??= BioStorageService();
      AppLogger.logInfo(_component, 'Bio generation service initialized');
    } catch (e) {
      AppLogger.logError(_component, 'Failed to initialize bio generation service', e);
      rethrow;
    }
  }
  
  /// Check if bio regeneration is needed and trigger if necessary
  Future<void> checkAndRegenerateBio({required String userId}) async {
    try {
      AppLogger.logInfo(_component, 'Checking if bio regeneration is needed for user: $userId');
      
      if (_bioStorageService == null) {
        AppLogger.logWarning(_component, 'Bio storage service not initialized');
        return;
      }
      
      final userBio = await _bioStorageService!.getUserBio(userId: userId);
      if (userBio == null || !userBio.isEnabled) {
        AppLogger.logInfo(_component, 'Bio disabled or not found for user: $userId');
        return;
      }
      
      final insights = await _bioStorageService!.getInsights(userId: userId);
      final totalInsights = insights.length;
      
      // Get current generated bio
      final currentBio = await _bioStorageService!.getGeneratedBio(userId: userId);
      final lastBioInsightsCount = currentBio?.totalInsightsUsed ?? 0;
      
      bool shouldRegenerate = false;
      
      if (totalInsights < _minInsightsForBatchGeneration) {
        // Regenerate after every new insight when we have few insights
        shouldRegenerate = totalInsights > lastBioInsightsCount;
        AppLogger.logInfo(_component, 'Few insights mode: totalInsights=$totalInsights, lastCount=$lastBioInsightsCount, shouldRegenerate=$shouldRegenerate');
      } else {
        // Regenerate every 3 insights when we have enough data
        final newInsightsSinceLastBio = totalInsights - lastBioInsightsCount;
        shouldRegenerate = newInsightsSinceLastBio >= _batchGenerationInterval;
        AppLogger.logInfo(_component, 'Batch mode: newInsights=$newInsightsSinceLastBio, shouldRegenerate=$shouldRegenerate');
      }
      
      if (shouldRegenerate) {
        AppLogger.logInfo(_component, 'Regenerating bio for user: $userId');
        await _generateBio(userId: userId, insights: insights);
      }
      
    } catch (e) {
      AppLogger.logError(_component, 'Error checking bio regeneration for user: $userId', e);
      // Don't rethrow - bio generation should never break main flow
    }
  }

  /// Force generate a bio immediately regardless of conditions
  Future<void> generateBioOnDemand({required String userId}) async {
    try {
      AppLogger.logInfo(_component, 'Generating bio on demand for user: $userId');
      
      if (_bioStorageService == null) {
        AppLogger.logWarning(_component, 'Bio storage service not initialized');
        await initialize();
      }
      
      final userBio = await _bioStorageService!.getUserBio(userId: userId);
      if (userBio == null || !userBio.isEnabled) {
        AppLogger.logInfo(_component, 'Bio disabled or not found for user: $userId');
        return;
      }
      
      final insights = await _bioStorageService!.getInsights(userId: userId);
      if (insights.isEmpty) {
        AppLogger.logInfo(_component, 'No insights available for bio generation for user: $userId - bio will show fallback message');
        return; // Let the UI show "No bio still available. The prophets need more information"
      }

      // Check if existing bio has parsing issues and clear it if needed
      final existingBio = await _bioStorageService!.getGeneratedBio(userId: userId);
      if (existingBio != null) {
        final hasParsingIssues = existingBio.sections.values.any((content) => 
          content.trim() == 'No specific information available');
        
        if (hasParsingIssues) {
          AppLogger.logInfo(_component, 'Detected parsing issues in existing bio, clearing it for regeneration');
          await _bioStorageService!.clearGeneratedBio(userId: userId);
        }
      }
      
      AppLogger.logInfo(_component, 'Forcing bio generation with ${insights.length} insights for user: $userId');
      await _generateBio(userId: userId, insights: insights);
      
    } catch (e) {
      AppLogger.logError(_component, 'Error generating bio on demand for user: $userId', e);
      rethrow; // Rethrow for UI error handling
    }
  }

  /// Regenerate bio with improved parsing (clears old bio first)
  Future<void> regenerateBioWithImprovedParsing({String? userId}) async {
    try {
      userId = userId ?? 'default_user';
      AppLogger.logInfo(_component, 'Regenerating bio with improved parsing for user: $userId');
      
      if (_bioStorageService == null) {
        AppLogger.logWarning(_component, 'Bio storage service not initialized');
        await initialize();
      }
      
      final userBio = await _bioStorageService!.getUserBio(userId: userId);
      if (userBio == null || !userBio.isEnabled) {
        AppLogger.logInfo(_component, 'Bio disabled or not found for user: $userId');
        return;
      }
      
      final insights = await _bioStorageService!.getInsights(userId: userId);
      if (insights.isEmpty) {
        AppLogger.logInfo(_component, 'No insights available for bio regeneration for user: $userId');
        return;
      }

      // Clear existing bio to force fresh generation with new parsing
      AppLogger.logInfo(_component, 'Clearing existing bio to force regeneration');
      await _bioStorageService!.clearGeneratedBio(userId: userId);

      AppLogger.logInfo(_component, 'Regenerating bio with ${insights.length} insights for user: $userId');
      await _generateBio(userId: userId, insights: insights);

    } catch (e) {
      AppLogger.logError(_component, 'Failed to regenerate bio for user: $userId', e);
      rethrow;
    }
  }
  
  /// Generate a new biographical narrative from insights
  Future<void> _generateBio({
    required String userId,
    required List<BiographicalInsight> insights,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Starting bio generation with ${insights.length} total insights');
      
      // Debug: Log all insights with their source types
      for (int i = 0; i < insights.length; i++) {
        final insight = insights[i];
        AppLogger.logInfo(_component, 'Insight $i: sourceType=${insight.sourceType.displayName}, privacyLevel=${insight.privacyLevel.displayName}, content="${insight.content.substring(0, insight.content.length > 50 ? 50 : insight.content.length)}..."');
      }
      
      // Filter only usable insights (public/personal only) - TEMPORARILY REMOVE SOURCE TYPE FILTERING
      final usableInsights = insights
          .where((insight) => insight.privacyLevel.canUseForContext)
          .toList();
      
      AppLogger.logInfo(_component, 'After filtering: ${usableInsights.length} usable insights from ${insights.length} total insights');
      
      if (usableInsights.isEmpty) {
        AppLogger.logInfo(_component, 'No usable insights found for bio generation');
        AppLogger.logWarning(_component, 'Bio generation failed: No insights available with suitable privacy level.');
        return;
      }
      
      AppLogger.logInfo(_component, 'Generating bio from ${usableInsights.length} usable insights');
      
      // Generate bio using AI
      final generatedBio = await _generateBioWithAI(usableInsights);
      
      // Store the generated bio
      await _bioStorageService!.saveGeneratedBio(
        userId: userId,
        generatedBio: generatedBio.copyWith(
          totalInsightsUsed: usableInsights.length,
          generatedAt: DateTime.now(),
        ),
      );
      
      AppLogger.logInfo(_component, 'Successfully generated and saved bio for user: $userId');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to generate bio for user: $userId', e);
      rethrow;
    }
  }
  
  /// Use AI to generate structured biographical narrative
  Future<GeneratedBio> _generateBioWithAI(List<BiographicalInsight> insights) async {
    try {
      // Organize insights by category
      final insightsByCategory = <String, List<String>>{};
      for (final insight in insights) {
        insightsByCategory.putIfAbsent(insight.category, () => []).add(insight.content);
      }
      
      AppLogger.logInfo(_component, 'Insights organized by category: ${insightsByCategory.keys.join(', ')}');
      
      // Create prompt for AI bio generation
      final prompt = _buildBioGenerationPrompt(insightsByCategory);
      
      AppLogger.logInfo(_component, 'Sending bio generation request to AI service');
      AppLogger.logInfo(_component, 'Bio generation prompt length: ${prompt.length} characters');
      
      // Get AI response with increased token limit for detailed sections
      final aiResponse = await AIServiceManager.generateResponse(
        prompt: prompt,
        systemMessage: _getSystemPromptForBioGeneration(),
        maxTokens: 3000, // Increased from 1000 to accommodate detailed sections
      );
      
      if (aiResponse == null || aiResponse.isEmpty) {
        throw Exception('AI service returned empty response for bio generation');
      }
      
      AppLogger.logInfo(_component, 'AI response received: ${aiResponse.length} characters');
      AppLogger.logInfo(_component, 'AI response preview: ${aiResponse.substring(0, aiResponse.length > 200 ? 200 : aiResponse.length)}...');
      
      // Parse AI response into structured sections
      final bioSections = _parseAIResponseToBioSections(aiResponse);
      
      AppLogger.logInfo(_component, 'Parsed bio sections: ${bioSections.keys.join(', ')}');
      for (final entry in bioSections.entries) {
        AppLogger.logInfo(_component, '${entry.key}: ${entry.value.length} characters - "${entry.value.substring(0, entry.value.length > 50 ? 50 : entry.value.length)}"');
      }
      
      final generatedBio = GeneratedBio(
        id: '', // Will be set by storage service
        userId: '', // Will be set by storage service
        sections: bioSections,
        totalInsightsUsed: insights.length,
        confidenceScore: _calculateOverallConfidence(insights),
        generatedAt: DateTime.now(),
        lastUsedAt: null,
      );
      
      AppLogger.logInfo(_component, 'Generated bio created successfully with ${bioSections.length} sections');
      return generatedBio;
      
    } catch (e) {
      AppLogger.logError(_component, 'AI bio generation failed', e);
      rethrow;
    }
  }
  
  /// Build the prompt for AI bio generation
  String _buildBioGenerationPrompt(Map<String, List<String>> insightsByCategory) {
    final buffer = StringBuffer();
    final totalInsights = insightsByCategory.values.expand((list) => list).length;
    
    buffer.writeln('Generate a biographical profile from these insights:');
    buffer.writeln();
    
    for (final entry in insightsByCategory.entries) {
      buffer.writeln('${entry.key.toUpperCase()}:');
      for (final insight in entry.value) {
        buffer.writeln('- $insight');
      }
      buffer.writeln();
    }
    
    buffer.writeln('Create a structured biographical profile with these sections:');
    buffer.writeln('- INTERESTS: Main interests, hobbies, and preferences');
    buffer.writeln('- PERSONALITY: Key personality traits and characteristics');
    buffer.writeln('- BACKGROUND: Educational, professional, or cultural background');
    buffer.writeln('- GOALS: Aspirations, objectives, and motivations');
    buffer.writeln('- PREFERENCES: Communication style, learning preferences, etc.');
    buffer.writeln();
    
    // Adjust instructions based on number of insights
    if (totalInsights <= 3) {
      buffer.writeln('IMPORTANT: You have very few insights ($totalInsights). Be extremely conservative:');
      buffer.writeln('- Only mention what is explicitly evident from the insights');
      buffer.writeln('- Keep each section brief (1-2 sentences maximum)');
      buffer.writeln('- Do not make assumptions or elaborate beyond the evidence');
      buffer.writeln('- If you cannot find relevant information for a section, write "No specific information available"');
      buffer.writeln('- Focus on facts, not speculation');
    } else if (totalInsights <= 10) {
      buffer.writeln('IMPORTANT: You have limited insights ($totalInsights). Be moderately conservative:');
      buffer.writeln('- Base content primarily on the provided insights');
      buffer.writeln('- Keep each section concise (2-4 sentences)');
      buffer.writeln('- Make minimal reasonable inferences');
      buffer.writeln('- If you cannot find relevant information for a section, write "No specific information available"');
    } else {
      buffer.writeln('IMPORTANT: Analyze ALL the insights above and extract information for each section, regardless of how they are categorized.');
      buffer.writeln('For example, if an insight says "User has programming experience" (even if categorized as interests), it should go in BACKGROUND.');
      buffer.writeln('Each section should be comprehensive but stay under 800 words. Write detailed, flowing narratives.');
      buffer.writeln('Be natural and engaging, creating a complete picture of the person in each section.');
      buffer.writeln('If you cannot find relevant information for a section, write "No specific information available".');
    }
    
    return buffer.toString();
  }
  
  /// System prompt for bio generation
  String _getSystemPromptForBioGeneration() {
    return '''You are a biographical profile generator. Your task is to create accurate, evidence-based biographical narratives from user insights.

Core Principles:
1. BE CONSERVATIVE: Only write what is directly supported by the evidence
2. AVOID ASSUMPTIONS: Don't elaborate beyond what the insights actually show
3. SCALE CONTENT TO EVIDENCE: Write brief content when you have few insights
4. BE ACCURATE: Focus on facts, not speculation

Content Guidelines:
- Few insights (1-3): Keep each section to 1-2 sentences maximum
- Limited insights (4-10): Keep each section to 2-4 sentences
- Abundant insights (10+): Write detailed narratives up to 800 words per section

Rules:
1. Use respectful and positive tone
2. Focus on patterns that emerge from multiple insights
3. Write in natural, engaging language appropriate to the amount of evidence
4. Analyze ALL insights and categorize information appropriately, regardless of original category labels
5. If a section has no relevant insights, write "No specific information available"
6. Never invent details or make broad generalizations from minimal evidence

CRITICAL: Look at the CONTENT of each insight, not just its category. For example:
- "User has programming experience" should go in BACKGROUND even if categorized as "interests"
- "User wants to learn Python" should go in GOALS even if categorized elsewhere
- "User prefers morning work" should go in PREFERENCES even if categorized as "personality"

Format your response exactly like this:

INTERESTS: [Evidence-based content about interests, hobbies, and preferences]

PERSONALITY: [Evidence-based description of personality traits and characteristics]

BACKGROUND: [Evidence-based background including education, work, culture]

GOALS: [Evidence-based exploration of aspirations, objectives, and motivations]

PREFERENCES: [Evidence-based account of communication style, learning preferences, etc.]''';
  }
  
  /// Parse AI response into structured bio sections
  Map<String, String> _parseAIResponseToBioSections(String aiResponse) {
    AppLogger.logInfo(_component, 'Parsing AI response. First 200 characters: ${aiResponse.substring(0, aiResponse.length > 200 ? 200 : aiResponse.length)}...');
    
    final sections = <String, String>{};
    final lines = aiResponse.split('\n');
    
    String? currentSection;
    List<String> currentContent = [];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmedLine = line.trim();
      
      if (trimmedLine.isEmpty) continue;
      
      // Check for markdown-style headers: **INTERESTS:**
      final markdownHeaderMatch = RegExp(r'^\*\*(INTERESTS|PERSONALITY|BACKGROUND|GOALS|PREFERENCES):\*\*\s*(.*)$', caseSensitive: false).firstMatch(trimmedLine);
      
      // Check for simple headers: INTERESTS:
      final simpleHeaderMatch = RegExp(r'^(INTERESTS|PERSONALITY|BACKGROUND|GOALS|PREFERENCES):\s*(.*)$', caseSensitive: false).firstMatch(trimmedLine);
      
      if (markdownHeaderMatch != null || simpleHeaderMatch != null) {
        // Save previous section if it exists
        if (currentSection != null && currentContent.isNotEmpty) {
          sections[currentSection] = currentContent.join(' ').trim();
          AppLogger.logInfo(_component, 'Parsed section "$currentSection": ${sections[currentSection]!.substring(0, sections[currentSection]!.length > 100 ? 100 : sections[currentSection]!.length)}...');
        }
        
        // Start new section
        final match = markdownHeaderMatch ?? simpleHeaderMatch!;
        currentSection = match.group(1)!.toLowerCase();
        currentContent = [];
        
        // Add any content on the same line as header
        final headerContent = match.group(2)!.trim();
        if (headerContent.isNotEmpty) {
          currentContent.add(headerContent);
        }
        
        AppLogger.logInfo(_component, 'Found section header: $currentSection');
      } else if (currentSection != null) {
        // Add content to current section
        currentContent.add(trimmedLine);
      }
    }
    
    // Save the last section
    if (currentSection != null && currentContent.isNotEmpty) {
      sections[currentSection] = currentContent.join(' ').trim();
      AppLogger.logInfo(_component, 'Parsed final section "$currentSection": ${sections[currentSection]!.substring(0, sections[currentSection]!.length > 100 ? 100 : sections[currentSection]!.length)}...');
    }
    
    // Ensure all expected sections exist
    final expectedSections = ['interests', 'personality', 'background', 'goals', 'preferences'];
    for (final section in expectedSections) {
      if (!sections.containsKey(section) || sections[section]!.isEmpty) {
        sections[section] = 'No specific information available';
        AppLogger.logInfo(_component, 'Section "$section" missing or empty, using fallback');
      }
    }
    
    AppLogger.logInfo(_component, 'Final parsed sections: ${sections.keys.join(', ')}');
    return sections;
  }
  
  /// Calculate overall confidence score from insights
  double _calculateOverallConfidence(List<BiographicalInsight> insights) {
    if (insights.isEmpty) return 0.0;
    
    final totalConfidence = insights
        .map((insight) => insight.confidenceScore)
        .reduce((a, b) => a + b);
    
    return totalConfidence / insights.length;
  }
  
  /// Generate bio context for prophet responses
  Future<String> generateContextForProphet({
    required String userId,
    String? prophetType,
  }) async {
    try {
      if (_bioStorageService == null) {
        AppLogger.logWarning(_component, 'Bio storage service not initialized');
        return '';
      }
      
      final generatedBio = await _bioStorageService!.getGeneratedBio(userId: userId);
      
      if (generatedBio == null || generatedBio.sections.isEmpty) {
        AppLogger.logInfo(_component, 'No generated bio available for context');
        return '';
      }
      
      // Update last used timestamp
      await _bioStorageService!.updateBioLastUsed(userId: userId);
      
      // Create context from bio sections
      final contextParts = <String>[];
      
      for (final entry in generatedBio.sections.entries) {
        if (entry.value != 'No specific information available') {
          contextParts.add('${entry.key}: ${entry.value}');
        }
      }
      
      if (contextParts.isEmpty) {
        return '';
      }
      
      final context = contextParts.join('\n\n');
      AppLogger.logInfo(_component, 'Generated context for prophet (${context.length} chars)');
      
      return 'User background information:\n\n$context';
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to generate prophet context', e);
      return ''; // Fail gracefully
    }
  }
}
