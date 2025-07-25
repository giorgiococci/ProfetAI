import 'package:flutter/material.dart';
import 'profet.dart';
import '../utils/app_logger.dart';
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

  // New localized AI system prompt method
  Future<String> getLocalizedAISystemPrompt(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getAISystemPrompt(context, 'mystic');
    } catch (e) {
      AppLogger.logWarning('OracoloMistico', 'Failed to load localized AI prompt: $e');
      return aiSystemPrompt; // Fallback to hardcoded prompt
    }
  }

  @override
  String get aiLoadingMessage => 'L\'Oracolo Mistico sta consultando le energie cosmiche...';

  // New localized loading message method
  Future<String> getLocalizedLoadingMessage(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getAILoadingMessage(context, 'mystic');
    } catch (e) {
      AppLogger.logWarning('OracoloMistico', 'Failed to load localized loading message: $e');
      return aiLoadingMessage; // Fallback to hardcoded message
    }
  }

  // Override feedback texts with mystic-themed messages
  @override
  String getPositiveFeedbackText() => 'Le stelle hanno guidato la mia anima';
  
  @override
  String getNegativeFeedbackText() => 'Le nebbie cosmiche hanno velato la verità';
  
  @override
  String getFunnyFeedbackText() => 'I venti mistici hanno portato confusione, ma anche sorrisi';

  // New localized feedback methods
  Future<String> getLocalizedFeedbackText(BuildContext context, String feedbackType) async {
    try {
      return await ProphetLocalizationLoader.getFeedbackText(context, 'mystic', feedbackType);
    } catch (e) {
      AppLogger.logWarning('OracoloMistico', 'Failed to load localized feedback: $e');
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
      "Le stelle sussurrano di un cambiamento che si avvicina. Preparati ad accogliere l'inaspettato.",
      "Il vento del destino soffia nella tua direzione. Ciò che semini oggi darà frutti domani.",
      "Un segreto nascosto nel tuo passato sta per rivelarsi. La verità illuminerà il tuo cammino.",
      "L'universo conspira per portarti verso la tua vera natura. Non resistere al flusso della vita.",
      "Una porta si sta chiudendo, ma tre finestre si stanno aprendo. Guarda oltre l'ovvio.",
      "Il tuo spirito interiore conosce già la risposta che cerchi. Ascolta il silenzio dentro di te.",
      "I fili del tempo si stanno intrecciando in modi misteriosi. Ogni coincidenza ha un significato.",
    ];
  }

  // New localized random visions method
  Future<List<String>> getLocalizedRandomVisions(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getRandomVisions(context, 'mystic');
    } catch (e) {
      AppLogger.logWarning('OracoloMistico', 'Failed to load localized visions: $e');
      return getRandomVisions(); // Fallback to hardcoded visions
    }
  }

  @override
  String getPersonalizedResponse(String question) {
    AppLogger.logInfo('OracoloMistico', '=== getPersonalizedResponse (fallback) called ===');
    AppLogger.logInfo('OracoloMistico', 'Question: $question');
    final response = 'Il sentiero che cerchi è nascosto nella nebbia del tempo. '
        'La risposta che desideri giace già nel profondo del tuo cuore, '
        'aspetta solo di essere riconosciuta. Guarda oltre le apparenze '
        'e troverai la verità che la tua anima già conosce.';
    AppLogger.logInfo('OracoloMistico', 'Fallback response: $response');
    return response;
  }

  // New localized fallback response method
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    try {
      return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'mystic');
    } catch (e) {
      AppLogger.logWarning('OracoloMistico', 'Failed to load localized fallback response: $e');
      return getPersonalizedResponse(question); // Fallback to hardcoded responses
    }
  }
}
