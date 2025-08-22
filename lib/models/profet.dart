import 'package:flutter/material.dart';
import '../services/ai_service_manager.dart';
import '../utils/app_logger.dart';
import '../l10n/prophet_localization_loader.dart';
import 'vision_feedback.dart';

// Classe base astratta per tutti gli oracoli/profeti
abstract class Profet {
  static const String _component = 'Profet';
  
  final String name;
  final String description;
  final String location;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> backgroundGradient;
  final IconData icon;
  final String? backgroundImagePath; // Percorso opzionale per immagine di sfondo
  final String? profetImagePath; // Percorso opzionale per immagine dell'oracolo

  const Profet({
    required this.name,
    required this.description,
    required this.location,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundGradient,
    required this.icon,
    this.backgroundImagePath, // Parametro opzionale
    this.profetImagePath, // Parametro opzionale per immagine dell'oracolo
  });

  // Get prophet type string for localization purposes
  String get type;
  
  // Abstract localized methods - these are the ones that should be implemented
  Future<List<String>> getLocalizedRandomVisions(BuildContext context);
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question);
  Future<String> getLocalizedAISystemPrompt(BuildContext context);
  
  // Abstract method for generating AI-powered vision titles
  Future<String> generateVisionTitle(BuildContext context, {
    String? question,
    required String answer,
  });
  
  // Abstract method for AI system prompt - each profet defines its personality (will be deprecated)
  String get aiSystemPrompt;
  
  // Abstract method for personalized loading message
  String get aiLoadingMessage;
  
  // Localized feedback methods using ProphetLocalizationLoader
  Future<String> getPositiveFeedbackText(BuildContext context) async =>
      await ProphetLocalizationLoader.getFeedbackText(context, type, 'positive');
  
  Future<String> getNegativeFeedbackText(BuildContext context) async =>
      await ProphetLocalizationLoader.getFeedbackText(context, type, 'negative');
  
  Future<String> getFunnyFeedbackText(BuildContext context) async =>
      await ProphetLocalizationLoader.getFeedbackText(context, type, 'funny');
  
  // Method to create feedback with prophet-specific localized text
  Future<VisionFeedback> createFeedback(
    BuildContext context, {
    required FeedbackType type,
    String? visionContent,
    String? question,
  }) async {
    switch (type) {
      case FeedbackType.positive:
        return VisionFeedback.positive(
          visionContent: visionContent,
          question: question,
          customText: await getPositiveFeedbackText(context),
        );
      case FeedbackType.negative:
        return VisionFeedback.negative(
          visionContent: visionContent,
          question: question,
          customText: await getNegativeFeedbackText(context),
        );
      case FeedbackType.funny:
        return VisionFeedback.funny(
          visionContent: visionContent,
          question: question,
          customText: await getFunnyFeedbackText(context),
        );
    }
  }
  
  // Static AI service methods - simplified
  static Future<void> initializeAI({
    required String endpoint,
    required String apiKey,
    required String deploymentName,
  }) async {
    // This is now handled by AIServiceManager
    AppLogger.logInfo(_component, 'AI initialization requested (handled by AIServiceManager)');
  }

  static Future<bool> loadStoredAICredentials() async {
    // This is now handled by AIServiceManager
    return AIServiceManager.initialize();
  }

  static bool get isAIEnabled {
    final isAvailable = AIServiceManager.isAIAvailable;
    AppLogger.logInfo(_component, 'Profet.isAIEnabled called - result: $isAvailable');
    AppLogger.logInfo(_component, 'AI Status Details: ${AIServiceManager.getDetailedStatus()}');
    return isAvailable;
  }

  static Future<void> clearAICredentials() async {
    await AIServiceManager.clearConfiguration();
  }

  // Enhanced methods that use AI when available
  Future<String> getAIPersonalizedResponse(String question, BuildContext context) async {
    AppLogger.logInfo(_component, '=== getAIPersonalizedResponse called ===');
    AppLogger.logInfo(_component, 'Question: $question');
    AppLogger.logInfo(_component, 'Prophet: $name');
    
    // Check AI availability
    final isAIAvailable = AIServiceManager.isAIAvailable;
    AppLogger.logInfo(_component, 'AIServiceManager.isAIAvailable: $isAIAvailable');
    
    if (!isAIAvailable) {
      AppLogger.logWarning(_component, 'AI not available, using localized fallback response');
      AppLogger.logInfo(_component, 'AI Status Details: ${AIServiceManager.getDetailedStatus()}');
      // Note: This fallback won't work in base class as it needs BuildContext
      // The UI should handle this case by catching and using localized methods
      throw Exception('AI not available - UI should handle with localized fallback');
    }

    try {
      AppLogger.logInfo(_component, 'Attempting to generate AI response...');
      final localizedPrompt = await getLocalizedAISystemPrompt(context);
      AppLogger.logInfo(_component, 'Localized system prompt: $localizedPrompt');
      AppLogger.logInfo(_component, 'Using parameters: maxTokens=200, temperature=0.8');
      
      final response = await AIServiceManager.generateResponse(
        prompt: question,
        systemMessage: localizedPrompt,
        maxTokens: 200,
        temperature: 0.8,
      );
      
      AppLogger.logInfo(_component, 'AI response received: ${response != null ? "YES" : "NULL"}');
      if (response != null) {
        AppLogger.logInfo(_component, 'AI response length: ${response.length}');
        AppLogger.logInfo(_component, 'AI response content: $response');
      }
      
      if (response != null && response.isNotEmpty) {
        AppLogger.logInfo(_component, '✅ AI response generated successfully');
        return response;
      } else {
        AppLogger.logWarning(_component, '⚠️ AI returned empty response, throwing for UI fallback');
        throw Exception('AI returned empty response - UI should handle with localized fallback');
      }
    } catch (e) {
      AppLogger.logError(_component, '❌ AI response failed, throwing for UI fallback', e);
      throw e; // Re-throw so UI can handle with localized methods
    }
  }

  /// Enhanced AI response generation with personalized biographical context
  /// 
  /// This method accepts additional personalized context that can be used
  /// to tailor the prophet's response based on user's biographical insights
  Future<String> getAIPersonalizedResponseWithContext(
    String question, 
    BuildContext context, 
    {String? personalizedContext}
  ) async {
    AppLogger.logInfo(_component, '=== getAIPersonalizedResponseWithContext called ===');
    AppLogger.logInfo(_component, 'Question: $question');
    AppLogger.logInfo(_component, 'Prophet: $name');
    AppLogger.logInfo(_component, 'Has personalized context: ${personalizedContext != null}');
    
    // Check AI availability
    final isAIAvailable = AIServiceManager.isAIAvailable;
    AppLogger.logInfo(_component, 'AIServiceManager.isAIAvailable: $isAIAvailable');
    
    if (!isAIAvailable) {
      AppLogger.logWarning(_component, 'AI not available, using fallback response');
      AppLogger.logInfo(_component, 'AI Status Details: ${AIServiceManager.getDetailedStatus()}');
      throw Exception('AI not available - UI should handle with localized fallback');
    }

    try {
      AppLogger.logInfo(_component, 'Attempting to generate AI response with personalization...');
      
      // Get the base system prompt
      final baseSystemPrompt = await getLocalizedAISystemPrompt(context);
      
      // Enhanced system prompt with personalized context
      String enhancedSystemPrompt = baseSystemPrompt;
      if (personalizedContext != null && personalizedContext.isNotEmpty) {
        enhancedSystemPrompt += '\n\n$personalizedContext';
        AppLogger.logInfo(_component, 'Enhanced system prompt with personalized context');
      }
      
      AppLogger.logInfo(_component, 'Using enhanced system prompt: $enhancedSystemPrompt');
      AppLogger.logInfo(_component, 'Using parameters: maxTokens=200, temperature=0.8');
      
      final response = await AIServiceManager.generateResponse(
        prompt: question,
        systemMessage: enhancedSystemPrompt,
        maxTokens: 200,
        temperature: 0.8,
      );
      
      AppLogger.logInfo(_component, 'AI response received: ${response != null ? "YES" : "NULL"}');
      if (response != null) {
        AppLogger.logInfo(_component, 'AI response length: ${response.length}');
        AppLogger.logInfo(_component, 'AI response content: $response');
      }
      
      if (response != null && response.isNotEmpty) {
        AppLogger.logInfo(_component, '✅ AI response with personalization generated successfully');
        return response;
      } else {
        AppLogger.logWarning(_component, '⚠️ AI returned empty response, throwing for UI fallback');
        throw Exception('AI returned empty response - UI should handle with localized fallback');
      }
    } catch (e) {
      AppLogger.logError(_component, '❌ AI response with personalization failed, throwing for UI fallback', e);
      throw e; // Re-throw so UI can handle with localized methods
    }
  }

  /// Enhanced random vision generation with personalized biographical context
  /// 
  /// This method generates a random vision that can be tailored based on
  /// the user's interests and preferences from their biographical profile
  Future<String> getAIRandomVisionWithContext(
    BuildContext context, 
    {String? personalizedContext}
  ) async {
    AppLogger.logInfo(_component, '=== getAIRandomVisionWithContext called ===');
    AppLogger.logInfo(_component, 'Prophet: $name');
    AppLogger.logInfo(_component, 'Has personalized context: ${personalizedContext != null}');
    
    // Check AI availability
    final isAIAvailable = AIServiceManager.isAIAvailable;
    AppLogger.logInfo(_component, 'AIServiceManager.isAIAvailable: $isAIAvailable');
    
    if (!isAIAvailable) {
      AppLogger.logWarning(_component, 'AI not available for random vision, throwing for UI fallback');
      AppLogger.logInfo(_component, 'AI Status Details: ${AIServiceManager.getDetailedStatus()}');
      throw Exception('AI not available - UI should handle with localized fallback');
    }

    try {
      AppLogger.logInfo(_component, 'Attempting to generate AI random vision with personalization...');
      
      // Get the base system prompt
      final baseSystemPrompt = await getLocalizedAISystemPrompt(context);
      
      // Enhanced system prompt with personalized context
      String enhancedSystemPrompt = baseSystemPrompt;
      if (personalizedContext != null && personalizedContext.isNotEmpty) {
        enhancedSystemPrompt += '\n\n$personalizedContext';
        enhancedSystemPrompt += '\n\nPlease generate a vision that aligns with the user\'s interests and background.';
        AppLogger.logInfo(_component, 'Enhanced system prompt with personalized context for random vision');
      }
      
      // Create a prompt for random vision that considers user context
      String visionPrompt = 'Please provide me with spiritual guidance and wisdom.';
      if (personalizedContext != null && personalizedContext.isNotEmpty) {
        visionPrompt = 'Based on my background and interests, please share spiritual wisdom that would be meaningful to me.';
      }
      
      AppLogger.logInfo(_component, 'Using enhanced system prompt: $enhancedSystemPrompt');
      AppLogger.logInfo(_component, 'Using vision prompt: $visionPrompt');
      AppLogger.logInfo(_component, 'Using parameters: maxTokens=250, temperature=0.9');
      
      final response = await AIServiceManager.generateResponse(
        prompt: visionPrompt,
        systemMessage: enhancedSystemPrompt,
        maxTokens: 250,
        temperature: 0.9, // Higher temperature for more creative random visions
      );
      
      AppLogger.logInfo(_component, 'AI random vision response received: ${response != null ? "YES" : "NULL"}');
      if (response != null) {
        AppLogger.logInfo(_component, 'AI random vision response length: ${response.length}');
        AppLogger.logInfo(_component, 'AI random vision response content: $response');
      }
      
      if (response != null && response.isNotEmpty) {
        AppLogger.logInfo(_component, '✅ AI random vision with personalization generated successfully');
        return response;
      } else {
        AppLogger.logWarning(_component, '⚠️ AI returned empty random vision, throwing for UI fallback');
        throw Exception('AI returned empty random vision - UI should handle with localized fallback');
      }
    } catch (e) {
      AppLogger.logError(_component, '❌ AI random vision with personalization failed, throwing for UI fallback', e);
      throw e; // Re-throw so UI can handle with localized methods
    }
  }

  Future<String> getAIRandomVision(BuildContext context) async {
    AppLogger.logInfo(_component, '=== getAIRandomVision called ===');
    AppLogger.logInfo(_component, 'Prophet: $name');
    
    // Check AI availability
    final isAIAvailable = AIServiceManager.isAIAvailable;
    AppLogger.logInfo(_component, 'AIServiceManager.isAIAvailable: $isAIAvailable');
    
    if (!isAIAvailable) {
      AppLogger.logWarning(_component, 'AI not available for random vision, throwing for UI fallback');
      AppLogger.logInfo(_component, 'AI Status Details: ${AIServiceManager.getDetailedStatus()}');
      throw Exception('AI not available - UI should handle with localized fallback');
    }

    try {
      AppLogger.logInfo(_component, 'Attempting to generate AI random vision...');
      final localizedPrompt = await getLocalizedAISystemPrompt(context);
      AppLogger.logInfo(_component, 'Localized system prompt: $localizedPrompt');
      AppLogger.logInfo(_component, 'Using parameters: maxTokens=150, temperature=0.9');
      
      final response = await AIServiceManager.generateResponse(
        prompt: "Dammi una profezia spontanea senza che io ti faccia una domanda specifica.",
        systemMessage: localizedPrompt,
        maxTokens: 150,
        temperature: 0.9, // Higher temperature for more creativity
      );
      
      AppLogger.logInfo(_component, 'AI vision received: ${response != null ? "YES" : "NULL"}');
      if (response != null) {
        AppLogger.logInfo(_component, 'AI vision length: ${response.length}');
        AppLogger.logInfo(_component, 'AI vision content: $response');
      }
      
      if (response != null && response.isNotEmpty) {
        AppLogger.logInfo(_component, '✅ AI random vision generated successfully');
        return response;
      } else {
        AppLogger.logWarning(_component, '⚠️ AI returned empty vision, throwing for UI fallback');
        throw Exception('AI returned empty vision - UI should handle with localized fallback');
      }
    } catch (e) {
      AppLogger.logError(_component, '❌ AI vision failed, throwing for UI fallback', e);
      throw e; // Re-throw so UI can handle with localized methods
    }
  }

  /// Generates a brief random oracle response (1-2 sentences max)
  /// This method is specifically designed for the "Listen to Oracle" feature
  Future<String> getAIBriefRandomVision(BuildContext context, {String? personalizedContext}) async {
    AppLogger.logInfo(_component, '=== getAIBriefRandomVision called ===');
    AppLogger.logInfo(_component, 'Prophet: $name');
    AppLogger.logInfo(_component, 'Has personalized context: ${personalizedContext != null}');
    
    // Check AI availability
    final isAIAvailable = AIServiceManager.isAIAvailable;
    AppLogger.logInfo(_component, 'AIServiceManager.isAIAvailable: $isAIAvailable');
    
    if (!isAIAvailable) {
      AppLogger.logWarning(_component, 'AI not available for brief random vision, throwing for UI fallback');
      AppLogger.logInfo(_component, 'AI Status Details: ${AIServiceManager.getDetailedStatus()}');
      throw Exception('AI not available - UI should handle with localized fallback');
    }

    try {
      AppLogger.logInfo(_component, 'Attempting to generate AI brief random vision...');
      
      // Get the base system prompt
      final baseSystemPrompt = await getLocalizedAISystemPrompt(context);
      
      // Enhanced system prompt with personalized context and brevity instruction
      String enhancedSystemPrompt = baseSystemPrompt;
      enhancedSystemPrompt += '\n\nIMPORTANT: Your response must be VERY BRIEF - maximum 1-2 sentences. Be concise and direct while maintaining your unique personality.';
      
      if (personalizedContext != null && personalizedContext.isNotEmpty) {
        enhancedSystemPrompt += '\n\n$personalizedContext';
        enhancedSystemPrompt += '\n\nPlease generate a brief vision that aligns with the user\'s interests and background.';
        AppLogger.logInfo(_component, 'Enhanced system prompt with personalized context for brief random vision');
      }
      
      // Create a prompt for brief random vision
      String visionPrompt = 'Give me a brief spiritual insight or oracle message.';
      if (personalizedContext != null && personalizedContext.isNotEmpty) {
        visionPrompt = 'Based on my background, give me a brief spiritual insight that would be meaningful to me.';
      }
      
      AppLogger.logInfo(_component, 'Using enhanced system prompt with brevity instruction');
      AppLogger.logInfo(_component, 'Using brief vision prompt: $visionPrompt');
      
      final response = await AIServiceManager.generateResponse(
        prompt: visionPrompt,
        systemMessage: enhancedSystemPrompt,
        temperature: 0.7,
      );
      
      AppLogger.logInfo(_component, 'AI brief random vision response received: ${response != null ? "YES" : "NULL"}');
      if (response != null) {
        AppLogger.logInfo(_component, 'AI brief random vision response length: ${response.length}');
        AppLogger.logInfo(_component, 'AI brief random vision response content: $response');
      }
      
      if (response != null && response.isNotEmpty) {
        AppLogger.logInfo(_component, '✅ AI brief random vision generated successfully');
        return response;
      } else {
        AppLogger.logWarning(_component, '⚠️ AI returned empty brief random vision, throwing for UI fallback');
        throw Exception('AI returned empty brief random vision - UI should handle with localized fallback');
      }
    } catch (e) {
      AppLogger.logError(_component, '❌ AI brief random vision failed, throwing for UI fallback', e);
      throw e; // Re-throw so UI can handle with localized methods
    }
  }
}
