import 'package:flutter/material.dart';
import 'profet.dart';
import '../l10n/prophet_localization_loader.dart';
import '../services/ai_service_manager.dart';
import '../utils/app_logger.dart';

class OracoloRoaster extends Profet {
  const OracoloRoaster() : super(
    name: 'Oracolo Satirico',
    description: 'Sarcasmo divino con onestà brutale',
    location: 'TEMPLE OF DIVINE JUDGMENT',
    primaryColor: const Color(0xFFFF3D00), // Burning red-orange
    secondaryColor: const Color(0xFFFF5722), // Fiery orange
    backgroundGradient: const [
      Color(0xFF8B0000), // Dark red
      Color(0xFF4A0E00), // Dark brown-red
      Color(0xFF1A0000), // Very dark red
    ],
    icon: Icons.local_fire_department,
    backgroundImagePath: 'assets/images/backgrounds/roaster_profet_background.png',
    profetImagePath: 'assets/images/prophets/roaster_prophet.png',
  );

  @override
  String get type => 'roaster_prophet';

  @override
  String get aiSystemPrompt => '';  // Now uses localized version

  @override
  String get aiLoadingMessage => '';  // Now uses localized version

  // Localized AI system prompt method
  @override
  Future<String> getLocalizedAISystemPrompt(BuildContext context) async {
    return await ProphetLocalizationLoader.getAISystemPrompt(context, 'roaster_prophet');
  }

  // Localized random visions method
  @override
  Future<List<String>> getLocalizedRandomVisions(BuildContext context) async {
    return await ProphetLocalizationLoader.getRandomVisions(context, 'roaster_prophet');
  }

  // Localized fallback response method
  @override
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'roaster_prophet');
  }

  // Generate AI-powered vision title with roasting style
  @override
  Future<String> generateVisionTitle(BuildContext context, {
    String? question,
    required String answer,
  }) async {
    try {
      AppLogger.logInfo('OracoloRoaster', 'Generating roasting vision title');
      
      if (!AIServiceManager.isAIAvailable) {
        AppLogger.logWarning('OracoloRoaster', 'AI service not available, using fallback title');
        return _generateFallbackTitle(question, answer);
      }

      // Create a roasting, sarcastic prompt for title generation
      final titlePrompt = '''
You are The Prophet Who Roasts, a theatrical and brutally honest oracle. Create a savage, sarcastic title for a vision.

Context:
${question != null ? 'Question: $question\n' : ''}Vision Answer: $answer

Requirements:
- Maximum 30 characters
- Roasting and theatrical tone
- Use savage words like: Roasted, Burnt, Judgment, Truth, Reality, Check, Called Out, Exposed, Served
- Include dramatic flair with mystic elements
- Be brutally honest but theatrical
- Focus on the harsh reality revealed in the vision

Examples of style: "Reality Check Served", "Truth Burns Deep", "Cosmic Roast Session", "Divine Judgment Call"

Generate ONLY the title, no quotes or extra text.''';

      final response = await AIServiceManager.generateResponse(
        prompt: titlePrompt,
        systemMessage: '',
        maxTokens: 50,
        temperature: 0.7,
      );

      if (response != null && response.trim().isNotEmpty) {
        // Clean up the response and ensure it's within length limits
        String title = response.trim();
        if (title.length > 30) {
          title = '${title.substring(0, 27)}...';
        }
        AppLogger.logInfo('OracoloRoaster', 'Generated roasting title: $title');
        return title;
      } else {
        AppLogger.logWarning('OracoloRoaster', 'AI returned empty title, using fallback');
        return _generateFallbackTitle(question, answer);
      }
    } catch (e) {
      AppLogger.logError('OracoloRoaster', 'Error generating AI title', e);
      return _generateFallbackTitle(question, answer);
    }
  }

  String _generateFallbackTitle(String? question, String answer) {
    final fallbackTitles = [
      'Divine Roast Session',
      'Truth Burns Deep',
      'Reality Check Served',
      'Cosmic Judgment Call',
      'Brutal Truth Bomb',
      'Sacred Sass Attack',
      'Mystical Mic Drop',
      'Divine Reality Check',
      'Roasted by the Gods',
      'Truth Tea Served Hot',
    ];
    
    // Use a simple hash of the answer to pick a consistent title
    final hashCode = answer.hashCode.abs();
    final index = hashCode % fallbackTitles.length;
    
    AppLogger.logInfo('OracoloRoaster', 'Using fallback title: ${fallbackTitles[index]}');
    return fallbackTitles[index];
  }
}
