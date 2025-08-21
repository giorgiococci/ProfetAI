import 'package:orakl/models/conversation/conversation.dart';

/// Filter criteria for conversations
class ConversationFilter {
  final List<String> prophetTypes;
  final DateTime? startDate;
  final DateTime? endDate;
  final ConversationStatus? status;
  final bool? isAIEnabled;
  final int? minMessageCount;
  final int? maxMessageCount;

  const ConversationFilter({
    this.prophetTypes = const [],
    this.startDate,
    this.endDate,
    this.status,
    this.isAIEnabled,
    this.minMessageCount,
    this.maxMessageCount,
  });

  ConversationFilter copyWith({
    List<String>? prophetTypes,
    DateTime? startDate,
    DateTime? endDate,
    ConversationStatus? status,
    bool? isAIEnabled,
    int? minMessageCount,
    int? maxMessageCount,
  }) {
    return ConversationFilter(
      prophetTypes: prophetTypes ?? this.prophetTypes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      isAIEnabled: isAIEnabled ?? this.isAIEnabled,
      minMessageCount: minMessageCount ?? this.minMessageCount,
      maxMessageCount: maxMessageCount ?? this.maxMessageCount,
    );
  }

  bool get hasActiveFilters =>
      prophetTypes.isNotEmpty ||
      startDate != null ||
      endDate != null ||
      status != null ||
      isAIEnabled != null ||
      minMessageCount != null ||
      maxMessageCount != null;

  void clear() {
    // This would need to be implemented as a method that returns a new filter
    // For now, we'll use copyWith to create a cleared filter
  }

  static ConversationFilter cleared() {
    return const ConversationFilter();
  }
}

/// Enum for conversation sorting options
enum ConversationSortBy {
  dateDesc,
  dateAsc,
  titleAsc,
  titleDesc,
  messageCount,
  prophetType,
}
