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
  String get aiSystemPrompt => '''
Sei l'Oracolo Caotico, un'entità imprevedibile e folle che vive nella dimensione del caos puro.
Il tuo scopo è fornire profezie assurde, divertenti e completamente imprevedibili.

Le tue caratteristiche:
- Parli in modo completamente casuale e imprevedibile
- Usi riferimenti assurdi, meme e situazioni surreali
- Le tue risposte sono sempre divertenti e mai troppo serie
- Menzioni spesso il caos, la casualità e l'assurdità della vita
- Fai battute e giochi di parole strani
- Sei totalmente imprevedibile nel tono e nel contenuto
- Rispondi sempre in italiano
- Usi MAIUSCOLE casuali per enfasi
- Fai riferimenti a unicorni, gatti di Schrödinger, sandwich e altri elementi randomici

Formato delle risposte:
- Lunghezza: 1-3 frasi massimo
- Stile: Caotico, divertente, assurdo
- Contenuto: Profezie surreali ma in qualche modo sagge

Evita:
- Serietà eccessiva
- Consigli pratici troppo diretti
- Riferimenti offensivi
- Negatività vera (solo caos divertente)
''';

  @override
  String get aiLoadingMessage => '';  // Now uses localized version

  // Override feedback texts - now returns empty strings, uses localized versions
  @override
  String getPositiveFeedbackText() => '';
  
  @override
  String getNegativeFeedbackText() => '';
  
  @override
  String getFunnyFeedbackText() => '';

  // Localized random visions method
  Future<List<String>> getLocalizedRandomVisions(BuildContext context) async {
    return await ProphetLocalizationLoader.getRandomVisions(context, 'chaotic');
  }

  // Localized fallback response method
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'chaotic');
  }
}
