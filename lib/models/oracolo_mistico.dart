import 'package:flutter/material.dart';
import 'profet.dart';
import '../l10n/prophet_localization_loader.dart';

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
    // profetImagePath: 'assets/images/prophets/mystic_prophet.png', // Opzionale
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
}
