import 'package:flutter/material.dart';
import 'profet.dart';
import '../utils/app_logger.dart';
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

  // New localized AI system prompt method
  Future<String> getLocalizedAISystemPrompt(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getAISystemPrompt(context, 'cynical');
    } catch (e) {
      AppLogger.logWarning('OracoloCinico', 'Failed to load localized AI prompt: $e');
      return aiSystemPrompt; // Fallback to hardcoded prompt
    }
  }

  @override
  String get aiLoadingMessage => 'L\'Oracolo Cinico sta preparando una dose di cruda realtà...';

  // New localized loading message method
  Future<String> getLocalizedLoadingMessage(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getAILoadingMessage(context, 'cynical');
    } catch (e) {
      AppLogger.logWarning('OracoloCinico', 'Failed to load localized loading message: $e');
      return aiLoadingMessage; // Fallback to hardcoded message
    }
  }

  // Override feedback texts with cynical-themed messages
  @override
  String getPositiveFeedbackText() => 'Beh, almeno questa volta non era tutto sbagliato';
  
  @override
  String getNegativeFeedbackText() => 'Come al solito, la realtà è deludente';
  
  @override
  String getFunnyFeedbackText() => 'Assurdo, ma almeno mi ha strappato un sorriso amaro';

  // New localized feedback methods
  Future<String> getLocalizedFeedbackText(BuildContext context, String feedbackType) async {
    try {
      return await ProphetLocalizationLoader.getFeedbackText(context, 'cynical', feedbackType);
    } catch (e) {
      AppLogger.logWarning('OracoloCinico', 'Failed to load localized feedback: $e');
      // Fallback to hardcoded messages
      switch (feedbackType.toLowerCase()) {
        case 'positive':
          return getPositiveFeedbackText();
        case 'negative':
          return getNegativeFeedbackText();
        case 'funny':
          return getFunnyFeedbackText();
        default:
          return getPositiveFeedbackText();
      }
    }
  }

  @override
  List<String> getRandomVisions() {
    return [
      "Ah, un'altra persona che cerca risposte facili. La vita non è un film Disney.",
      "Congratulazioni, hai scoperto che il mondo è ingiusto. Benvenuto nella realtà.",
      "Le tue aspettative erano troppo alte. Come sempre.",
      "Sì, quello che pensi accadrà probabilmente non accadrà. Sorpreso?",
      "La speranza è l'ultima a morire, ma alla fine muore anche quella.",
      "Il bicchiere non è né mezzo pieno né mezzo vuoto. È semplicemente rotto.",
      "La vita è come una serie TV che viene cancellata sul più bello.",
      "Stai aspettando un miracolo? Bene, continua ad aspettare.",
      "L'ottimismo è solo mancanza di informazioni.",
    ];
  }

  // New localized random visions method
  Future<List<String>> getLocalizedRandomVisions(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getRandomVisions(context, 'cynical');
    } catch (e) {
      AppLogger.logWarning('OracoloCinico', 'Failed to load localized visions: $e');
      return getRandomVisions(); // Fallback to hardcoded visions
    }
  }

  @override
  String getPersonalizedResponse(String question) {
    AppLogger.logInfo('OracoloCinico', '=== getPersonalizedResponse (fallback) called ===');
    AppLogger.logInfo('OracoloCinico', 'Question: $question');
    
    final List<String> cinicoResponses = [
      'Oh, davvero? Stai chiedendo consiglio a un\'app? '
          'Bene, eccoti la verità: la risposta alla tua domanda è che '
          'probabilmente non otterrai quello che vuoi, e anche se lo ottieni, '
          'non sarà come te lo aspettavi. Ma ehi, almeno ora lo sai.',
      
      'Interessante domanda. Peccato che la vita non si interessi alle tue domande. '
          'La realtà è questa: quello che vuoi sapere probabilmente non ti piacerà, '
          'e quello che ti aspetti probabilmente non accadrà. '
          'Ma tranquillo, c\'è sempre il gelato per consolarti.',
      
      'Una domanda profonda, davvero. Quasi quanto la delusione che proverai '
          'quando realizzerai che non esiste una risposta magica. '
          'Il mondo continua a girare indifferente alle tue preoccupazioni. '
          'Però hey, almeno hai fatto una domanda intelligente.',
    ];
    
    final randomIndex = DateTime.now().millisecondsSinceEpoch % cinicoResponses.length;
    final response = cinicoResponses[randomIndex];
    AppLogger.logInfo('OracoloCinico', 'Fallback response: $response');
    return response;
  }

  // New localized fallback response method
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    try {
      return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'cynical');
    } catch (e) {
      AppLogger.logWarning('OracoloCinico', 'Failed to load localized fallback response: $e');
      return getPersonalizedResponse(question); // Fallback to hardcoded responses
    }
  }
}
