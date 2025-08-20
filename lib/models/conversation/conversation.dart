import '../profet_manager.dart';
import '../profet.dart';

/// Enum for conversation status
enum ConversationStatus {
  active,
  completed,
  archived,
}

/// Enum for conversation participants
enum MessageSender {
  user,
  prophet,
}

/// Data model representing a conversation between user and prophet
/// 
/// This model stores conversation metadata and provides access to
/// the complete message history for a conversational interaction
class Conversation {
  final int? id;
  final String title;
  final String prophetType;
  final DateTime startedAt;
  final DateTime lastUpdatedAt;
  final int messageCount;
  final ConversationStatus status;
  final bool isAIEnabled;

  const Conversation({
    this.id,
    required this.title,
    required this.prophetType,
    required this.startedAt,
    required this.lastUpdatedAt,
    required this.messageCount,
    this.status = ConversationStatus.active,
    this.isAIEnabled = false,
  });

  /// Create a copy of the conversation with updated values
  Conversation copyWith({
    int? id,
    String? title,
    String? prophetType,
    DateTime? startedAt,
    DateTime? lastUpdatedAt,
    int? messageCount,
    ConversationStatus? status,
    bool? isAIEnabled,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      prophetType: prophetType ?? this.prophetType,
      startedAt: startedAt ?? this.startedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      messageCount: messageCount ?? this.messageCount,
      status: status ?? this.status,
      isAIEnabled: isAIEnabled ?? this.isAIEnabled,
    );
  }

  /// Convert Conversation to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'prophet_type': prophetType,
      'started_at': startedAt.millisecondsSinceEpoch,
      'last_updated_at': lastUpdatedAt.millisecondsSinceEpoch,
      'message_count': messageCount,
      'status': status.name,
      'is_ai_enabled': isAIEnabled ? 1 : 0,
    };
  }

  /// Create Conversation from database map
  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      prophetType: map['prophet_type'] ?? '',
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at'] ?? 0),
      lastUpdatedAt: DateTime.fromMillisecondsSinceEpoch(map['last_updated_at'] ?? 0),
      messageCount: map['message_count']?.toInt() ?? 0,
      status: ConversationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ConversationStatus.active,
      ),
      isAIEnabled: (map['is_ai_enabled'] ?? 0) == 1,
    );
  }

  /// Convert Conversation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prophetType': prophetType,
      'startedAt': startedAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'messageCount': messageCount,
      'status': status.name,
      'isAIEnabled': isAIEnabled,
    };
  }

  /// Create Conversation from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toInt(),
      title: json['title'] ?? '',
      prophetType: json['prophetType'] ?? '',
      startedAt: DateTime.parse(json['startedAt'] ?? DateTime.now().toIso8601String()),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] ?? DateTime.now().toIso8601String()),
      messageCount: json['messageCount']?.toInt() ?? 0,
      status: ConversationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConversationStatus.active,
      ),
      isAIEnabled: json['isAIEnabled'] ?? false,
    );
  }

  /// Get conversation duration
  Duration get duration => lastUpdatedAt.difference(startedAt);

  /// Get the display name for the prophet type
  String get prophetDisplayName {
    switch (prophetType.toLowerCase()) {
      case 'mystic_prophet':
      case 'mystic':
        return 'The Mystic Oracle';
      case 'chaotic_prophet':
      case 'chaotic':
        return 'The Chaotic Oracle';
      case 'cynical_prophet':
      case 'cynical':
        return 'The Cynical Oracle';
      case 'roaster_prophet':
      case 'roaster':
        return 'The Prophet Who Roasts';
      default:
        return 'Oracle';
    }
  }

  /// Get the image path for the prophet
  String get prophetImagePath {
    switch (prophetType.toLowerCase()) {
      case 'mystic_prophet':
      case 'mystic':
        return 'assets/images/prophets/mystic_prophet.png';
      case 'chaotic_prophet':
      case 'chaotic':
        return 'assets/images/prophets/chaotic_prophet.png';
      case 'cynical_prophet':
      case 'cynical':
        return 'assets/images/prophets/cynical_prophet.png';
      case 'roaster_prophet':
      case 'roaster':
        return 'assets/images/prophets/roaster_prophet.png';
      default:
        return 'assets/images/prophets/mystic_prophet.png';
    }
  }

  /// Get ProfetType enum from the stored string
  ProfetType get prophetTypeEnum {
    return ProfetManager.getProfetTypeFromString(prophetType);
  }

  /// Get Profet instance for this conversation
  Profet get profet {
    return ProfetManager.getProfet(prophetTypeEnum);
  }

  /// Check if conversation is recently active (within last 24 hours)
  bool get isRecentlyActive {
    final now = DateTime.now();
    final difference = now.difference(lastUpdatedAt);
    return difference.inHours < 24;
  }

  /// Get a summary text for the conversation
  String get summary {
    final duration = this.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    String durationText;
    if (hours > 0) {
      durationText = '${hours}h ${minutes}m';
    } else {
      durationText = '${minutes}m';
    }
    
    return '$messageCount messages • $durationText • $prophetDisplayName';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation &&
        other.id == id &&
        other.title == title &&
        other.prophetType == prophetType &&
        other.startedAt == startedAt &&
        other.lastUpdatedAt == lastUpdatedAt &&
        other.messageCount == messageCount &&
        other.status == status &&
        other.isAIEnabled == isAIEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      prophetType,
      startedAt,
      lastUpdatedAt,
      messageCount,
      status,
      isAIEnabled,
    );
  }

  @override
  String toString() {
    return 'Conversation{id: $id, title: $title, prophetType: $prophetType, messageCount: $messageCount, status: $status}';
  }
}
