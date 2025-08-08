/// Privacy classification levels for user information
/// 
/// This enum defines different levels of privacy sensitivity for
/// biographical information collected from user interactions
enum PrivacyLevel {
  /// Public information that can be freely shared and stored
  /// Examples: general interests, hobbies, public opinions
  public,
  
  /// Personal information that is private but not sensitive
  /// Examples: preferences, personality traits, life goals
  personal,
  
  /// Sensitive information that requires careful handling
  /// Examples: financial status, health issues, family problems
  sensitive,
  
  /// Confidential information that should never be stored
  /// Examples: medical conditions, financial details, precise locations, phone numbers
  confidential,
}

extension PrivacyLevelExtension on PrivacyLevel {
  /// Returns true if this privacy level should be stored in the bio
  bool get canStore {
    switch (this) {
      case PrivacyLevel.public:
      case PrivacyLevel.personal:
        return true;
      case PrivacyLevel.sensitive:
      case PrivacyLevel.confidential:
        return false;
    }
  }
  
  /// Returns true if this privacy level should be used for prophet context
  bool get canUseForContext {
    switch (this) {
      case PrivacyLevel.public:
      case PrivacyLevel.personal:
        return true;
      case PrivacyLevel.sensitive:
      case PrivacyLevel.confidential:
        return false;
    }
  }
  
  /// Returns a human-readable description of the privacy level
  String get description {
    switch (this) {
      case PrivacyLevel.public:
        return 'Public information that can be freely shared';
      case PrivacyLevel.personal:
        return 'Personal information that is private but not sensitive';
      case PrivacyLevel.sensitive:
        return 'Sensitive information that requires careful handling';
      case PrivacyLevel.confidential:
        return 'Confidential information that should never be stored';
    }
  }
  
  /// Returns the display name for the privacy level
  String get displayName {
    switch (this) {
      case PrivacyLevel.public:
        return 'Public';
      case PrivacyLevel.personal:
        return 'Personal';
      case PrivacyLevel.sensitive:
        return 'Sensitive';
      case PrivacyLevel.confidential:
        return 'Confidential';
    }
  }
}
