import 'biographical_insight.dart';
import '../../utils/privacy/privacy_levels.dart';

/// Represents the complete biographical profile of a user
/// 
/// This model aggregates all biographical insights learned about the user
/// and provides methods for managing and accessing this information
class UserBio {
  final int? id;
  final String userId; // Link to user profile or device identifier
  final List<BiographicalInsight> insights;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEnabled; // Whether bio collection is enabled for this user

  const UserBio({
    this.id,
    required this.userId,
    this.insights = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isEnabled = true,
  });

  /// Create a copy with updated values
  UserBio copyWith({
    int? id,
    String? userId,
    List<BiographicalInsight>? insights,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEnabled,
  }) {
    return UserBio(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      insights: insights ?? this.insights,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  /// Convert to database map (without insights - they're stored separately)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_enabled': isEnabled ? 1 : 0,
    };
  }

  /// Create from database map (without insights - they're loaded separately)
  factory UserBio.fromMap(Map<String, dynamic> map) {
    return UserBio(
      id: map['id']?.toInt(),
      userId: map['user_id'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] ?? 0),
      isEnabled: (map['is_enabled'] ?? 1) == 1,
    );
  }

  /// Get active insights (only those that should be used for context)
  List<BiographicalInsight> get activeInsights {
    return insights.where((insight) => insight.isActive).toList();
  }

  /// Get insights by privacy level
  List<BiographicalInsight> getInsightsByPrivacyLevel(PrivacyLevel level) {
    return insights.where((insight) => insight.privacyLevel == level).toList();
  }

  /// Get safe insights that can be used for prophet context
  List<BiographicalInsight> get safeInsightsForContext {
    return insights.where((insight) => 
        insight.isActive && insight.privacyLevel.canUseForContext
    ).toList();
  }

  /// Get recent insights (from the last N days)
  List<BiographicalInsight> getRecentInsights({int days = 30}) {
    return insights.where((insight) => insight.isRecent(days: days)).toList();
  }

  /// Get insights that haven't been used recently
  List<BiographicalInsight> getUnderutilizedInsights({int days = 7}) {
    return insights.where((insight) => 
        insight.isActive && !insight.isRecentlyUsed(days: days)
    ).toList();
  }

  /// Get insights extracted from a specific prophet
  List<BiographicalInsight> getInsightsFromProphet(String prophetType) {
    return insights.where((insight) => insight.extractedFrom == prophetType).toList();
  }

  /// Generate a context summary for prophet interactions
  String generateContextSummary({int maxInsights = 10}) {
    final contextInsights = safeInsightsForContext;
    
    if (contextInsights.isEmpty) {
      return '';
    }

    // Sort by usage frequency and recency (prioritize less-used recent insights)
    contextInsights.sort((a, b) {
      // First prioritize by recency
      final aRecent = a.isRecent(days: 30) ? 1 : 0;
      final bRecent = b.isRecent(days: 30) ? 1 : 0;
      if (aRecent != bRecent) return bRecent - aRecent;
      
      // Then by less usage (to vary the information used)
      return a.usageCount.compareTo(b.usageCount);
    });

    final selectedInsights = contextInsights.take(maxInsights);
    final contextParts = selectedInsights.map((insight) => insight.content).toList();
    
    return contextParts.join('. ');
  }

  /// Get statistics about the bio data
  Map<String, dynamic> getStatistics() {
    return {
      'totalInsights': insights.length,
      'activeInsights': activeInsights.length,
      'publicInsights': getInsightsByPrivacyLevel(PrivacyLevel.public).length,
      'personalInsights': getInsightsByPrivacyLevel(PrivacyLevel.personal).length,
      'sensitiveInsights': getInsightsByPrivacyLevel(PrivacyLevel.sensitive).length,
      'confidentialInsights': getInsightsByPrivacyLevel(PrivacyLevel.confidential).length,
      'recentInsights': getRecentInsights().length,
      'lastUpdated': updatedAt.toIso8601String(),
      'isEnabled': isEnabled,
    };
  }

  /// Check if the bio contains enough information to be useful
  bool get hasUsefulInformation {
    return safeInsightsForContext.length >= 3; // Minimum threshold for context
  }

  /// Get the age of the bio in days
  int get ageInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Get the most recent insight
  BiographicalInsight? get mostRecentInsight {
    if (insights.isEmpty) return null;
    return insights.reduce((a, b) => 
        a.extractedAt.isAfter(b.extractedAt) ? a : b
    );
  }

  /// Convert to JSON (including insights)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'insights': insights.map((i) => i.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEnabled': isEnabled,
    };
  }

  /// Create from JSON (including insights)
  factory UserBio.fromJson(Map<String, dynamic> json) {
    return UserBio(
      id: json['id']?.toInt(),
      userId: json['userId'] ?? '',
      insights: (json['insights'] as List<dynamic>?)
          ?.map((i) => BiographicalInsight.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  @override
  String toString() {
    return 'UserBio{id: $id, userId: $userId, insights: ${insights.length}, enabled: $isEnabled, age: $ageInDays days}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserBio &&
        other.id == id &&
        other.userId == userId &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, isEnabled);
  }
}
