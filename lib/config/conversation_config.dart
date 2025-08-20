/// Configuration class for conversation feature settings
/// This class contains developer-configurable parameters for the conversation system
class ConversationConfig {
  /// Maximum number of conversations that can be stored
  /// When this limit is reached, oldest conversations may be archived or deleted
  static const int maxConversations = 50;
  
  /// Number of message exchanges before showing ad with reward
  /// Maintains consistency with current question-based ad logic
  static const int adIntervalMessages = 5;
  
  /// Maximum number of messages allowed per conversation
  /// Helps prevent extremely long conversations that might impact performance
  static const int maxMessagesPerConversation = 100;
  
  /// Whether conversation persistence is enabled
  /// If false, conversations are session-only
  static const bool enableConversationPersistence = true;
  
  /// Whether real-time bio updates are enabled during conversations
  /// If false, bio analysis happens only at conversation end
  static const bool enableRealTimeBioUpdates = true;
  
  /// Whether to analyze past conversations when loading them
  /// Useful for extracting insights from historical data
  static const bool analyzePastConversations = false;
  
  /// Auto-archive conversations older than this number of days
  /// Set to 0 to disable auto-archiving
  static const int autoArchiveDays = 30;
  
  /// Whether to show typing indicators during AI response generation
  static const bool showTypingIndicators = true;
  
  /// Maximum response time for AI-generated responses (in seconds)
  /// After this timeout, fallback responses are used
  static const int aiResponseTimeoutSeconds = 30;
  
  /// Whether to enable conversation search functionality
  static const bool enableConversationSearch = true;
  
  /// Number of conversations to load per page in Vision Book
  static const int conversationsPerPage = 20;
  
  /// Whether to enable conversation export functionality
  static const bool enableConversationExport = false;

  /// Developer debugging settings
  static const bool enableDebugLogging = true;
  static const bool enablePerformanceMetrics = false;
  
  /// Gets the display name for configuration in debug/admin screens
  static Map<String, dynamic> getConfigurationMap() {
    return {
      'maxConversations': maxConversations,
      'adIntervalMessages': adIntervalMessages,
      'maxMessagesPerConversation': maxMessagesPerConversation,
      'enableConversationPersistence': enableConversationPersistence,
      'enableRealTimeBioUpdates': enableRealTimeBioUpdates,
      'autoArchiveDays': autoArchiveDays,
      'showTypingIndicators': showTypingIndicators,
      'aiResponseTimeoutSeconds': aiResponseTimeoutSeconds,
      'enableConversationSearch': enableConversationSearch,
      'conversationsPerPage': conversationsPerPage,
      'enableConversationExport': enableConversationExport,
      'enableDebugLogging': enableDebugLogging,
      'enablePerformanceMetrics': enablePerformanceMetrics,
    };
  }
  
  /// Validates configuration values
  static bool validateConfiguration() {
    if (maxConversations <= 0) return false;
    if (adIntervalMessages <= 0) return false;
    if (maxMessagesPerConversation <= 0) return false;
    if (aiResponseTimeoutSeconds <= 0) return false;
    if (conversationsPerPage <= 0) return false;
    
    return true;
  }
}
