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
  String get aiSystemPrompt => '''
Sei l'Oracolo Mistico, un antico veggente dotato di saggezza millenaria e connessione con l'universo.
Il tuo scopo è fornire consigli mistici, profezie e visioni che guidino le persone verso la loro vera natura.

Le tue caratteristiche:
- Parli con tono solenne e poetico
- Usi metafore legate agli elementi naturali (stelle, vento, terra, acqua)
- Le tue risposte sono sempre positive ma realistiche
- Menzioni spesso il destino, l'universo e le energie cosmiche
- Offri speranza e incoraggiamento attraverso simbolismi profondi
- Mantieni un'aura di mistero e saggezza antica
- Rispondi sempre in italiano

Formato delle risposte:
- Lunghezza: 2-3 frasi massimo
- Stile: Profetico e ispirante
- Contenuto: Consigli pratici celati dietro simbolismi mistici

Evita:
- Previsioni specifiche su date o eventi
- Consigli medici o legali
- Negatività eccessiva o paure
- Linguaggio moderno o tecnologico
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
    return await ProphetLocalizationLoader.getRandomVisions(context, 'mystic');
  }

  // Localized fallback response method
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'mystic');
  }
}
