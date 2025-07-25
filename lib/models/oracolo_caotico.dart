import 'package:flutter/material.dart';
import 'profet.dart';
import '../utils/app_logger.dart';
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

  // New localized AI system prompt method
  Future<String> getLocalizedAISystemPrompt(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getAISystemPrompt(context, 'chaotic');
    } catch (e) {
      AppLogger.logWarning('OracoloCaotico', 'Failed to load localized AI prompt: $e');
      return aiSystemPrompt; // Fallback to hardcoded prompt
    }
  }

  @override
  String get aiLoadingMessage => 'L\'Oracolo Caotico sta mescolando le carte della realtà...';

  // New localized loading message method
  Future<String> getLocalizedLoadingMessage(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getAILoadingMessage(context, 'chaotic');
    } catch (e) {
      AppLogger.logWarning('OracoloCaotico', 'Failed to load localized loading message: $e');
      return aiLoadingMessage; // Fallback to hardcoded message
    }
  }

  // Override feedback texts with chaotic-themed messages
  @override
  String getPositiveFeedbackText() => 'EUREKA! Gli unicorni cosmici hanno DANZATO nel mio cervello!';
  
  @override
  String getNegativeFeedbackText() => 'I gatti di Schrödinger erano tutti morti oggi, che sfortuna!';
  
  @override
  String getFunnyFeedbackText() => 'Ho riso come un pinguino che fa surf su una pizza volante!';

  // New localized feedback methods
  Future<String> getLocalizedFeedbackText(BuildContext context, String feedbackType) async {
    try {
      return await ProphetLocalizationLoader.getFeedbackText(context, 'chaotic', feedbackType);
    } catch (e) {
      AppLogger.logWarning('OracoloCaotico', 'Failed to load localized feedback: $e');
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
      "CAOS! La tua vita è come un sandwich al burro d'arachidi che cade sempre dal lato sbagliato!",
      "Le probabilità dicono 42. Non chiedere il perché, l'universo è così.",
      "Un unicorno viola sta ballando la macarena nel tuo futuro. O forse è solo martedì.",
      "ATTENZIONE: Il caos rileva anomalie spazio-temporali nel tuo caffè del mattino!",
      "La risposta è: SÌ, NO, FORSE, DECISAMENTE, MAI PIÙ. Scegli tu!",
      "Il destino ha fatto cadere i suoi dadi... sono finiti sotto il divano.",
      "ERRORE 404: Destino non trovato. Riprova dopo aver riavviato la realtà.",
      "Il gatto di Schrödinger ha appena fatto una scommessa sul tuo futuro. Ha vinto... o perso?",
      "BREAKING NEWS: L'universo ha dichiarato sciopero. Aspetta sviluppi caotici.",
    ];
  }

  // New localized random visions method
  Future<List<String>> getLocalizedRandomVisions(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getRandomVisions(context, 'chaotic');
    } catch (e) {
      AppLogger.logWarning('OracoloCaotico', 'Failed to load localized visions: $e');
      return getRandomVisions(); // Fallback to hardcoded visions
    }
  }

  @override
  String getPersonalizedResponse(String question) {
    AppLogger.logInfo('OracoloCaotico', '=== getPersonalizedResponse (fallback) called ===');
    AppLogger.logInfo('OracoloCaotico', 'Question: $question');
    
    final List<String> caoticResponses = [
      'CAOS DETECTED! 🌪️ La tua domanda ha creato un paradosso temporale! '
          'La risposta è: fai esattamente il contrario di quello che pensi sia giusto, '
          'ma solo nei giorni pari, e quando piove. Oppure comprati un gatto. '
          'Il caos approva entrambe le opzioni!',
      
      'ALERT! 🚨 Il tuo cervello ha fatto una domanda troppo logica! '
          'Sistema di risposta: ERRORE CRITICO. Soluzione: balla per 3 minuti, '
          'poi decidi lanciando una moneta. Se cade di taglio, la risposta è "forse".',
      
      'CAOS SUPREMO! 🎪 La tua domanda ha fatto ridere l\'universo! '
          'Risposta ufficiale: fai quello che NON faresti mai, '
          'ma solo dopo aver mangiato una pizza con l\'ananas. '
          'Trust the chaos, embrace the weird!',
    ];
    
    final randomIndex = DateTime.now().millisecondsSinceEpoch % caoticResponses.length;
    final response = caoticResponses[randomIndex];
    AppLogger.logInfo('OracoloCaotico', 'Fallback response: $response');
    return response;
  }

  // New localized fallback response method
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    try {
      return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'chaotic');
    } catch (e) {
      AppLogger.logWarning('OracoloCaotico', 'Failed to load localized fallback response: $e');
      return getPersonalizedResponse(question); // Fallback to hardcoded responses
    }
  }
}
