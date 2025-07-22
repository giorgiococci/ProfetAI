import '../models/vision_feedback.dart';

class FeedbackService {
  // For now, we'll use in-memory storage
  // This can be enhanced later with SharedPreferences or other persistent storage
  static final List<VisionFeedback> _feedbacks = [];
  
  // Singleton pattern
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  // Save feedback
  Future<void> saveFeedback(VisionFeedback feedback) async {
    _feedbacks.add(feedback);
    print('Feedback saved: ${feedback.type.name} - ${feedback.thematicText}');
  }

  // Get all feedbacks
  Future<List<VisionFeedback>> getAllFeedbacks() async {
    return List.from(_feedbacks);
  }

  // Get feedback count by type
  Future<Map<FeedbackType, int>> getFeedbackCountByType() async {
    final Map<FeedbackType, int> counts = {
      FeedbackType.positive: 0,
      FeedbackType.negative: 0,
      FeedbackType.funny: 0,
    };

    for (final feedback in _feedbacks) {
      counts[feedback.type] = (counts[feedback.type] ?? 0) + 1;
    }

    return counts;
  }

  // Clear all feedbacks
  Future<void> clearAllFeedbacks() async {
    _feedbacks.clear();
  }

  // Get recent feedbacks (last N)
  Future<List<VisionFeedback>> getRecentFeedbacks(int count) async {
    if (_feedbacks.length <= count) {
      return List.from(_feedbacks);
    }
    return _feedbacks.sublist(_feedbacks.length - count);
  }
}
