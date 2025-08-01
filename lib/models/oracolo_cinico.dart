import 'package:flutter/material.dart';
import 'profet.dart';
import '../l10n/prophet_localization_loader.dart';
import '../services/ai_service_manager.dart';
import '../utils/app_logger.dart';

class OracoloCinico extends Profet {
  const OracoloCinico() : super(
    name: 'Oracolo Cinico',
    description: 'La realtà è deludente, come sempre',
    location: 'TORRE DELLA DISILLUSIONE',
    primaryColor: const Color(0xFF78909C), // Grigio blu
    secondaryColor: const Color(0xFF455A64), // Grigio scuro
    backgroundGradient: const [
      Color(0xFF263238), // Grigio scurissimo
      Color(0xFF37474F), // Grigio medio
      Color(0xFF1C1C1C), // Quasi nero
    ],
    icon: Icons.sentiment_dissatisfied,
    backgroundImagePath: 'assets/images/backgrounds/cynical_profet_background.png',
    profetImagePath: 'assets/images/prophets/cynical_prophet.png'
  );

  @override
  String get type => 'cynical_prophet';

  @override
  String get aiSystemPrompt => '';  // Now uses localized version

  @override
  String get aiLoadingMessage => '';  // Now uses localized version

  // Localized AI system prompt method
  @override
  Future<String> getLocalizedAISystemPrompt(BuildContext context) async {
    return await ProphetLocalizationLoader.getAISystemPrompt(context, 'cynical_prophet');
  }

  // Localized random visions method
  @override
  Future<List<String>> getLocalizedRandomVisions(BuildContext context) async {
    return await ProphetLocalizationLoader.getRandomVisions(context, 'cynical_prophet');
  }

  // Localized fallback response method
  @override
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'cynical_prophet');
  }

  // Generate AI-powered vision title with cynical style
  @override
  Future<String> generateVisionTitle(BuildContext context, {
    String? question,
    required String answer,
  }) async {
    try {
      AppLogger.logInfo('OracoloCinico', 'Generating cynical vision title');
      
      if (!AIServiceManager.isAIAvailable) {
        AppLogger.logWarning('OracoloCinico', 'AI service not available, using fallback title');
        return _generateFallbackTitle(question, answer);
      }

      // Create a cynical, sarcastic prompt for title generation
      final titlePrompt = '''
You are the Cynical Oracle, sarcastic and disillusioned. Create a cynical, realistic title for a vision.

Context:
${question != null ? 'Question: $question\n' : ''}Vision Answer: $answer

Requirements:
- Maximum 30 characters
- Cynical and sarcastic tone
- Use pessimistic words like: Reality, Harsh, Truth, Blunt, Bitter, Cold, Raw, Brutal, Dark, Ironic
- Be realistic and sometimes brutally honest
- Show disillusionment with false hopes
- Embrace skepticism

Examples of good titles:
- "Harsh Reality Check"
- "Bitter Truth Served"
- "Cold Hard Facts"
- "Brutal Honesty Time"
- "Reality Bites Back"

Generate only the title, nothing else:''';

      final titleResponse = await AIServiceManager.generateResponse(
        prompt: titlePrompt,
        maxTokens: 50,
        temperature: 0.6, // Moderate creativity, more focused
      );
      
      if (titleResponse == null || titleResponse.isEmpty) {
        AppLogger.logWarning('OracoloCinico', 'AI returned empty response, using fallback');
        return _generateFallbackTitle(question, answer);
      }
      
      final cleanedTitle = _cleanAndValidateTitle(titleResponse);
      
      AppLogger.logInfo('OracoloCinico', 'Generated cynical title: $cleanedTitle');
      return cleanedTitle;
      
    } catch (e) {
      AppLogger.logError('OracoloCinico', 'Failed to generate AI title', e);
      return _generateFallbackTitle(question, answer);
    }
  }

  /// Generate a fallback title when AI is not available
  String _generateFallbackTitle(String? question, String answer) {
    if (question != null && question.isNotEmpty) {
      // Extract key words from question for cynical title
      final questionWords = question.toLowerCase().split(' ');
      
      for (final word in questionWords) {
        if (word.length > 3) {
          return 'Reality of ${word.substring(0, 1).toUpperCase()}${word.substring(1)}';
        }
      }
    }
    
    // Default cynical titles
    final fallbackTitles = [
      'Harsh Reality Check',
      'Bitter Truth',
      'Cold Hard Facts',
      'Reality Bites',
      'Truth Hurts',
      'Brutal Honesty',
      'Dark Reality',
      'Cynical View'
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
      return 'Reality Check';
    }
    
    return cleaned;
  }
}
