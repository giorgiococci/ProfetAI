import 'package:flutter/material.dart';
import '../services/ai_service_manager.dart';
import '../utils/app_logger.dart';
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

  // Metodi astratti che devono essere implementati dalle classi figlie
  List<String> getRandomVisions();
  String getPersonalizedResponse(String question);
  
  // Abstract method for AI system prompt - each profet defines its personality
  String get aiSystemPrompt;
  
  // Abstract method for personalized loading message
  String get aiLoadingMessage;
  
  // Abstract methods for feedback customization - can be overridden by subclasses
  String getPositiveFeedbackText() => 'La visione ha illuminato il mio cammino';
  String getNegativeFeedbackText() => 'La visione era offuscata';
  String getFunnyFeedbackText() => 'Non ho capito, ma mi ha fatto ridere';
  
  // Method to create feedback with prophet-specific text
  VisionFeedback createFeedback({
    required FeedbackType type,
    String? visionContent,
    String? question,
  }) {
    switch (type) {
      case FeedbackType.positive:
        return VisionFeedback.positive(
          visionContent: visionContent,
          question: question,
          customText: getPositiveFeedbackText(),
        );
      case FeedbackType.negative:
        return VisionFeedback.negative(
          visionContent: visionContent,
          question: question,
          customText: getNegativeFeedbackText(),
        );
      case FeedbackType.funny:
        return VisionFeedback.funny(
          visionContent: visionContent,
          question: question,
          customText: getFunnyFeedbackText(),
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
  Future<String> getAIPersonalizedResponse(String question) async {
    AppLogger.logInfo(_component, '=== getAIPersonalizedResponse called ===');
    AppLogger.logInfo(_component, 'Question: $question');
    AppLogger.logInfo(_component, 'Prophet: $name');
    
    // Check AI availability
    final isAIAvailable = AIServiceManager.isAIAvailable;
    AppLogger.logInfo(_component, 'AIServiceManager.isAIAvailable: $isAIAvailable');
    
    if (!isAIAvailable) {
      AppLogger.logWarning(_component, 'AI not available, using fallback response');
      AppLogger.logInfo(_component, 'AI Status Details: ${AIServiceManager.getDetailedStatus()}');
      final fallbackResponse = getPersonalizedResponse(question);
      AppLogger.logInfo(_component, 'Fallback response: $fallbackResponse');
      return fallbackResponse;
    }

    try {
      AppLogger.logInfo(_component, 'Attempting to generate AI response...');
      AppLogger.logInfo(_component, 'System prompt: $aiSystemPrompt');
      AppLogger.logInfo(_component, 'Using parameters: maxTokens=200, temperature=0.8');
      
      final response = await AIServiceManager.generateResponse(
        prompt: question,
        systemMessage: aiSystemPrompt,
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
        AppLogger.logWarning(_component, '⚠️ AI returned empty response, using fallback');
        final fallbackResponse = getPersonalizedResponse(question);
        AppLogger.logInfo(_component, 'Fallback response: $fallbackResponse');
        return fallbackResponse;
      }
    } catch (e) {
      AppLogger.logError(_component, '❌ AI response failed, using fallback', e);
      final fallbackResponse = getPersonalizedResponse(question);
      AppLogger.logInfo(_component, 'Fallback response: $fallbackResponse');
      return fallbackResponse;
    }
  }

  Future<String> getAIRandomVision() async {
    AppLogger.logInfo(_component, '=== getAIRandomVision called ===');
    AppLogger.logInfo(_component, 'Prophet: $name');
    
    // Check AI availability
    final isAIAvailable = AIServiceManager.isAIAvailable;
    AppLogger.logInfo(_component, 'AIServiceManager.isAIAvailable: $isAIAvailable');
    
    if (!isAIAvailable) {
      AppLogger.logWarning(_component, 'AI not available for random vision, using fallback');
      AppLogger.logInfo(_component, 'AI Status Details: ${AIServiceManager.getDetailedStatus()}');
      final fallbackVision = getRandomVision();
      AppLogger.logInfo(_component, 'Fallback vision: $fallbackVision');
      return fallbackVision;
    }

    try {
      AppLogger.logInfo(_component, 'Attempting to generate AI random vision...');
      AppLogger.logInfo(_component, 'System prompt: $aiSystemPrompt');
      AppLogger.logInfo(_component, 'Using parameters: maxTokens=150, temperature=0.9');
      
      final response = await AIServiceManager.generateResponse(
        prompt: "Dammi una profezia spontanea senza che io ti faccia una domanda specifica.",
        systemMessage: aiSystemPrompt,
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
        AppLogger.logWarning(_component, '⚠️ AI returned empty vision, using fallback');
        final fallbackVision = getRandomVision();
        AppLogger.logInfo(_component, 'Fallback vision: $fallbackVision');
        return fallbackVision;
      }
    } catch (e) {
      AppLogger.logError(_component, '❌ AI vision failed, using fallback', e);
      final fallbackVision = getRandomVision();
      AppLogger.logInfo(_component, 'Fallback vision: $fallbackVision');
      return fallbackVision;
    }
  }
  
  // Metodi comuni a tutti i profeti
  String getRandomVision() {
    AppLogger.logInfo(_component, '=== getRandomVision (fallback) called ===');
    AppLogger.logInfo(_component, 'Prophet: $name');
    final visions = getRandomVisions();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % visions.length;
    final selectedVision = visions[randomIndex];
    AppLogger.logInfo(_component, 'Selected fallback vision: $selectedVision');
    return selectedVision;
  }

  String getHintText() => 'Poni la tua domanda all\'$name...';
  
  String getVisionTitle(bool hasQuestion) {
    return hasQuestion 
        ? 'La Visione dell\'$name'
        : 'Visione Spontanea dell\'$name';
  }

  String getVisionContent(bool hasQuestion, String? question) {
    if (hasQuestion && question != null) {
      return 'La tua domanda: "$question"\n\n'
          'L\'$name risponde:\n\n'
          '"${getPersonalizedResponse(question)}"';
    } else {
      return 'L\'$name ha una visione per te:\n\n"${getRandomVision()}"';
    }
  }
}
