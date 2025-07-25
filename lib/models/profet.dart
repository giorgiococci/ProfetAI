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

  static bool get isAIEnabled => AIServiceManager.isAIAvailable;

  static Future<void> clearAICredentials() async {
    await AIServiceManager.clearConfiguration();
  }

  // Enhanced methods that use AI when available
  Future<String> getAIPersonalizedResponse(String question) async {
    if (!AIServiceManager.isAIAvailable) {
      AppLogger.logDebug(_component, 'AI not available, using fallback response');
      return getPersonalizedResponse(question);
    }

    try {
      final response = await AIServiceManager.generateResponse(
        prompt: question,
        systemMessage: aiSystemPrompt,
        maxTokens: 200,
        temperature: 0.8,
      );
      
      if (response != null && response.isNotEmpty) {
        AppLogger.logDebug(_component, 'AI response generated successfully');
        return response;
      } else {
        AppLogger.logWarning(_component, 'AI returned empty response, using fallback');
        return getPersonalizedResponse(question);
      }
    } catch (e) {
      AppLogger.logError(_component, 'AI response failed, using fallback', e);
      return getPersonalizedResponse(question);
    }
  }

  Future<String> getAIRandomVision() async {
    if (!AIServiceManager.isAIAvailable) {
      AppLogger.logDebug(_component, 'AI not available for random vision, using fallback');
      return getRandomVision();
    }

    try {
      final response = await AIServiceManager.generateResponse(
        prompt: "Dammi una profezia spontanea senza che io ti faccia una domanda specifica.",
        systemMessage: aiSystemPrompt,
        maxTokens: 150,
        temperature: 0.9, // Higher temperature for more creativity
      );
      
      if (response != null && response.isNotEmpty) {
        AppLogger.logDebug(_component, 'AI random vision generated successfully');
        return response;
      } else {
        AppLogger.logWarning(_component, 'AI returned empty vision, using fallback');
        return getRandomVision();
      }
    } catch (e) {
      AppLogger.logError(_component, 'AI vision failed, using fallback', e);
      return getRandomVision();
    }
  }
  
  // Metodi comuni a tutti i profeti
  String getRandomVision() {
    final visions = getRandomVisions();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % visions.length;
    return visions[randomIndex];
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
