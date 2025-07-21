import 'package:flutter/material.dart';
import 'profet.dart';

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
  );

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

  @override
  String getPersonalizedResponse(String question) {
    return 'Il sentiero che cerchi è nascosto nella nebbia del tempo. '
        'La risposta che desideri giace già nel profondo del tuo cuore, '
        'aspetta solo di essere riconosciuta. Guarda oltre le apparenze '
        'e troverai la verità che la tua anima già conosce.';
  }
}
