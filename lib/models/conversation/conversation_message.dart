import '../vision_feedback.dart';
import 'conversation.dart';

/// Data model representing a single message within a conversation
/// 
/// This model stores individual messages exchanged between user and prophet,
/// including content, metadata, and feedback information
class ConversationMessage {
  final int? id;
  final int conversationId;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final FeedbackType? feedbackType;
  final bool isAIGenerated;
  final String? metadata; // Additional data like response time, model used, etc.

  const ConversationMessage({
    this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.feedbackType,
    this.isAIGenerated = false,
    this.metadata,
  });

  /// Create a copy of the message with updated values
  ConversationMessage copyWith({
    int? id,
    int? conversationId,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    FeedbackType? feedbackType,
    bool? isAIGenerated,
    String? metadata,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      feedbackType: feedbackType ?? this.feedbackType,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert ConversationMessage to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'content': content,
      'sender': sender.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'feedback_type': feedbackType?.name,
      'is_ai_generated': isAIGenerated ? 1 : 0,
      'metadata': metadata,
    };
  }

  /// Create ConversationMessage from database map
  factory ConversationMessage.fromMap(Map<String, dynamic> map) {
    return ConversationMessage(
      id: map['id']?.toInt(),
      conversationId: map['conversation_id']?.toInt() ?? 0,
      content: map['content'] ?? '',
      sender: MessageSender.values.firstWhere(
        (e) => e.name == map['sender'],
        orElse: () => MessageSender.user,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      feedbackType: map['feedback_type'] != null
          ? FeedbackType.values.firstWhere(
              (e) => e.name == map['feedback_type'],
              orElse: () => FeedbackType.positive,
            )
          : null,
      isAIGenerated: (map['is_ai_generated'] ?? 0) == 1,
      metadata: map['metadata'],
    );
  }

  /// Convert ConversationMessage to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'feedbackType': feedbackType?.name,
      'isAIGenerated': isAIGenerated,
      'metadata': metadata,
    };
  }

  /// Create ConversationMessage from JSON
  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id']?.toInt(),
      conversationId: json['conversationId']?.toInt() ?? 0,
      content: json['content'] ?? '',
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      feedbackType: json['feedbackType'] != null
          ? FeedbackType.values.firstWhere(
              (e) => e.name == json['feedbackType'],
              orElse: () => FeedbackType.positive,
            )
          : null,
      isAIGenerated: json['isAIGenerated'] ?? false,
      metadata: json['metadata'],
    );
  }

  /// Check if this is a user message
  bool get isUserMessage => sender == MessageSender.user;

  /// Check if this is a prophet message
  bool get isProphetMessage => sender == MessageSender.prophet;

  /// Check if feedback has been provided
  bool get hasFeedback => feedbackType != null;

  /// Get the time elapsed since this message
  Duration get timeElapsed => DateTime.now().difference(timestamp);

  /// Check if this message was sent recently (within last 5 minutes)
  bool get isRecentMessage => timeElapsed.inMinutes < 5;

  /// Get formatted timestamp for display
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // Format as MM/dd for older messages
      return '${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}';
    }
  }

  /// Get a short preview of the message content (for list views)
  String get preview {
    const maxLength = 100;
    if (content.length <= maxLength) {
      return content;
    }
    return '${content.substring(0, maxLength)}...';
  }

  /// Create a user message
  factory ConversationMessage.userMessage({
    required int conversationId,
    required String content,
    DateTime? timestamp,
    String? metadata,
  }) {
    return ConversationMessage(
      conversationId: conversationId,
      content: content,
      sender: MessageSender.user,
      timestamp: timestamp ?? DateTime.now(),
      isAIGenerated: false,
      metadata: metadata,
    );
  }

  /// Create a prophet message
  factory ConversationMessage.prophetMessage({
    required int conversationId,
    required String content,
    DateTime? timestamp,
    bool isAIGenerated = false,
    String? metadata,
  }) {
    return ConversationMessage(
      conversationId: conversationId,
      content: content,
      sender: MessageSender.prophet,
      timestamp: timestamp ?? DateTime.now(),
      isAIGenerated: isAIGenerated,
      metadata: metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationMessage &&
        other.id == id &&
        other.conversationId == conversationId &&
        other.content == content &&
        other.sender == sender &&
        other.timestamp == timestamp &&
        other.feedbackType == feedbackType &&
        other.isAIGenerated == isAIGenerated &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      conversationId,
      content,
      sender,
      timestamp,
      feedbackType,
      isAIGenerated,
      metadata,
    );
  }

  @override
  String toString() {
    return 'ConversationMessage{id: $id, conversationId: $conversationId, sender: $sender, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}}';
  }
}
