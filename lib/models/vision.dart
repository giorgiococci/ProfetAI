import 'vision_feedback.dart';

/// Enum for sorting options in vision list
enum VisionSortBy {
  dateDesc,
  dateAsc,
  titleAsc,
  titleDesc,
  prophetType,
}

/// Data model representing a stored vision from the oracles
/// 
/// This model stores complete vision information including the question,
/// answer, prophet details, feedback, and AI-generated title
class Vision {
  final int? id;
  final String title;
  final String? question;
  final String answer;
  final String prophetType;
  final FeedbackType? feedbackType;
  final DateTime timestamp;
  final bool isAIGenerated;

  const Vision({
    this.id,
    required this.title,
    this.question,
    required this.answer,
    required this.prophetType,
    this.feedbackType,
    required this.timestamp,
    this.isAIGenerated = false,
  });

  /// Create a copy of the vision with updated values
  Vision copyWith({
    int? id,
    String? title,
    String? question,
    String? answer,
    String? prophetType,
    FeedbackType? feedbackType,
    DateTime? timestamp,
    bool? isAIGenerated,
  }) {
    return Vision(
      id: id ?? this.id,
      title: title ?? this.title,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      prophetType: prophetType ?? this.prophetType,
      feedbackType: feedbackType ?? this.feedbackType,
      timestamp: timestamp ?? this.timestamp,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
    );
  }

  /// Convert Vision to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'question': question,
      'answer': answer,
      'prophet_type': prophetType,
      'feedback_type': feedbackType?.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_ai_generated': isAIGenerated ? 1 : 0,
    };
  }

  /// Create Vision from database map
  factory Vision.fromMap(Map<String, dynamic> map) {
    return Vision(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      question: map['question'],
      answer: map['answer'] ?? '',
      prophetType: map['prophet_type'] ?? '',
      feedbackType: map['feedback_type'] != null
          ? FeedbackType.values.firstWhere(
              (e) => e.name == map['feedback_type'],
              orElse: () => FeedbackType.positive,
            )
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isAIGenerated: (map['is_ai_generated'] ?? 0) == 1,
    );
  }

  /// Convert Vision to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'question': question,
      'answer': answer,
      'prophetType': prophetType,
      'feedbackType': feedbackType?.name,
      'timestamp': timestamp.toIso8601String(),
      'isAIGenerated': isAIGenerated,
    };
  }

  /// Create Vision from JSON
  factory Vision.fromJson(Map<String, dynamic> json) {
    return Vision(
      id: json['id']?.toInt(),
      title: json['title'] ?? '',
      question: json['question'],
      answer: json['answer'] ?? '',
      prophetType: json['prophetType'] ?? '',
      feedbackType: json['feedbackType'] != null
          ? FeedbackType.values.firstWhere(
              (e) => e.name == json['feedbackType'],
              orElse: () => FeedbackType.positive,
            )
          : null,
      timestamp: DateTime.parse(json['timestamp']),
      isAIGenerated: json['isAIGenerated'] ?? false,
    );
  }

  /// Check if this vision has a question (vs being a random vision)
  bool get hasQuestion => question != null && question!.trim().isNotEmpty;

  /// Get a preview of the answer content (truncated for list display)
  String getAnswerPreview({int maxLength = 100}) {
    if (answer.length <= maxLength) {
      return answer;
    }
    return '${answer.substring(0, maxLength)}...';
  }

  /// Get a display-friendly prophet name
  String get prophetDisplayName {
    switch (prophetType.toLowerCase()) {
      case 'mystic_prophet':
      case 'mistico':
        return 'Mystic Oracle';
      case 'chaotic_prophet':
      case 'caotico':
        return 'Chaotic Oracle';
      case 'cynical_prophet':
      case 'cinico':
        return 'Cynical Oracle';
      default:
        return 'Oracle';
    }
  }

  /// Get the prophet image path for display
  String get prophetImagePath {
    switch (prophetType.toLowerCase()) {
      case 'mystic_prophet':
      case 'mistico':
        return 'assets/images/prophets/mystic_prophet.png';
      case 'chaotic_prophet':
      case 'caotico':
        return 'assets/images/prophets/chaotic_prophet.png';
      case 'cynical_prophet':
      case 'cinico':
        return 'assets/images/prophets/cynical_prophet.png';
      default:
        return 'assets/images/prophets/mystic_prophet.png';
    }
  }

  @override
  String toString() {
    return 'Vision{id: $id, title: $title, prophetType: $prophetType, hasQuestion: $hasQuestion, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vision &&
        other.id == id &&
        other.title == title &&
        other.question == question &&
        other.answer == answer &&
        other.prophetType == prophetType &&
        other.feedbackType == feedbackType &&
        other.timestamp == timestamp &&
        other.isAIGenerated == isAIGenerated;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      question,
      answer,
      prophetType,
      feedbackType,
      timestamp,
      isAIGenerated,
    );
  }
}

/// Filter criteria for vision queries
class VisionFilter {
  final Set<String> prophetTypes;
  final Set<FeedbackType> feedbackTypes;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final bool? hasQuestion;
  final VisionSortBy sortBy;

  const VisionFilter({
    this.prophetTypes = const {},
    this.feedbackTypes = const {},
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.hasQuestion,
    this.sortBy = VisionSortBy.dateDesc,
  });

  /// Create a copy with updated filter values
  VisionFilter copyWith({
    Set<String>? prophetTypes,
    Set<FeedbackType>? feedbackTypes,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool? hasQuestion,
    VisionSortBy? sortBy,
  }) {
    return VisionFilter(
      prophetTypes: prophetTypes ?? this.prophetTypes,
      feedbackTypes: feedbackTypes ?? this.feedbackTypes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
      hasQuestion: hasQuestion ?? this.hasQuestion,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return prophetTypes.isNotEmpty ||
        feedbackTypes.isNotEmpty ||
        startDate != null ||
        endDate != null ||
        (searchQuery != null && searchQuery!.isNotEmpty) ||
        hasQuestion != null ||
        sortBy != VisionSortBy.dateDesc;
  }

  /// Clear all filters
  VisionFilter clear() {
    return const VisionFilter();
  }
}
