import 'package:flutter/material.dart';
import 'profet.dart';

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
    backgroundImagePath: 'assets/images/backgrounds/chaotic_profet_background.png', // Immagine caotica
  );

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

  @override
  String getPersonalizedResponse(String question) {
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
    return caoticResponses[randomIndex];
  }
}
