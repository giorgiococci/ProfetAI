import 'package:flutter/material.dart';
import '../../models/vision_feedback.dart';

/// Widget for displaying and collecting message feedback
/// Allows users to provide feedback on individual conversation messages
class MessageFeedback extends StatefulWidget {
  final FeedbackType? currentFeedback;
  final Function(FeedbackType) onFeedbackChanged;
  final bool isCompact;
  final bool showLabels;
  final Color? accentColor;

  const MessageFeedback({
    super.key,
    this.currentFeedback,
    required this.onFeedbackChanged,
    this.isCompact = false,
    this.showLabels = false,
    this.accentColor,
  });

  @override
  State<MessageFeedback> createState() => _MessageFeedbackState();
}

class _MessageFeedbackState extends State<MessageFeedback>
    with TickerProviderStateMixin {
  
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleFeedbackTap(FeedbackType type) {
    // Animate the selection
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    widget.onFeedbackChanged(type);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactFeedback();
    } else {
      return _buildFullFeedback();
    }
  }

  Widget _buildCompactFeedback() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFeedbackButton(
          emoji: '🌟',
          type: FeedbackType.positive,
          color: Colors.green,
          size: 16,
        ),
        const SizedBox(width: 6),
        _buildFeedbackButton(
          emoji: '🪨',
          type: FeedbackType.negative,
          color: Colors.red,
          size: 16,
        ),
        const SizedBox(width: 6),
        _buildFeedbackButton(
          emoji: '🐸',
          type: FeedbackType.funny,
          color: Colors.orange,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildFullFeedback() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLabels)
            Text(
              'How was this response?',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (widget.showLabels)
            const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFeedbackButtonWithLabel(
                emoji: '🌟',
                label: 'Great',
                type: FeedbackType.positive,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildFeedbackButtonWithLabel(
                emoji: '🪨',
                label: 'Poor',
                type: FeedbackType.negative,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              _buildFeedbackButtonWithLabel(
                emoji: '🐸',
                label: 'Funny',
                type: FeedbackType.funny,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton({
    required String emoji,
    required FeedbackType type,
    required Color color,
    double size = 20,
  }) {
    final isSelected = widget.currentFeedback == type;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () => _handleFeedbackTap(type),
            child: Container(
              padding: EdgeInsets.all(widget.isCompact ? 4 : 6),
              decoration: BoxDecoration(
                color: isSelected 
                    ? color.withValues(alpha: 0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? color
                      : Colors.white.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: size,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackButtonWithLabel({
    required String emoji,
    required String label,
    required FeedbackType type,
    required Color color,
  }) {
    final isSelected = widget.currentFeedback == type;
    
    return GestureDetector(
      onTap: () => _handleFeedbackTap(type),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFeedbackButton(
            emoji: emoji,
            type: type,
            color: color,
            size: 24,
          ),
          if (widget.showLabels) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? color
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple feedback selector for quick feedback collection
class QuickFeedback extends StatelessWidget {
  final Function(FeedbackType) onFeedback;
  final Color? accentColor;

  const QuickFeedback({
    super.key,
    required this.onFeedback,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickButton('🌟', FeedbackType.positive),
          const SizedBox(width: 4),
          _buildQuickButton('🪨', FeedbackType.negative),
          const SizedBox(width: 4),
          _buildQuickButton('🐸', FeedbackType.funny),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String emoji, FeedbackType type) {
    return GestureDetector(
      onTap: () => onFeedback(type),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
