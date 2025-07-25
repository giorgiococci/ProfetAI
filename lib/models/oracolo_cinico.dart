import 'package:flutter/material.dart';
import 'profet.dart';
import '../l10n/prophet_localization_loader.dart';

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
}
