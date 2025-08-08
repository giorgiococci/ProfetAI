/// Source type classification for biographical insights
/// 
/// This enum distinguishes between insights derived from user statements
/// versus those inferred from prophet responses
enum InsightSourceType {
  /// Insights extracted from what the user explicitly said or asked
  /// These represent the user's actual thoughts, interests, and preferences
  user,
  
  /// Insights inferred from prophet responses or system observations
  /// These represent potential user interests based on prophet interactions
  /// but don't necessarily reflect the user's actual views
  prophet,
}

extension InsightSourceTypeExtension on InsightSourceType {
  /// Human-readable name for the source type
  String get displayName {
    switch (this) {
      case InsightSourceType.user:
        return 'User Statement';
      case InsightSourceType.prophet:
        return 'Prophet Interaction';
    }
  }
  
  /// Description of what this source type represents
  String get description {
    switch (this) {
      case InsightSourceType.user:
        return 'Direct insights from user questions and statements';
      case InsightSourceType.prophet:
        return 'Inferred insights from prophet responses and interactions';
    }
  }
  
  /// Whether insights from this source should be used for bio generation
  bool get shouldUseInBio {
    switch (this) {
      case InsightSourceType.user:
        return true; // Always use user insights
      case InsightSourceType.prophet:
        return false; // Don't use prophet insights in main bio
    }
  }
  
  /// Convert to database integer value
  int get dbValue {
    switch (this) {
      case InsightSourceType.user:
        return 0;
      case InsightSourceType.prophet:
        return 1;
    }
  }
}

/// Helper methods for InsightSourceType
class InsightSourceTypeHelper {
  /// Convert from database integer value
  static InsightSourceType fromDbValue(int value) {
    switch (value) {
      case 0:
        return InsightSourceType.user;
      case 1:
        return InsightSourceType.prophet;
      default:
        return InsightSourceType.user; // Default to user for safety
    }
  }
}
