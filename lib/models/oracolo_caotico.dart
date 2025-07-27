import 'package:flutter/material.dart';
import 'profet.dart';
import '../l10n/prophet_localization_loader.dart';

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
}
