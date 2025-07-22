import 'package:flutter/material.dart';
import '../services/azure_openai_service.dart';

// Classe base astratta per tutti gli oracoli/profeti
abstract class Profet {
  final String name;
  final String description;
  final String location;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> backgroundGradient;
  final IconData icon;
  final String? backgroundImagePath; // Percorso opzionale per immagine di sfondo

  // Static AI service shared by all profets
  static final AzureOpenAIService _aiService = AzureOpenAIService();

  const Profet({
    required this.name,
    required this.description,
    required this.location,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundGradient,
    required this.icon,
    this.backgroundImagePath, // Parametro opzionale
  });

  // Metodi astratti che devono essere implementati dalle classi figlie
  List<String> getRandomVisions();
  String getPersonalizedResponse(String question);
  
  // Abstract method for AI system prompt - each profet defines its personality
  String get aiSystemPrompt;
  
  // Static AI service methods
  static Future<void> initializeAI({
    required String endpoint,
    required String apiKey,
    required String deploymentName,
  }) async {
    await _aiService.initialize(
      endpoint: endpoint,
      apiKey: apiKey,
      deploymentName: deploymentName,
    );
  }

  static Future<bool> loadStoredAICredentials() async {
    return await _aiService.loadStoredCredentials();
  }

  static bool get isAIEnabled => _aiService.isInitialized;

  static Future<void> clearAICredentials() async {
    await _aiService.clearCredentials();
  }

  // Enhanced methods that use AI when available
  Future<String> getAIPersonalizedResponse(String question) async {
    if (!_aiService.isInitialized) {
      // Fallback to original response
      return getPersonalizedResponse(question);
    }

    try {
      final response = await _aiService.generateResponse(
        prompt: question,
        systemMessage: aiSystemPrompt,
        maxTokens: 200,
        temperature: 0.8,
      );
      return response;
    } catch (e) {
      print('AI response failed, using fallback: $e');
      return getPersonalizedResponse(question);
    }
  }

  Future<String> getAIRandomVision() async {
    if (!_aiService.isInitialized) {
      // Fallback to original random vision
      return getRandomVision();
    }

    try {
      final response = await _aiService.generateResponse(
        prompt: "Dammi una profezia spontanea senza che io ti faccia una domanda specifica.",
        systemMessage: aiSystemPrompt,
        maxTokens: 150,
        temperature: 0.9, // Higher temperature for more creativity
      );
      return response;
    } catch (e) {
      print('AI random vision failed, using fallback: $e');
      return getRandomVision();
    }
  }

  Stream<String> getAIStreamingResponse(String question) async* {
    if (!_aiService.isInitialized) {
      yield getPersonalizedResponse(question);
      return;
    }

    try {
      yield* _aiService.generateStreamingResponse(
        prompt: question,
        systemMessage: aiSystemPrompt,
        maxTokens: 200,
        temperature: 0.8,
      );
    } catch (e) {
      print('AI streaming failed: $e');
      yield getPersonalizedResponse(question);
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
