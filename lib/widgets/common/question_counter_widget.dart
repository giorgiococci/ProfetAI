import 'package:flutter/material.dart';
import '../../services/question_ad_service.dart';
import '../../utils/theme_utils.dart';
import '../../utils/app_logger.dart';

/// Widget that displays question count and ad frequency information
/// 
/// Shows users how many questions they've asked and when the next ad will appear
class QuestionCounterWidget extends StatefulWidget {
  final bool showDetails;
  final EdgeInsetsGeometry? padding;
  
  const QuestionCounterWidget({
    super.key,
    this.showDetails = false,
    this.padding,
  });
  
  @override
  State<QuestionCounterWidget> createState() => _QuestionCounterWidgetState();
}

class _QuestionCounterWidgetState extends State<QuestionCounterWidget> {
  final QuestionAdService _questionAdService = QuestionAdService();
  
  @override
  void initState() {
    super.initState();
    _ensureServiceInitialized();
  }
  
  Future<void> _ensureServiceInitialized() async {
    if (!_questionAdService.isInitialized) {
      try {
        await _questionAdService.initialize();
        if (mounted) setState(() {});
      } catch (e) {
        AppLogger.logError('QuestionCounterWidget', 'Failed to initialize service', e);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_questionAdService.isInitialized) {
      return const SizedBox.shrink();
    }
    
    final questionCount = _questionAdService.questionCount;
    final questionsUntilNextAd = _questionAdService.questionsUntilNextAd;
    final willShowAdNext = _questionAdService.willShowAdOnNextQuestion;
    
    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: widget.showDetails ? _buildDetailedView(
        questionCount, 
        questionsUntilNextAd, 
        willShowAdNext
      ) : _buildSimpleView(questionCount, questionsUntilNextAd),
    );
  }
  
  Widget _buildSimpleView(int questionCount, int questionsUntilNextAd) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.help_outline,
          size: 16,
          color: Colors.white54,
        ),
        const SizedBox(width: 4),
        Text(
          '$questionCount questions',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (questionsUntilNextAd <= 2) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.play_circle_outline,
            size: 14,
            color: Colors.orange,
          ),
          const SizedBox(width: 2),
          Text(
            'Ad in $questionsUntilNextAd',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildDetailedView(int questionCount, int questionsUntilNextAd, bool willShowAdNext) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 18,
                color: ThemeUtils.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Oracle Statistics',
                style: TextStyle(
                  color: ThemeUtils.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Question count
          Row(
            children: [
              Icon(
                Icons.help_outline,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                'Questions asked: $questionCount',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Ad info
          Row(
            children: [
              Icon(
                willShowAdNext ? Icons.play_circle_filled : Icons.play_circle_outline,
                size: 16,
                color: willShowAdNext ? Colors.orange : Colors.white54,
              ),
              const SizedBox(width: 6),
              Text(
                willShowAdNext 
                  ? 'Next question shows ad'
                  : 'Ad in $questionsUntilNextAd questions',
                style: TextStyle(
                  color: willShowAdNext ? Colors.orange : Colors.white54,
                  fontSize: 13,
                  fontWeight: willShowAdNext ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          
          if (willShowAdNext) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Watch a short ad to continue',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
