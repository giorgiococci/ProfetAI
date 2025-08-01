import 'package:flutter/material.dart';
import 'profet.dart';
import '../l10n/prophet_localization_loader.dart';
import '../services/ai_service_manager.dart';
import '../utils/app_logger.dart';

class OracoloCaotico extends Profet {
  const OracoloCaotico() : super(
    name: 'Oracolo Caotico',
    description: 'Il Caos ti chiama... forse',
    location: 'DIMENSIONE DEL CAOS',
    primaryColor: const Color(0xFFFF6B35), // Arancione vivace
    secondaryColor: const Color(0xFFE91E63), // Rosa shocking
    backgroundGradient: const [
      Color(0xFF2E1A47), // Viola scuro
      Color(0xFF3E2723), // Marrone scuro
      Color(0xFF1B0D2E), // Viola quasi nero
    ],
    icon: Icons.shuffle,
    backgroundImagePath: 'assets/images/backgrounds/chaotic_profet_background.png', // Immagine di sfondo
    profetImagePath: 'assets/images/prophets/chaotic_prophet.png', // Immagine dell'oracolo caotico
  );

  @override
  String get type => 'chaotic_prophet';

  @override
  String get aiSystemPrompt => '';  // Now uses localized version

  @override
  String get aiLoadingMessage => '';  // Now uses localized version

  // Localized AI system prompt method
  @override
  Future<String> getLocalizedAISystemPrompt(BuildContext context) async {
    return await ProphetLocalizationLoader.getAISystemPrompt(context, 'chaotic_prophet');
  }

  // Localized random visions method
  @override
  Future<List<String>> getLocalizedRandomVisions(BuildContext context) async {
    return await ProphetLocalizationLoader.getRandomVisions(context, 'chaotic_prophet');
  }

  // Localized fallback response method
  @override
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'chaotic_prophet');
  }

  // Generate AI-powered vision title with chaotic style
  @override
  Future<String> generateVisionTitle(BuildContext context, {
    String? question,
    required String answer,
  }) async {
    try {
      AppLogger.logInfo('OracoloCaotico', 'Generating chaotic vision title');
      
      if (!AIServiceManager.isAIAvailable) {
        AppLogger.logWarning('OracoloCaotico', 'AI service not available, using fallback title');
        return _generateFallbackTitle(question, answer);
      }

      // Create a chaotic, unpredictable prompt for title generation
      final titlePrompt = '''
You are the Chaotic Oracle, unpredictable and wild. Create a chaotic, surprising title for a vision.

Context:
${question != null ? 'Question: $question\n' : ''}Vision Answer: $answer

Requirements:
- Maximum 30 characters
- Chaotic and unpredictable tone
- Use wild words like: Chaos, Storm, Wild, Mad, Twisted, Bizarre, Whirl, Frenzy, Mayhem, Rebel
- Mix unexpected concepts
- Be provocative and surprising
- Embrace randomness and contradiction

Examples of good titles:
- "Mad Storm of Truth"
- "Chaos Whispers Wisdom" 
- "Wild Twisted Vision"
- "Rebel Fortune Speaks"
- "Bizarre Truth Storm"

Generate only the title, nothing else:''';

      final titleResponse = await AIServiceManager.generateResponse(
        prompt: titlePrompt,
        maxTokens: 50,
        temperature: 1.0, // Maximum creativity for chaos
      );
      
      if (titleResponse == null || titleResponse.isEmpty) {
        AppLogger.logWarning('OracoloCaotico', 'AI returned empty response, using fallback');
        return _generateFallbackTitle(question, answer);
      }
      
      final cleanedTitle = _cleanAndValidateTitle(titleResponse);
      
      AppLogger.logInfo('OracoloCaotico', 'Generated chaotic title: $cleanedTitle');
      return cleanedTitle;
      
    } catch (e) {
      AppLogger.logError('OracoloCaotico', 'Failed to generate AI title', e);
      return _generateFallbackTitle(question, answer);
    }
  }

  /// Generate a fallback title when AI is not available
  String _generateFallbackTitle(String? question, String answer) {
    if (question != null && question.isNotEmpty) {
      // Extract key words from question for chaotic title
      final questionWords = question.toLowerCase().split(' ');
      
      for (final word in questionWords) {
        if (word.length > 3) {
          return 'Mad ${word.substring(0, 1).toUpperCase()}${word.substring(1)} Chaos';
        }
      }
    }
    
    // Default chaotic titles
    final fallbackTitles = [
      'Wild Chaos Storm',
      'Mad Truth Spiral',
      'Twisted Fortune',
      'Rebel Wisdom',
      'Bizarre Vision',
      'Mayhem Speaks',
      'Frenzy Unleashed',
      'Storm of Madness'
    ];
    
    return fallbackTitles[DateTime.now().millisecond % fallbackTitles.length];
  }

  /// Clean and validate the AI-generated title
  String _cleanAndValidateTitle(String title) {
    // Remove quotes, extra spaces, and newlines
    String cleaned = title.trim();
    
    // Remove leading and trailing quotes
    if (cleaned.startsWith('"') || cleaned.startsWith("'")) {
      cleaned = cleaned.substring(1);
    }
    if (cleaned.endsWith('"') || cleaned.endsWith("'")) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    
    // Replace multiple spaces with single space
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Ensure it's not too long
    if (cleaned.length > 30) {
      cleaned = '${cleaned.substring(0, 27)}...';
    }
    
    // Ensure it's not empty
    if (cleaned.isEmpty) {
      return 'Wild Chaos';
    }
    
    return cleaned;
  }
}
