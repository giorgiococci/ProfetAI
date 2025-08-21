import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/profet.dart';
import '../../utils/privacy/privacy_levels.dart';
import '../../utils/bio/insight_source_type.dart';
import '../../services/ai_service_manager.dart';
import 'bio_storage_service.dart';
import 'bio_generation_service.dart';
import 'privacy_filter_service.dart';
import '../../utils/app_logger.dart';

/// AI-powered biographical analysis agent that processes prophet interactions
/// 
/// This service analyzes user questions and prophet responses to extract
/// and store biographical insights while respecting privacy controls
class BioAnalysisAgent {
  static const String _component = 'BioAnalysisAgent';
  
  final BioStorageService _bioStorage = BioStorageService();
  final PrivacyFilterService _privacyFilter = PrivacyFilterService();
  
  // Singleton pattern
  static final BioAnalysisAgent _instance = BioAnalysisAgent._internal();
  factory BioAnalysisAgent() => _instance;
  BioAnalysisAgent._internal();

  /// Analyze a Q&A interaction and extract biographical insights
  /// This is the main entry point called after prophet interactions
  Future<void> analyzeInteraction({
    required BuildContext context,
    required Profet profet,
    required String response,
    String? question,
    String? userId,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Starting bio analysis for ${profet.name}');
      
      // Check if user bio is enabled before processing
      final userBio = await _bioStorage.initializeUserBio(userId: userId);
      if (!userBio.isEnabled) {
        AppLogger.logInfo(_component, 'Bio collection disabled for user - skipping analysis');
        return;
      }
      
      // Analyze the question for insights
      if (question != null && question.trim().isNotEmpty) {
        await _analyzeQuestion(
          question: question,
          response: response,
          prophetType: profet.type,
          userId: userId,
        );
      }
      
      // Analyze the response for insights about user interests
      await _analyzeResponse(
        response: response,
        question: question,
        prophetType: profet.type,
        userId: userId,
      );
      
      AppLogger.logInfo(_component, 'Bio analysis completed successfully');
      
      // Trigger bio generation if needed
      await _triggerBioGenerationIfNeeded(userId: userId);
      
    } catch (e) {
      // Bio analysis errors should never break the user experience
      AppLogger.logError(_component, 'Bio analysis failed - continuing gracefully: $e');
    }
  }

  /// Trigger bio generation after each prophet interaction
  Future<void> _triggerBioGenerationIfNeeded({String? userId}) async {
    try {
      final bioGenerator = BioGenerationService.instance;
      await bioGenerator.initialize();
      
      // AUTOMATIC GENERATION: Always generate bio after prophet responses
      // This ensures users get updated bio profiles immediately
      AppLogger.logInfo(_component, 'Triggering automatic bio generation after prophet interaction');
      await bioGenerator.generateBioOnDemand(userId: userId ?? 'default_user');
    } catch (e) {
      AppLogger.logError(_component, 'Bio generation trigger failed: $e');
      // Don't rethrow - bio generation is not critical
    }
  }

  /// Analyze user question to extract biographical insights
  Future<void> _analyzeQuestion({
    required String question,
    required String response,
    required String prophetType,
    String? userId,
  }) async {
    try {
      AppLogger.logDebug(_component, 'Analyzing question for insights');
      
      // Check if question is very brief and adjust analysis accordingly
      final wordCount = question.trim().split(RegExp(r'\s+')).length;
      final isBrief = wordCount <= 5; // Consider questions with 5 words or less as brief
      
      AppLogger.logInfo(_component, 'Question word count: $wordCount, considered brief: $isBrief');
      
      // Create context for AI analysis
      final analysisPrompt = '''
Analyze this user question to a spiritual oracle and identify biographical insights.

Question: "$question" (Word count: $wordCount)
Oracle Response: "$response"

Extract ONLY clear, factual insights about the user. Respond with insights in this format:
CATEGORY: INSIGHT

Available categories: interests, concerns, relationships, goals, personality, lifestyle, values, challenges

Example responses:
interests: User is interested in career advancement
concerns: User is worried about financial stability
goals: User wants to improve their relationships
personality: User tends to overthink decisions

Rules:
- Only extract insights that are clearly evident from the question
- Keep insights factual and neutral
${isBrief ? '- BRIEF QUESTION DETECTED: Extract maximum 1 insight and be extra conservative' : '- Maximum 2 insights per analysis (reduced to avoid over-interpretation)'}
- Skip vague or uncertain insights
- Use simple, clear language
${isBrief ? '- For brief questions like "I like tennis", only extract the obvious interest, do not infer personality traits' : '- Be conservative: if the question is very brief (under 10 words), extract maximum 1 insight'}
- Do not infer complex personality traits from simple statements

If no clear insights can be extracted, respond with: NO_INSIGHTS
''';

      final insights = await _extractInsightsFromText(analysisPrompt);
      
      if (insights.isNotEmpty) {
        AppLogger.logInfo(_component, 'Extracted ${insights.length} insights from question');
        await _storeInsights(insights, userId, question, response);
      }
      
    } catch (e) {
      AppLogger.logWarning(_component, 'Question analysis failed: $e');
    }
  }

  /// Analyze prophet response to infer user interests and patterns
  Future<void> _analyzeResponse({
    required String response,
    String? question,
    required String prophetType,
    String? userId,
  }) async {
    try {
      AppLogger.logDebug(_component, 'Analyzing response for user patterns');
      
      // Create context for AI analysis focusing on what the oracle response reveals about user interests
      final analysisPrompt = '''
Analyze what this spiritual oracle response reveals about the user who received it.

${question != null ? 'Original Question: "$question"' : 'Random Vision Request'}
Oracle Response: "$response"
Oracle Type: $prophetType

Infer what this exchange reveals about the user's interests, spiritual orientation, or seeking patterns.

Extract insights in this format:
CATEGORY: INSIGHT

Available categories: interests, spiritual_orientation, seeking_patterns, life_focus, oracle_preference

Example responses:
interests: User seeks guidance on personal relationships
spiritual_orientation: User is drawn to mystical and cosmic themes
seeking_patterns: User frequently asks about future outcomes
life_focus: User is focused on career and professional growth
oracle_preference: User prefers the $prophetType oracle's approach

Rules:
- Focus on what the oracle choice and response topic reveal about the user
- Keep insights observational and neutral
- Maximum 2 insights per analysis
- Skip obvious or generic insights
- Use simple, clear language

If no meaningful insights can be inferred, respond with: NO_INSIGHTS
''';

      final insights = await _extractInsightsFromText(analysisPrompt);
      
      if (insights.isNotEmpty) {
        AppLogger.logInfo(_component, 'Extracted ${insights.length} insights from response analysis');
        await _storeInsights(insights, userId, question ?? 'Random vision', response);
      }
      
    } catch (e) {
      AppLogger.logWarning(_component, 'Response analysis failed: $e');
    }
  }

  /// Extract insights from AI analysis text
  Future<List<Map<String, String>>> _extractInsightsFromText(String analysisPrompt) async {
    try {
      // Use the AI service directly for analysis
      final aiResponse = await AIServiceManager.generateResponse(
        prompt: analysisPrompt,
        systemMessage: 'You are a biographical insight extraction assistant. Extract only clear, factual insights about users based on their spiritual oracle interactions. Be conservative and avoid over-interpretation of brief or simple statements.',
        maxTokens: 200,
        temperature: 0.1, // Reduced temperature for more conservative analysis
      );
      
      if (aiResponse == null || aiResponse.trim() == 'NO_INSIGHTS') {
        AppLogger.logDebug(_component, 'No insights extracted from analysis');
        return [];
      }
      
      // Parse the AI response to extract category:insight pairs
      final insights = <Map<String, String>>[];
      final lines = aiResponse.split('\n');
      
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        
        final colonIndex = trimmed.indexOf(':');
        if (colonIndex > 0 && colonIndex < trimmed.length - 1) {
          final category = trimmed.substring(0, colonIndex).trim().toLowerCase();
          final content = trimmed.substring(colonIndex + 1).trim();
          
          if (content.isNotEmpty && _isValidCategory(category)) {
            insights.add({
              'category': category,
              'content': content,
            });
            
            // Limit to prevent overwhelming the system with speculative insights
            if (insights.length >= 2) break; // Reduced from 3 to 2
          }
        }
      }
      
      AppLogger.logDebug(_component, 'Parsed ${insights.length} valid insights from AI response');
      return insights;
      
    } catch (e) {
      AppLogger.logWarning(_component, 'Failed to extract insights from AI analysis: $e');
      return [];
    }
  }

  /// Store extracted insights with privacy filtering
  Future<void> _storeInsights(
    List<Map<String, String>> insights,
    String? userId,
    String sourceQuestion,
    String sourceAnswer,
  ) async {
    AppLogger.logInfo(_component, 'Processing ${insights.length} extracted insights for storage');
    
    for (final insight in insights) {
      try {
        final category = insight['category']!;
        final content = insight['content']!;
        
        AppLogger.logInfo(_component, 'Processing insight - Category: $category, Content preview: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}');
        
        // First, analyze privacy level
        final privacyLevel = await _privacyFilter.analyzePrivacyLevel(content: content);
        
        // Only store if privacy level allows it
        if (!privacyLevel.canStore) {
          AppLogger.logInfo(_component, 'Skipping insight due to privacy level: ${privacyLevel.displayName}');
          continue;
        }
        
        // Store the insight using the correct API
        await _bioStorage.addInsight(
          content: content,
          category: category,
          sourceQuestionId: sourceQuestion,
          sourceAnswer: sourceAnswer,
          extractedFrom: 'bio_analysis_agent',
          privacyLevel: privacyLevel,
          sourceType: InsightSourceType.prophet, // This analyzes prophet responses
          userId: userId,
        );
        
        AppLogger.logInfo(_component, 'Successfully stored insight - Category: $category, Privacy: ${privacyLevel.displayName}');
        
      } catch (e) {
        // Individual insight failures shouldn't stop the process
        AppLogger.logWarning(_component, 'Failed to store insight: ${insight['content']} - $e');
      }
    }
  }

  /// Validate if a category is allowed for biographical insights
  bool _isValidCategory(String category) {
    const validCategories = {
      'interests',
      'concerns', 
      'relationships',
      'goals',
      'personality',
      'lifestyle',
      'values',
      'challenges',
      'spiritual_orientation',
      'seeking_patterns',
      'life_focus',
      'oracle_preference',
    };
    
    return validCategories.contains(category.toLowerCase());
  }

  /// Generate personalized context for prophet responses
  /// This method enriches prophet prompts with relevant biographical context
  Future<String> generatePersonalizedContext({
    required String basePrompt,
    String? userId,
    int maxInsights = 5,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Generating personalized context for prophet');
      
      // Get user bio with insights
      final userBio = await _bioStorage.initializeUserBio(userId: userId);
      
      if (!userBio.isEnabled || userBio.insights.isEmpty) {
        AppLogger.logDebug(_component, 'No biographical context available');
        return basePrompt;
      }
      
      // Get recent insights that can be used for context
      final contextInsights = userBio.insights
          .where((insight) => insight.privacyLevel.canUseForContext)
          .take(maxInsights)
          .map((insight) => insight.content)
          .join('\n');
      
      if (contextInsights.isEmpty) {
        return basePrompt;
      }
      
      // Integrate context into the prophet prompt naturally
      final personalizedPrompt = '''
$basePrompt

Background context about this user (use naturally, don't reference explicitly):
$contextInsights

Respond naturally incorporating this understanding without mentioning you have background information.''';

      AppLogger.logInfo(_component, 'Enhanced prompt with biographical context');
      return personalizedPrompt;
      
    } catch (e) {
      AppLogger.logWarning(_component, 'Failed to generate personalized context: $e');
      return basePrompt; // Fallback to original prompt
    }
  }

  /// Check if bio analysis is enabled for a user
  Future<bool> isBioEnabled({String? userId}) async {
    try {
      final userBio = await _bioStorage.initializeUserBio(userId: userId);
      return userBio.isEnabled;
    } catch (e) {
      AppLogger.logWarning(_component, 'Failed to check bio status: $e');
      return false; // Fail safe - disable bio if check fails
    }
  }

  /// Get bio statistics for monitoring
  Future<Map<String, dynamic>> getBioStatistics({String? userId}) async {
    try {
      final userBio = await _bioStorage.initializeUserBio(userId: userId);
      return {
        'total_insights': userBio.insights.length,
        'enabled': userBio.isEnabled,
        'categories': _getCategoryStats(userBio.insights),
        'privacy_levels': _getPrivacyStats(userBio.insights),
      };
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get bio statistics: $e');
      return {};
    }
  }
  
  /// Get category distribution statistics
  Map<String, int> _getCategoryStats(List<dynamic> insights) {
    final stats = <String, int>{};
    for (final insight in insights) {
      if (insight.extractedFrom != null) {
        stats[insight.extractedFrom] = (stats[insight.extractedFrom] ?? 0) + 1;
      }
    }
    return stats;
  }
  
  /// Get privacy level distribution statistics
  Map<String, int> _getPrivacyStats(List<dynamic> insights) {
    final stats = <String, int>{};
    for (final insight in insights) {
      if (insight.privacyLevel != null) {
        final levelName = insight.privacyLevel.displayName;
        stats[levelName] = (stats[levelName] ?? 0) + 1;
      }
    }
    return stats;
  }

  /// Analyze a user message for conversation bio insights
  /// This method is specifically for conversation message analysis
  Future<void> analyzeUserMessage({
    required BuildContext context,
    required String userMessage,
    required String prophetResponse,
    required Profet profet,
    String? userId,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Analyzing user message for conversation bio insights');
      
      // Use the existing analyzeInteraction method but focus on user message analysis
      await analyzeInteraction(
        context: context,
        profet: profet,
        response: prophetResponse,
        question: userMessage,
        userId: userId,
      );
      
    } catch (e) {
      AppLogger.logWarning(_component, 'User message analysis failed: $e');
    }
  }

  /// Analyze conversation patterns for recurring themes
  /// This method analyzes multiple messages to find conversation patterns
  Future<void> analyzeConversationPatterns({
    required BuildContext context,
    required List<String> userMessages,
    required Profet profet,
    String? userId,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Analyzing conversation patterns');
      
      if (userMessages.length < 3) {
        AppLogger.logDebug(_component, 'Not enough messages for pattern analysis');
        return;
      }
      
      // Create a synthetic analysis of conversation themes
      final conversationThemes = userMessages.join(' | ');
      const syntheticResponse = 'Pattern analysis of user conversation themes and interests';
      
      // Use the existing analyzeInteraction method with synthesized data
      await analyzeInteraction(
        context: context,
        profet: profet,
        response: syntheticResponse,
        question: 'Conversation themes analysis: $conversationThemes',
        userId: userId,
      );
      
    } catch (e) {
      AppLogger.logWarning(_component, 'Conversation pattern analysis failed: $e');
    }
  }

  /// Analyze message exchange specifically for bio insights
  /// This is a higher-level method that combines user and prophet analysis
  Future<void> analyzeMessageExchange({
    required BuildContext context,
    required String userMessage,
    required String prophetResponse,
    required Profet profet,
    String? userId,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Analyzing complete message exchange');
      
      // Analyze the full interaction
      await analyzeInteraction(
        context: context,
        profet: profet,
        response: prophetResponse,
        question: userMessage,
        userId: userId,
      );
      
    } catch (e) {
      AppLogger.logWarning(_component, 'Message exchange analysis failed: $e');
    }
  }

  /// Analyze a direct prophet response without user input for bio insights
  /// This is useful for "Listen to Oracle" features where the prophet speaks without a user question
  Future<void> analyzeDirectProphetResponse({
    required String response,
    required Profet profet,
    String? userId,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Analyzing direct prophet response for bio insights');
      
      // Analyze the response for insights about user interests/engagement
      // Even without a user question, we can infer engagement patterns
      await _analyzeResponse(
        response: response,
        question: null, // No user question for direct prophet messages
        prophetType: profet.type,
        userId: userId,
      );
      
      AppLogger.logInfo(_component, 'Direct prophet response analysis completed');
      
      // Trigger bio generation if needed
      await _triggerBioGenerationIfNeeded(userId: userId);
      
    } catch (e) {
      AppLogger.logWarning(_component, 'Direct prophet response analysis failed: $e');
    }
  }
}
