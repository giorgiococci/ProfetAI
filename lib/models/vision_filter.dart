import 'package:profet_ai/models/vision_feedback.dart';

/// Enum for sorting options in vision list
enum VisionSortBy {
  dateDesc,
  dateAsc,
  titleAsc,
  titleDesc,
  prophetType,
}

/// Filter and sorting configuration for vision list
class VisionFilter {
  final Set<String> prophetTypes;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<FeedbackType> feedbackTypes;
  final bool? hasQuestion;
  final VisionSortBy sortBy;

  const VisionFilter({
    this.prophetTypes = const {},
    this.startDate,
    this.endDate,
    this.feedbackTypes = const {},
    this.hasQuestion,
    this.sortBy = VisionSortBy.dateDesc,
  });

  /// Check if any filters are currently active
  bool get hasActiveFilters {
    return prophetTypes.isNotEmpty ||
           startDate != null ||
           endDate != null ||
           feedbackTypes.isNotEmpty ||
           hasQuestion != null ||
           sortBy != VisionSortBy.dateDesc;
  }

  /// Create a copy of the filter with updated values
  VisionFilter copyWith({
    Set<String>? prophetTypes,
    DateTime? startDate,
    DateTime? endDate,
    Set<FeedbackType>? feedbackTypes,
    bool? hasQuestion,
    VisionSortBy? sortBy,
  }) {
    return VisionFilter(
      prophetTypes: prophetTypes ?? this.prophetTypes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      feedbackTypes: feedbackTypes ?? this.feedbackTypes,
      hasQuestion: hasQuestion ?? this.hasQuestion,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Create a filter with cleared values
  VisionFilter clear() {
    return const VisionFilter();
  }

  @override
  String toString() {
    return 'VisionFilter(prophetTypes: $prophetTypes, startDate: $startDate, '
           'endDate: $endDate, feedbackTypes: $feedbackTypes, '
           'hasQuestion: $hasQuestion, sortBy: $sortBy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is VisionFilter &&
           other.prophetTypes == prophetTypes &&
           other.startDate == startDate &&
           other.endDate == endDate &&
           other.feedbackTypes == feedbackTypes &&
           other.hasQuestion == hasQuestion &&
           other.sortBy == sortBy;
  }

  @override
  int get hashCode {
    return prophetTypes.hashCode ^
           startDate.hashCode ^
           endDate.hashCode ^
           feedbackTypes.hashCode ^
           hasQuestion.hashCode ^
           sortBy.hashCode;
  }
}
