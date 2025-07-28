import 'package:flutter/material.dart';
import 'profet.dart';
import '../l10n/prophet_localization_loader.dart';
import '../services/ai_service_manager.dart';
import '../utils/app_logger.dart';

class OracoloMistico extends Profet {
  const OracoloMistico() : super(
    name: 'Oracolo Mistico',
    description: 'L\'Oracolo Mistico ti aspetta',
    location: 'TEMPIO DELLE VISIONI',
    primaryColor: const Color(0xFFD4AF37), // Oro
    secondaryColor: const Color(0xFF8B4513), // Bronzo
    backgroundGradient: const [
      Color(0xFF1A1A2E), // Blu scuro mistico
      Color(0xFF16213E), // Blu ancora più scuro
      Color(0xFF0F0F23), // Quasi nero con hint blu
    ],
    icon: Icons.visibility,
    backgroundImagePath: 'assets/images/backgrounds/mystic_profet_background.png', // Percorso immagine
    profetImagePath: 'assets/images/prophets/mystic_prophet.png', // Opzionale
  );

  @override
  String get type => 'mystic_prophet';

  @override
  String get aiSystemPrompt => '';  // Now uses localized version

  @override
  String get aiLoadingMessage => '';  // Now uses localized version

  // Localized AI system prompt method
  @override
  Future<String> getLocalizedAISystemPrompt(BuildContext context) async {
    return await ProphetLocalizationLoader.getAISystemPrompt(context, 'mystic_prophet');
  }

  // Localized random visions method
  @override
  Future<List<String>> getLocalizedRandomVisions(BuildContext context) async {
    return await ProphetLocalizationLoader.getRandomVisions(context, 'mystic_prophet');
  }

  // Localized fallback response method
  @override
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'mystic_prophet');
  }

  // Generate AI-powered vision title with mystic style
  @override
  Future<String> generateVisionTitle(BuildContext context, {
    String? question,
    required String answer,
  }) async {
    try {
      AppLogger.logInfo('OracoloMistico', 'Generating vision title');
      
      if (!AIServiceManager.isAIAvailable) {
        AppLogger.logWarning('OracoloMistico', 'AI service not available, using fallback title');
        return _generateFallbackTitle(question, answer);
      }

      // Create a mystical, spiritual prompt for title generation
      final titlePrompt = '''
You are the Mystic Oracle, a wise and spiritual guide. Create a mystical, enlightening title for a vision.

Context:
${question != null ? 'Question: $question\n' : ''}Vision Answer: $answer

Requirements:
- Maximum 30 characters
- Mystical and spiritual tone
- Use evocative words like: Revelation, Sacred, Divine, Enlightenment, Wisdom, Light, Spirit, Truth
- Avoid mundane or modern terms
- Focus on the spiritual essence of the vision

Examples of good titles:
- "Sacred Light Revealed"
- "Divine Truth Awakens"
- "Mystic Revelation"
- "Spirit's Guidance"
- "Enlightened Path"

Generate only the title, nothing else:''';

      final titleResponse = await AIServiceManager.generateResponse(
        prompt: titlePrompt,
        maxTokens: 50,
        temperature: 0.8,
      );
      
      if (titleResponse == null || titleResponse.isEmpty) {
        AppLogger.logWarning('OracoloMistico', 'AI returned empty response, using fallback');
        return _generateFallbackTitle(question, answer);
      }
      
      final cleanedTitle = _cleanAndValidateTitle(titleResponse);
      
      AppLogger.logInfo('OracoloMistico', 'Generated title: $cleanedTitle');
      return cleanedTitle;
      
    } catch (e) {
      AppLogger.logError('OracoloMistico', 'Failed to generate AI title', e);
      return _generateFallbackTitle(question, answer);
    }
  }

  /// Generate a fallback title when AI is not available
  String _generateFallbackTitle(String? question, String answer) {
    if (question != null && question.isNotEmpty) {
      // Extract key words from question for mystical title
      final questionWords = question.toLowerCase().split(' ');
      
      for (final word in questionWords) {
        if (word.length > 4) {
          return 'Sacred ${word.substring(0, 1).toUpperCase()}${word.substring(1)} Vision';
        }
      }
    }
    
    // Default mystical titles
    final fallbackTitles = [
      'Divine Revelation',
      'Sacred Vision',
      'Mystic Insight',
      'Spiritual Truth',
      'Enlightened Wisdom',
      'Sacred Light',
      'Divine Guidance',
      'Mystic Teaching'
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
      return 'Divine Vision';
    }
    
    return cleaned;
  }
}
