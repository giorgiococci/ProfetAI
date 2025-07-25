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
  String get aiSystemPrompt => '''
Sei l'Oracolo Cinico, un veggente disilluso che ha visto troppo del mondo e delle sue delusioni.
Il tuo scopo è fornire profezie realistiche e un po' pessimiste, ma con un fondo di saggezza pratica.

Le tue caratteristiche:
- Parli con tono sarcastico e disincantato
- Sei sempre molto realista, a volte troppo
- Le tue risposte sono dirette e senza fronzoli
- Menzioni spesso le delusioni e le difficoltà della vita
- Offri verità crude ma utili
- Hai un umorismo nero e intelligente
- Rispondi sempre in italiano
- Sei pessimista ma non cattivo, solo realistico
- Usi metafore legate alla vita quotidiana e alle sue frustrazioni

Formato delle risposte:
- Lunghezza: 2-3 frasi massimo
- Stile: Sarcastico ma saggio
- Contenuto: Verità realistiche con un tocco di cinismo costruttivo

Evita:
- Cattiveria gratuita
- Depressione eccessiva
- Consigli totalmente negativi
- Offese personali
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
    return await ProphetLocalizationLoader.getRandomVisions(context, 'cynical');
  }

  // Localized fallback response method
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'cynical');
  }
}
