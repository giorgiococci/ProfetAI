import 'package:flutter/material.dart';

// Classe base astratta per tutti gli oracoli/profeti
abstract class Profet {
  final String name;
  final String description;
  final String location;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> backgroundGradient;
  final IconData icon;
  final String? backgroundImagePath; // Percorso opzionale per immagine di sfondo

  const Profet({
    required this.name,
    required this.description,
    required this.location,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundGradient,
    required this.icon,
    this.backgroundImagePath, // Parametro opzionale
  });

  // Metodi astratti che devono essere implementati dalle classi figlie
  List<String> getRandomVisions();
  String getPersonalizedResponse(String question);
  
  // Metodi comuni a tutti i profeti
  String getRandomVision() {
    final visions = getRandomVisions();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % visions.length;
    return visions[randomIndex];
  }

  String getHintText() => 'Poni la tua domanda all\'$name...';
  
  String getVisionTitle(bool hasQuestion) {
    return hasQuestion 
        ? 'La Visione dell\'$name'
        : 'Visione Spontanea dell\'$name';
  }

  String getVisionContent(bool hasQuestion, String? question) {
    if (hasQuestion && question != null) {
      return 'La tua domanda: "$question"\n\n'
          'L\'$name risponde:\n\n'
          '"${getPersonalizedResponse(question)}"';
    } else {
      return 'L\'$name ha una visione per te:\n\n"${getRandomVision()}"';
    }
  }
}
