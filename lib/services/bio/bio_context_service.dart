import '../../models/bio/biographical_insight.dart';
import '../../utils/app_logger.dart';
import '../../models/profet.dart';
import 'bio_storage_service.dart';

/// Service for generating personalized context from biographical insights
/// 
/// This service retrieves relevant biographical insights and formats them
/// into context that can enhance prophet responses with personalization
class BioContextService {
  static const String _component = 'BioContextService';
  
  final BioStorageService _bioStorage = BioStorageService();
  
  // Singleton pattern
  static final BioContextService _instance = BioContextService._internal();
  factory BioContextService() => _instance;
  BioContextService._internal();

  /// Generates personalized context for a prophet interaction
  /// 
  /// Returns relevant biographical insights formatted as context that can be
  /// included in the prompt to personalize the prophet's response
  Future<String?> generatePersonalizedContext({
    required Profet profet,
    required String userQuestion,
    String? userId,
    int maxInsights = 3,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Generating personalized context for ${profet.name}');
      
      // Check if bio is enabled for this user
      final userBio = await _bioStorage.initializeUserBio(userId: userId);
      if (!userBio.isEnabled) {
        AppLogger.logInfo(_component, 'Bio collection disabled - no personalization context');
        return null;
      }

      // Get relevant insights for this interaction
      final relevantInsights = await _findRelevantInsights(
        userQuestion: userQuestion,
        profetName: profet.name,
        userId: userId,
        maxInsights: maxInsights,
      );

      if (relevantInsights.isEmpty) {
        AppLogger.logInfo(_component, 'No relevant insights found for personalization');
        return null;
      }

      // Format insights into context
      final personalizedContext = _formatInsightsAsContext(
        insights: relevantInsights,
        profetName: profet.name,
        userQuestion: userQuestion,
      );

      AppLogger.logInfo(_component, 'Generated personalized context with ${relevantInsights.length} insights');
      return personalizedContext;
      
    } catch (e) {
      AppLogger.logError(_component, 'Error generating personalized context', e);
      return null; // Graceful degradation - no personalization if error
    }
  }

  /// Gets a summary of user interests for general personalization
  /// 
  /// Returns a brief summary of the user's main interests and preferences
  /// that can be used for general context in prophet interactions
  Future<String?> getUserInterestsSummary({
    String? userId,
    int maxInterests = 5,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Getting user interests summary');
      
      // Check if bio is enabled
      final userBio = await _bioStorage.initializeUserBio(userId: userId);
      if (!userBio.isEnabled) {
        return null;
      }

      // Get recent insights (using existing method)
      final recentInsights = await _bioStorage.getContextInsights(
        userId: userId,
        limit: maxInterests * 2, // Get more and filter client-side
      );

      if (recentInsights.isEmpty) {
        return null;
      }

      // Filter for interest-related insights
      final interestInsights = recentInsights.where((insight) {
        final content = insight.content.toLowerCase();
        return content.contains('interest') || 
               content.contains('enjoy') || 
               content.contains('passion') ||
               content.contains('hobby') ||
               content.contains('like');
      }).take(maxInterests).toList();

      if (interestInsights.isEmpty) {
        return null;
      }

      // Format as a summary
      final interests = interestInsights.map((insight) => insight.content).join(', ');
      return 'This person seems naturally drawn to: $interests. Let this subtly influence your spiritual guidance without explicitly mentioning these interests.';
      
    } catch (e) {
      AppLogger.logError(_component, 'Error getting user interests summary', e);
      return null;
    }
  }

  /// Finds biographical insights relevant to the current interaction
  /// 
  /// Uses keyword matching and recency scoring to identify the most
  /// relevant insights for personalizing the response
  Future<List<BiographicalInsight>> _findRelevantInsights({
    required String userQuestion,
    required String profetName,
    String? userId,
    required int maxInsights,
  }) async {
    try {
      // Get all available insights using existing method
      final allInsights = await _bioStorage.getContextInsights(
        userId: userId,
        limit: 50, // Get more insights to choose from
      );
      
      if (allInsights.isEmpty) {
        return [];
      }

      // Score insights by relevance
      final scoredInsights = <_ScoredInsight>[];
      
      for (final insight in allInsights) {
        final relevanceScore = _calculateRelevanceScore(
          insight: insight,
          userQuestion: userQuestion,
          profetName: profetName,
        );
        
        if (relevanceScore > 0.0) {
          scoredInsights.add(_ScoredInsight(insight, relevanceScore));
        }
      }

      // Sort by relevance score (highest first) and take top results
      scoredInsights.sort((a, b) => b.score.compareTo(a.score));
      
      return scoredInsights
          .take(maxInsights)
          .map((scored) => scored.insight)
          .toList();
          
    } catch (e) {
      AppLogger.logError(_component, 'Error finding relevant insights', e);
      return [];
    }
  }

  /// Calculates relevance score for an insight based on the current interaction
  /// 
  /// Factors considered:
  /// - Keyword overlap between insight and question
  /// - Prophet-specific relevance
  /// - Insight freshness (more recent = higher score)
  /// - Usage count (less used = higher priority)
  double _calculateRelevanceScore({
    required BiographicalInsight insight,
    required String userQuestion,
    required String profetName,
  }) {
    double score = 0.0;
    
    final questionLower = userQuestion.toLowerCase();
    final insightLower = insight.content.toLowerCase();
    
    // Keyword overlap scoring
    final questionWords = questionLower.split(RegExp(r'\s+'));
    final insightWords = insightLower.split(RegExp(r'\s+'));
    
    int matchCount = 0;
    for (final word in questionWords) {
      if (word.length > 3 && insightWords.any((w) => w.contains(word))) {
        matchCount++;
      }
    }
    
    // Base score from keyword matches
    score += (matchCount / questionWords.length) * 10.0;
    
    // Prophet-specific relevance boost
    if (insight.extractedFrom.toLowerCase().contains(profetName.toLowerCase())) {
      score += 2.0;
    }
    
    // Category-based scoring (inferred from content)
    final content = insightLower;
    if (content.contains('interest') || content.contains('enjoy') || content.contains('passion')) {
      score += 3.0; // Interests
    } else if (content.contains('personality') || content.contains('trait') || content.contains('character')) {
      score += 2.5; // Personality
    } else if (content.contains('prefer') || content.contains('like') || content.contains('dislike')) {
      score += 2.0; // Preferences
    } else if (content.contains('value') || content.contains('believe') || content.contains('important')) {
      score += 2.5; // Values
    } else if (content.contains('goal') || content.contains('aspire') || content.contains('hope')) {
      score += 2.0; // Goals
    }
    
    // Freshness scoring (more recent insights get higher scores)
    final daysSinceCreated = DateTime.now().difference(insight.extractedAt).inDays;
    final freshnessScore = 1.0 / (1.0 + daysSinceCreated * 0.1);
    score += freshnessScore;
    
    // Usage count boost (less used insights get priority)
    score += 1.0 / (1.0 + insight.usageCount * 0.5);
    
    return score;
  }

  /// Formats biographical insights into context text for prophet prompts
  /// 
  /// Creates subtle context that influences the AI's response style and content
  /// without making the personalization obvious to the user
  String _formatInsightsAsContext({
    required List<BiographicalInsight> insights,
    required String profetName,
    required String userQuestion,
  }) {
    if (insights.isEmpty) {
      return '';
    }

    final contextParts = <String>[];
    
    // Group insights by inferred category for better organization
    final insightsByCategory = <String, List<BiographicalInsight>>{};
    for (final insight in insights) {
      final category = _inferCategory(insight.content);
      insightsByCategory.putIfAbsent(category, () => []).add(insight);
    }

    // Format each category as subtle guidance (not explicit user knowledge)
    for (final entry in insightsByCategory.entries) {
      final category = entry.key;
      final categoryInsights = entry.value;
      
      final insightTexts = categoryInsights.map((i) => i.content).join('; ');
      
      switch (category) {
        case 'interests':
          contextParts.add('This person seems drawn to: $insightTexts. Tailor your response to resonate with these interests.');
          break;
        case 'personality':
          contextParts.add('This individual appears to have these traits: $insightTexts. Adjust your communication style accordingly.');
          break;
        case 'preferences':
          contextParts.add('This person tends to prefer: $insightTexts. Shape your guidance to match these preferences.');
          break;
        case 'values':
          contextParts.add('This individual seems to value: $insightTexts. Frame your wisdom in alignment with these values.');
          break;
        case 'goals':
          contextParts.add('This person appears focused on: $insightTexts. Connect your guidance to these aspirations.');
          break;
        default:
          contextParts.add('Context about this individual: $insightTexts. Use this to make your response more relevant.');
      }
    }

    final contextText = contextParts.join('\n');
    
    return '''
RESPONSE GUIDANCE (Internal - Do NOT mention this context to the user):
$contextText

Provide your response as $profetName in a way that naturally aligns with this context, but NEVER explicitly mention that you know these details about the user. Make the response feel personally relevant without revealing your awareness.''';
  }

  /// Infers category from insight content using keyword analysis
  String _inferCategory(String content) {
    final contentLower = content.toLowerCase();
    
    if (contentLower.contains('interest') || contentLower.contains('enjoy') || contentLower.contains('passion') || contentLower.contains('hobby')) {
      return 'interests';
    } else if (contentLower.contains('personality') || contentLower.contains('trait') || contentLower.contains('character')) {
      return 'personality';
    } else if (contentLower.contains('prefer') || contentLower.contains('like') || contentLower.contains('dislike')) {
      return 'preferences';
    } else if (contentLower.contains('value') || contentLower.contains('believe') || contentLower.contains('important')) {
      return 'values';
    } else if (contentLower.contains('goal') || contentLower.contains('aspire') || contentLower.contains('hope')) {
      return 'goals';
    } else {
      return 'general';
    }
  }

  /// Gets user engagement patterns for tailoring response style
  /// 
  /// Analyzes how the user typically engages with prophets to suggest
  /// appropriate response length and style
  Future<Map<String, dynamic>?> getUserEngagementPatterns({
    String? userId,
  }) async {
    try {
      final insights = await _bioStorage.getContextInsights(userId: userId, limit: 20);
      
      if (insights.length < 3) {
        return null; // Need more data for patterns
      }

      // Analyze patterns from insights
      int detailPreferenceCount = 0;
      int philosophicalInterestCount = 0;
      int practicalQuestionCount = 0;
      
      for (final insight in insights) {
        final content = insight.content.toLowerCase();
        
        if (content.contains('detailed') || content.contains('thorough') || content.contains('explanation')) {
          detailPreferenceCount++;
        }
        
        if (content.contains('philosophy') || content.contains('meaning') || content.contains('purpose')) {
          philosophicalInterestCount++;
        }
        
        if (content.contains('practical') || content.contains('how to') || content.contains('steps')) {
          practicalQuestionCount++;
        }
      }

      return {
        'prefersDetailedAnswers': detailPreferenceCount > insights.length * 0.3,
        'philosophicallyInclined': philosophicalInterestCount > insights.length * 0.2,
        'prefersPracticalAdvice': practicalQuestionCount > insights.length * 0.2,
        'totalInsights': insights.length,
      };
      
    } catch (e) {
      AppLogger.logError(_component, 'Error analyzing engagement patterns', e);
      return null;
    }
  }
}

/// Helper class for scoring insights by relevance
class _ScoredInsight {
  final BiographicalInsight insight;
  final double score;
  
  _ScoredInsight(this.insight, this.score);
}
