import 'package:flutter/material.dart';
import '../../models/profet.dart';
import '../../models/vision_feedback.dart';
import '../../l10n/app_localizations.dart';

/// A widget that displays feedback options for oracle visions.
/// Includes emoji buttons with localized text labels.
class FeedbackSection extends StatelessWidget {
  final Profet profet;
  final Function(FeedbackType) onFeedbackSelected;
  final String title;
  final List<FeedbackButtonData> feedbackOptions;

  const FeedbackSection({
    super.key,
    required this.profet,
    required this.onFeedbackSelected,
    this.title = 'Come è stata questa visione?',
    required this.feedbackOptions,
  });

  /// Factory constructor with default feedback options
  factory FeedbackSection.defaultOptions({
    Key? key,
    required Profet profet,
    required Function(FeedbackType) onFeedbackSelected,
    required BuildContext context,
    String? title,
  }) {
    final localizations = AppLocalizations.of(context)!;
    return FeedbackSection(
      key: key,
      profet: profet,
      onFeedbackSelected: onFeedbackSelected,
      title: title ?? 'Come è stata questa visione?',
      feedbackOptions: [
        FeedbackButtonData(
          type: FeedbackType.positive,
          icon: '🌟',
          label: localizations.feedbackPositiveAction,
        ),
        FeedbackButtonData(
          type: FeedbackType.negative,
          icon: '🪨',
          label: localizations.feedbackNegativeAction,
        ),
        FeedbackButtonData(
          type: FeedbackType.funny,
          icon: '🐸',
          label: localizations.feedbackFunnyAction,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: feedbackOptions.map((option) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FeedbackButton(
                    profet: profet,
                    feedbackData: option,
                    onPressed: () => onFeedbackSelected(option.type),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Individual feedback button widget
class FeedbackButton extends StatelessWidget {
  final Profet profet;
  final FeedbackButtonData feedbackData;
  final VoidCallback onPressed;
  final double iconSize;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const FeedbackButton({
    super.key,
    required this.profet,
    required this.feedbackData,
    required this.onPressed,
    this.iconSize = 20,
    this.fontSize = 9,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: profet.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: profet.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              feedbackData.icon,
              style: TextStyle(fontSize: iconSize),
            ),
            const SizedBox(height: 2),
            Text(
              feedbackData.label,
              style: TextStyle(
                color: profet.primaryColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated feedback button with hover and press effects
class AnimatedFeedbackButton extends StatefulWidget {
  final Profet profet;
  final FeedbackButtonData feedbackData;
  final VoidCallback onPressed;
  final Duration animationDuration;

  const AnimatedFeedbackButton({
    super.key,
    required this.profet,
    required this.feedbackData,
    required this.onPressed,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedFeedbackButton> createState() => _AnimatedFeedbackButtonState();
}

class _AnimatedFeedbackButtonState extends State<AnimatedFeedbackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse().then((_) {
      widget.onPressed();
    });
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: FeedbackButton(
                profet: widget.profet,
                feedbackData: widget.feedbackData,
                onPressed: () {}, // Empty since we handle it in gesture
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Data class for feedback button configuration
class FeedbackButtonData {
  final FeedbackType type;
  final String icon;
  final String label;
  final Color? customColor;

  const FeedbackButtonData({
    required this.type,
    required this.icon,
    required this.label,
    this.customColor,
  });

  /// Factory for positive feedback
  factory FeedbackButtonData.positive(String label) {
    return FeedbackButtonData(
      type: FeedbackType.positive,
      icon: '🌟',
      label: label,
    );
  }

  /// Factory for negative feedback
  factory FeedbackButtonData.negative(String label) {
    return FeedbackButtonData(
      type: FeedbackType.negative,
      icon: '🪨',
      label: label,
    );
  }

  /// Factory for funny feedback
  factory FeedbackButtonData.funny(String label) {
    return FeedbackButtonData(
      type: FeedbackType.funny,
      icon: '🐸',
      label: label,
    );
  }
}

/// A compact feedback section for smaller spaces
class CompactFeedbackSection extends StatelessWidget {
  final Profet profet;
  final Function(FeedbackType) onFeedbackSelected;
  final List<FeedbackButtonData> feedbackOptions;

  const CompactFeedbackSection({
    super.key,
    required this.profet,
    required this.onFeedbackSelected,
    required this.feedbackOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: feedbackOptions.map((option) {
        return GestureDetector(
          onTap: () => onFeedbackSelected(option.type),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: profet.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: profet.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              option.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      }).toList(),
    );
  }
}
