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
    
    final prophetResponseCount = _questionAdService.prophetResponseCount;
    final prophetResponsesUntilNextAd = _questionAdService.prophetResponsesUntilNextAd;
    final willShowAdOnNextProphetResponse = _questionAdService.willShowAdOnNextProphetResponse;
    
    // Determine which counter is closer to triggering an ad
    final closestToAd = questionsUntilNextAd <= prophetResponsesUntilNextAd ? questionsUntilNextAd : prophetResponsesUntilNextAd;
    final isQuestionCloser = questionsUntilNextAd <= prophetResponsesUntilNextAd;
    
    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: widget.showDetails ? _buildDetailedView(
        questionCount, 
        questionsUntilNextAd, 
        willShowAdNext,
        prophetResponseCount,
        prophetResponsesUntilNextAd,
        willShowAdOnNextProphetResponse
      ) : _buildSimpleView(questionCount, questionsUntilNextAd, prophetResponseCount, prophetResponsesUntilNextAd, closestToAd, isQuestionCloser),
    );
  }
  
  Widget _buildSimpleView(int questionCount, int questionsUntilNextAd, int prophetResponseCount, int prophetResponsesUntilNextAd, int closestToAd, bool isQuestionCloser) {
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
          '$questionCount Q',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.auto_awesome,
          size: 16,
          color: Colors.white54,
        ),
        const SizedBox(width: 4),
        Text(
          '$prophetResponseCount R',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (closestToAd <= 2) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.play_circle_outline,
            size: 14,
            color: Colors.orange,
          ),
          const SizedBox(width: 2),
          Text(
            'Ad in $closestToAd ${isQuestionCloser ? 'Q' : 'R'}',
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
  
  Widget _buildDetailedView(int questionCount, int questionsUntilNextAd, bool willShowAdNext, int prophetResponseCount, int prophetResponsesUntilNextAd, bool willShowAdOnNextProphetResponse) {
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
                'Oracle Activity',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Questions counter
          Row(
            children: [
              Icon(
                Icons.help_outline,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                '$questionCount questions asked',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Prophet responses counter  
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                '$prophetResponseCount prophet responses',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (willShowAdNext || willShowAdOnNextProphetResponse) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    willShowAdNext 
                        ? 'Next question will show ad'
                        : 'Next prophet response will show ad',
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
