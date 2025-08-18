import '../ai_service_manager.dart';
import '../../utils/app_logger.dart';
import '../../utils/privacy/privacy_levels.dart';

/// AI-powered privacy filter service for analyzing and classifying information
/// 
/// This service uses AI to determine the privacy sensitivity level of information
/// extracted from user interactions with prophets, ensuring sensitive data is not stored
class PrivacyFilterService {
  static const String _component = 'PrivacyFilterService';
  
  // Singleton pattern
  static final PrivacyFilterService _instance = PrivacyFilterService._internal();
  factory PrivacyFilterService() => _instance;
  PrivacyFilterService._internal();

  /// Analyzes text content and determines its privacy sensitivity level
  /// 
  /// Uses AI to classify information based on privacy categories:
  /// - PUBLIC: General interests, hobbies, public opinions
  /// - PERSONAL: Preferences, personality traits, life goals
  /// - SENSITIVE: Should be filtered out - financial status, health issues
  /// - CONFIDENTIAL: Must be filtered out - medical conditions, financial details, phone numbers, precise locations
  Future<PrivacyLevel> analyzePrivacyLevel({
    required String content,
    String? context,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Analyzing privacy level for content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
      
      // Check if AI is available
      if (!AIServiceManager.isAIAvailable) {
        AppLogger.logWarning(_component, 'AI not available, using fallback privacy analysis');
        return _fallbackPrivacyAnalysis(content);
      }

      final analysisPrompt = _buildPrivacyAnalysisPrompt(content, context);
      
      final response = await AIServiceManager.generateResponse(
        prompt: analysisPrompt,
        systemMessage: _getPrivacyAnalysisSystemPrompt(),
        maxTokens: 100,
        temperature: 0.1, // Low temperature for consistent classification
      );

      if (response != null && response.isNotEmpty) {
        final privacyLevel = _parsePrivacyResponse(response);
        AppLogger.logInfo(_component, 'AI privacy analysis result: ${privacyLevel.displayName}');
        return privacyLevel;
      } else {
        AppLogger.logWarning(_component, 'AI returned empty response, using fallback');
        return _fallbackPrivacyAnalysis(content);
      }
      
    } catch (e) {
      AppLogger.logError(_component, 'Error in AI privacy analysis', e);
      return _fallbackPrivacyAnalysis(content);
    }
  }

  /// Filters a list of potential biographical insights based on privacy level
  /// 
  /// Returns only insights that are safe to store (PUBLIC or PERSONAL level)
  Future<List<String>> filterSafeInsights(List<String> insights) async {
    final safeInsights = <String>[];
    
    for (final insight in insights) {
      final privacyLevel = await analyzePrivacyLevel(content: insight);
      if (privacyLevel.canStore) {
        safeInsights.add(insight);
        AppLogger.logInfo(_component, 'Insight approved for storage: ${insight.substring(0, insight.length > 30 ? 30 : insight.length)}...');
      } else {
        AppLogger.logInfo(_component, 'Insight filtered out (${privacyLevel.displayName}): ${insight.substring(0, insight.length > 30 ? 30 : insight.length)}...');
      }
    }
    
    AppLogger.logInfo(_component, 'Filtered ${insights.length} insights down to ${safeInsights.length} safe insights');
    return safeInsights;
  }

  /// Builds the analysis prompt for privacy classification
  String _buildPrivacyAnalysisPrompt(String content, String? context) {
    final contextSection = context != null ? 
      'Context of the conversation: $context\n\n' : '';
    
    return '''${contextSection}Analyze the following text and classify its privacy level:

"$content"

Classification guidelines:
- PUBLIC: General interests, hobbies, public opinions, general personality traits
- PERSONAL: Private preferences, specific personality insights, life goals, relationship status
- SENSITIVE: Financial situations, work problems, family conflicts (FILTER OUT)
- CONFIDENTIAL: Medical conditions, financial details, phone numbers, precise addresses (FILTER OUT)

Respond with only one word: PUBLIC, PERSONAL, SENSITIVE, or CONFIDENTIAL''';
  }

  /// Returns the system prompt for the privacy analysis AI agent
  String _getPrivacyAnalysisSystemPrompt() {
    return '''You are a Privacy Classification Agent for a spiritual guidance app. Your job is to analyze user information and classify it by privacy sensitivity level.

Your role is to PROTECT USER PRIVACY by identifying sensitive information that should NOT be stored.

Classification Rules:
- PUBLIC: General interests (spirituality, philosophy), hobbies, public opinions, general personality traits
- PERSONAL: Private preferences, specific personality insights, life goals, relationship status (general)
- SENSITIVE: Financial situations, work-related problems, family conflicts - MUST BE FILTERED OUT
- CONFIDENTIAL: Medical conditions, health details, financial specifics, phone numbers, precise locations, addresses - MUST BE FILTERED OUT

CRITICAL: When in doubt, classify as SENSITIVE or CONFIDENTIAL to protect user privacy.

Examples:
- "User is interested in meditation" → PUBLIC
- "User values honesty and seeks authentic relationships" → PERSONAL  
- "User is going through a divorce" → SENSITIVE (filter out)
- "User has anxiety disorder" → CONFIDENTIAL (filter out)
- "User lost their job last month" → SENSITIVE (filter out)
- "User lives at 123 Main Street" → CONFIDENTIAL (filter out)
- "User's phone number is..." → CONFIDENTIAL (filter out)

Respond with ONLY the classification: PUBLIC, PERSONAL, SENSITIVE, or CONFIDENTIAL''';
  }

  /// Parses the AI response and returns the corresponding PrivacyLevel
  PrivacyLevel _parsePrivacyResponse(String response) {
    final cleanResponse = response.trim().toUpperCase();
    
    switch (cleanResponse) {
      case 'PUBLIC':
        return PrivacyLevel.public;
      case 'PERSONAL':
        return PrivacyLevel.personal;
      case 'SENSITIVE':
        return PrivacyLevel.sensitive;
      case 'CONFIDENTIAL':
        return PrivacyLevel.confidential;
      default:
        AppLogger.logWarning(_component, 'Unexpected AI response: $response, defaulting to CONFIDENTIAL for safety');
        return PrivacyLevel.confidential; // Default to most restrictive for safety
    }
  }

  /// Fallback privacy analysis when AI is not available
  /// 
  /// Uses keyword-based heuristics to classify privacy levels
  PrivacyLevel _fallbackPrivacyAnalysis(String content) {
    AppLogger.logInfo(_component, 'Using fallback privacy analysis');
    
    final contentLower = content.toLowerCase();
    
    // Check for confidential patterns first (most restrictive)
    final confidentialPatterns = [
      // Medical conditions
      r'\b(cancer|diabetes|depression|anxiety|bipolar|schizophrenia|adhd|autism|ptsd)\b',
      r'\b(surgery|medication|prescription|therapy|treatment|diagnosis|hospital|doctor|clinic)\b',
      r'\b(sick|illness|disease|condition|disorder|syndrome|symptoms)\b',
      // Financial details
      r'\b(\$\d+|\d+\s*dollars?|\d+\s*euros?|salary|income|debt|loan|mortgage|bank|credit)\b',
      r'\b(unemployed|fired|laid\s*off|bankruptcy|broke|poor|rich|wealthy)\b',
      // Contact information
      r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b', // Phone numbers
      r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b', // Email addresses
      // Precise locations
      r'\b\d+\s+[a-zA-Z\s]+\s+(street|st|avenue|ave|road|rd|lane|ln|drive|dr|way|blvd|boulevard)\b',
      r'\b\d{5}(-\d{4})?\b', // ZIP codes
    ];
    
    for (final pattern in confidentialPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(contentLower)) {
        AppLogger.logInfo(_component, 'Fallback analysis detected confidential pattern: $pattern');
        return PrivacyLevel.confidential;
      }
    }
    
    // Check for sensitive patterns
    final sensitivePatterns = [
      r'\b(divorce|separation|breakup|cheating|affair|abuse)\b',
      r'\b(family\s+problems?|family\s+issues?|family\s+conflicts?)\b',
      r'\b(work\s+problems?|job\s+stress|workplace|boss|colleague)\b',
      r'\b(financial\s+problems?|money\s+problems?|financial\s+stress)\b',
      r'\b(legal\s+problems?|court|lawsuit|lawyer|attorney)\b',
    ];
    
    for (final pattern in sensitivePatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(contentLower)) {
        AppLogger.logInfo(_component, 'Fallback analysis detected sensitive pattern: $pattern');
        return PrivacyLevel.sensitive;
      }
    }
    
    // Check for personal patterns
    final personalPatterns = [
      r'\b(love|relationship|partner|dating|single|married)\b',
      r'\b(goals?|dreams?|ambitions?|aspirations?)\b',
      r'\b(personality|character|values?|beliefs?)\b',
      r'\b(private|personal|secret|confidential)\b',
    ];
    
    for (final pattern in personalPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(contentLower)) {
        AppLogger.logInfo(_component, 'Fallback analysis detected personal pattern: $pattern');
        return PrivacyLevel.personal;
      }
    }
    
    // Default to public if no sensitive patterns detected
    AppLogger.logInfo(_component, 'Fallback analysis defaulting to public level');
    return PrivacyLevel.public;
  }

  /// Validates if a text contains any obviously sensitive information
  /// 
  /// This is a quick pre-filter before sending to AI analysis
  bool containsObviouslySensitiveInfo(String content) {
    final contentLower = content.toLowerCase();
    
    // Quick check for obvious sensitive patterns
    final obviousPatterns = [
      r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b', // Phone numbers
      r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b', // Email
      r'\b\d+\s+[a-zA-Z\s]+(street|st|avenue|ave|road|rd)\b', // Addresses
      r'\b\$\d+\b|\b\d+\s*dollars?\b', // Money amounts
      r'\bsocial\s+security\b|\bssn\b', // SSN references
      r'\bcredit\s+card\b|\bdebit\s+card\b', // Card information
    ];
    
    for (final pattern in obviousPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(contentLower)) {
        return true;
      }
    }
    
    return false;
  }
}
