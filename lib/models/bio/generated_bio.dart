/// Generated biographical narrative model
class GeneratedBio {
  final String id;
  final String userId;
  final Map<String, String> sections;
  final int totalInsightsUsed;
  final double confidenceScore;
  final DateTime generatedAt;
  final DateTime? lastUsedAt;

  const GeneratedBio({
    required this.id,
    required this.userId,
    required this.sections,
    required this.totalInsightsUsed,
    required this.confidenceScore,
    required this.generatedAt,
    this.lastUsedAt,
  });

  /// Create a copy with updated fields
  GeneratedBio copyWith({
    String? id,
    String? userId,
    Map<String, String>? sections,
    int? totalInsightsUsed,
    double? confidenceScore,
    DateTime? generatedAt,
    DateTime? lastUsedAt,
  }) {
    return GeneratedBio(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sections: sections ?? this.sections,
      totalInsightsUsed: totalInsightsUsed ?? this.totalInsightsUsed,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      generatedAt: generatedAt ?? this.generatedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'sections_json': _sectionsToJson(),
      'total_insights_used': totalInsightsUsed,
      'confidence_score': confidenceScore,
      'generated_at': generatedAt.millisecondsSinceEpoch,
      'last_used_at': lastUsedAt?.millisecondsSinceEpoch,
    };
  }

  /// Create from database map
  static GeneratedBio fromMap(Map<String, dynamic> map) {
    return GeneratedBio(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      sections: _sectionsFromJson(map['sections_json'] as String),
      totalInsightsUsed: map['total_insights_used'] as int,
      confidenceScore: map['confidence_score'] as double,
      generatedAt: DateTime.fromMillisecondsSinceEpoch(map['generated_at'] as int),
      lastUsedAt: map['last_used_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_used_at'] as int)
          : null,
    );
  }

  /// Convert sections map to JSON string
  String _sectionsToJson() {
    final buffer = StringBuffer();
    buffer.write('{');
    
    final entries = sections.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('"${entry.key}":"${entry.value.replaceAll('"', '\\"')}"');
      if (i < entries.length - 1) buffer.write(',');
    }
    
    buffer.write('}');
    return buffer.toString();
  }

  /// Parse sections from JSON string
  static Map<String, String> _sectionsFromJson(String json) {
    final sections = <String, String>{};
    
    try {
      // Simple JSON parsing for key-value pairs
      final content = json.substring(1, json.length - 1); // Remove { }
      final pairs = content.split('","');
      
      for (final pair in pairs) {
        final cleanPair = pair.replaceAll('"', '');
        final colonIndex = cleanPair.indexOf(':');
        if (colonIndex > 0) {
          final key = cleanPair.substring(0, colonIndex);
          final value = cleanPair.substring(colonIndex + 1).replaceAll('\\"', '"');
          sections[key] = value;
        }
      }
    } catch (e) {
      // If parsing fails, return empty sections
      return {};
    }
    
    return sections;
  }

  /// Get formatted bio text for display
  String getFormattedBioText() {
    final buffer = StringBuffer();
    
    final sectionOrder = ['interests', 'personality', 'background', 'goals', 'preferences'];
    
    for (final sectionKey in sectionOrder) {
      final content = sections[sectionKey];
      if (content != null && content != 'No specific information available') {
        final title = _formatSectionTitle(sectionKey);
        buffer.writeln('$title\n$content\n');
      }
    }
    
    return buffer.toString().trim();
  }

  /// Format section title for display
  String _formatSectionTitle(String key) {
    switch (key) {
      case 'interests':
        return '🎯 Interests & Hobbies';
      case 'personality':
        return '✨ Personality';
      case 'background':
        return '📚 Background';
      case 'goals':
        return '🎯 Goals & Aspirations';
      case 'preferences':
        return '⚙️ Preferences';
      default:
        return key.toUpperCase();
    }
  }

  @override
  String toString() {
    return 'GeneratedBio(id: $id, userId: $userId, sections: ${sections.length}, '
           'insights: $totalInsightsUsed, confidence: $confidenceScore)';
  }
}
