import 'package:flutter/material.dart';
import 'profet.dart';

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
    backgroundImagePath: 'assets/images/backgrounds/oracolo_cinico_background.jpg', // Immagine cinica
  );

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

  @override
  String getPersonalizedResponse(String question) {
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
    return cinicoResponses[randomIndex];
  }
}
