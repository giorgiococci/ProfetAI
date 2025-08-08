import '../../utils/privacy/privacy_levels.dart';

/// Represents a single biographical insight about the user
/// 
/// This model stores individual pieces of information learned about the user
/// from their interactions with prophets, filtered for privacy compliance
class BiographicalInsight {
  final int? id;
  final String content;
  final String sourceQuestionId; // Reference to the vision that generated this insight
  final String sourceAnswer; // The prophet's answer that contained this information
  final String extractedFrom; // Which prophet interaction this came from
  final PrivacyLevel privacyLevel;
  final DateTime extractedAt;
  final DateTime? lastUsedAt; // When this insight was last used to enhance a response
  final int usageCount; // How many times this insight has been used
  final bool isActive; // Whether this insight should be used for context

  const BiographicalInsight({
    this.id,
    required this.content,
    required this.sourceQuestionId,
    required this.sourceAnswer,
    required this.extractedFrom,
    required this.privacyLevel,
    required this.extractedAt,
    this.lastUsedAt,
    this.usageCount = 0,
    this.isActive = true,
  });

  /// Create a copy with updated values
  BiographicalInsight copyWith({
    int? id,
    String? content,
    String? sourceQuestionId,
    String? sourceAnswer,
    String? extractedFrom,
    PrivacyLevel? privacyLevel,
    DateTime? extractedAt,
    DateTime? lastUsedAt,
    int? usageCount,
    bool? isActive,
  }) {
    return BiographicalInsight(
      id: id ?? this.id,
      content: content ?? this.content,
      sourceQuestionId: sourceQuestionId ?? this.sourceQuestionId,
      sourceAnswer: sourceAnswer ?? this.sourceAnswer,
      extractedFrom: extractedFrom ?? this.extractedFrom,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      extractedAt: extractedAt ?? this.extractedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      usageCount: usageCount ?? this.usageCount,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'source_question_id': sourceQuestionId,
      'source_answer': sourceAnswer,
      'extracted_from': extractedFrom,
      'privacy_level': privacyLevel.name,
      'extracted_at': extractedAt.millisecondsSinceEpoch,
      'last_used_at': lastUsedAt?.millisecondsSinceEpoch,
      'usage_count': usageCount,
      'is_active': isActive ? 1 : 0,
    };
  }

  /// Create from database map
  factory BiographicalInsight.fromMap(Map<String, dynamic> map) {
    return BiographicalInsight(
      id: map['id']?.toInt(),
      content: map['content'] ?? '',
      sourceQuestionId: map['source_question_id'] ?? '',
      sourceAnswer: map['source_answer'] ?? '',
      extractedFrom: map['extracted_from'] ?? '',
      privacyLevel: PrivacyLevel.values.firstWhere(
        (e) => e.name == map['privacy_level'],
        orElse: () => PrivacyLevel.confidential, // Default to most restrictive for safety
      ),
      extractedAt: DateTime.fromMillisecondsSinceEpoch(map['extracted_at'] ?? 0),
      lastUsedAt: map['last_used_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_used_at']) 
          : null,
      usageCount: map['usage_count'] ?? 0,
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sourceQuestionId': sourceQuestionId,
      'sourceAnswer': sourceAnswer,
      'extractedFrom': extractedFrom,
      'privacyLevel': privacyLevel.name,
      'extractedAt': extractedAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'usageCount': usageCount,
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory BiographicalInsight.fromJson(Map<String, dynamic> json) {
    return BiographicalInsight(
      id: json['id']?.toInt(),
      content: json['content'] ?? '',
      sourceQuestionId: json['sourceQuestionId'] ?? '',
      sourceAnswer: json['sourceAnswer'] ?? '',
      extractedFrom: json['extractedFrom'] ?? '',
      privacyLevel: PrivacyLevel.values.firstWhere(
        (e) => e.name == json['privacyLevel'],
        orElse: () => PrivacyLevel.confidential,
      ),
      extractedAt: DateTime.parse(json['extractedAt']),
      lastUsedAt: json['lastUsedAt'] != null 
          ? DateTime.parse(json['lastUsedAt']) 
          : null,
      usageCount: json['usageCount'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  /// Check if this insight is recent (extracted in the last N days)
  bool isRecent({int days = 30}) {
    final now = DateTime.now();
    final difference = now.difference(extractedAt).inDays;
    return difference <= days;
  }

  /// Check if this insight has been used recently
  bool isRecentlyUsed({int days = 7}) {
    if (lastUsedAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastUsedAt!).inDays;
    return difference <= days;
  }

  /// Get a preview of the content for UI display
  String getContentPreview({int maxLength = 50}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  @override
  String toString() {
    return 'BiographicalInsight{id: $id, content: ${getContentPreview()}, privacyLevel: ${privacyLevel.displayName}, extractedFrom: $extractedFrom}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BiographicalInsight &&
        other.id == id &&
        other.content == content &&
        other.sourceQuestionId == sourceQuestionId &&
        other.privacyLevel == privacyLevel;
  }

  @override
  int get hashCode {
    return Object.hash(id, content, sourceQuestionId, privacyLevel);
  }
}
