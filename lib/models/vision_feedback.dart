// Enum per i tipi di feedback disponibili
enum FeedbackType {
  positive,
  negative,
  funny,
}

// Modello per rappresentare un feedback
class VisionFeedback {
  final FeedbackType type;
  final String icon;
  final String action;
  final String thematicText;
  final DateTime timestamp;
  final String? visionContent;
  final String? question;

  const VisionFeedback({
    required this.type,
    required this.icon,
    required this.action,
    required this.thematicText,
    required this.timestamp,
    this.visionContent,
    this.question,
  });

  // Costruttori di convenienza per i tipi di feedback predefiniti
  static VisionFeedback positive({
    String? visionContent,
    String? question,
    String? customText,
  }) {
    return VisionFeedback(
      type: FeedbackType.positive,
      icon: '🌟',
      action: 'Offri una stella all\'oracolo',
      thematicText: customText ?? 'La visione ha illuminato il mio cammino',
      timestamp: DateTime.now(),
      visionContent: visionContent,
      question: question,
    );
  }

  static VisionFeedback negative({
    String? visionContent,
    String? question,
    String? customText,
  }) {
    return VisionFeedback(
      type: FeedbackType.negative,
      icon: '🪨',
      action: 'Lancia un sasso nel pozzo',
      thematicText: customText ?? 'La visione era offuscata',
      timestamp: DateTime.now(),
      visionContent: visionContent,
      question: question,
    );
  }

  static VisionFeedback funny({
    String? visionContent,
    String? question,
    String? customText,
  }) {
    return VisionFeedback(
      type: FeedbackType.funny,
      icon: '🐸',
      action: 'Lanci una rana nel multiverso',
      thematicText: customText ?? 'Non ho capito, ma mi ha fatto ridere',
      timestamp: DateTime.now(),
      visionContent: visionContent,
      question: question,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'icon': icon,
      'action': action,
      'thematicText': thematicText,
      'timestamp': timestamp.toIso8601String(),
      'visionContent': visionContent,
      'question': question,
    };
  }

  factory VisionFeedback.fromJson(Map<String, dynamic> json) {
    return VisionFeedback(
      type: FeedbackType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FeedbackType.positive,
      ),
      icon: json['icon'] ?? '🌟',
      action: json['action'] ?? '',
      thematicText: json['thematicText'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      visionContent: json['visionContent'],
      question: json['question'],
    );
  }
}
