import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/profet.dart';
import '../../utils/privacy/privacy_levels.dart';
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

  /// Trigger bio generation if conditions are met
  Future<void> _triggerBioGenerationIfNeeded({String? userId}) async {
    try {
      final bioGenerator = BioGenerationService.instance;
      await bioGenerator.initialize();
      await bioGenerator.checkAndRegenerateBio(userId: userId ?? 'default_user');
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
      
      // Create context for AI analysis
      final analysisPrompt = '''
Analyze this user question to a spiritual oracle and identify biographical insights.

Question: "$question"
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
- Maximum 3 insights per analysis
- Skip vague or uncertain insights
- Use simple, clear language

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
        systemMessage: 'You are a biographical insight extraction assistant. Extract only clear, factual insights about users based on their spiritual oracle interactions.',
        maxTokens: 200,
        temperature: 0.3,
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
            
            // Limit to prevent overwhelming the system
            if (insights.length >= 3) break;
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
    for (final insight in insights) {
      try {
        final category = insight['category']!;
        final content = insight['content']!;
        
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
          userId: userId,
        );
        
        AppLogger.logDebug(_component, 'Stored insight - $category: $content');
        
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
}
