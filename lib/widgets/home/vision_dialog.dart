import 'package:flutter/material.dart';
import '../../models/profet.dart';
import '../../models/vision_feedback.dart';
import '../../widgets/common/common_widgets.dart';
import '../../utils/theme_utils.dart';
import 'feedback_section.dart';

/// A comprehensive dialog widget for displaying oracle visions and responses.
/// Includes AI indicator, question display, content, feedback section, and action buttons.
class VisionDialog extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final String content;
  final Profet profet;
  final bool isAIEnabled;
  final String? question;
  final Function(FeedbackType) onFeedbackSelected;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onClose;

  const VisionDialog({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.content,
    required this.profet,
    required this.isAIEnabled,
    this.question,
    required this.onFeedbackSelected,
    required this.onSave,
    required this.onShare,
    required this.onClose,
  });

  /// Shows the vision dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required IconData titleIcon,
    required String content,
    required Profet profet,
    required bool isAIEnabled,
    String? question,
    required Function(FeedbackType) onFeedbackSelected,
    required VoidCallback onSave,
    required VoidCallback onShare,
    required VoidCallback onClose,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return VisionDialog(
          title: title,
          titleIcon: titleIcon,
          content: content,
          profet: profet,
          isAIEnabled: isAIEnabled,
          question: question,
          onFeedbackSelected: onFeedbackSelected,
          onSave: onSave,
          onShare: onShare,
          onClose: onClose,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: profet.primaryColor.withValues(alpha: 0.8), width: 2),
      ),
      title: _buildTitle(),
      content: _buildContent(),
      actions: [_buildActions(context)],
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(titleIcon, color: profet.primaryColor, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: ThemeUtils.titleStyle.copyWith(
              color: profet.primaryColor,
            ),
          ),
        ),
        if (isAIEnabled) _buildAIIndicator(),
      ],
    );
  }

  Widget _buildAIIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.psychology, color: Colors.blue, size: 12),
          SizedBox(width: 4),
          Text(
            'AI',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question != null && question!.isNotEmpty) ...[
          _buildQuestionContainer(),
          const SizedBox(height: 15),
        ],
        _buildContentContainer(),
      ],
    );
  }

  Widget _buildQuestionContainer() {
    return Container(
      padding: ThemeUtils.paddingSM,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: profet.secondaryColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: profet.secondaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"$question"',
              style: ThemeUtils.bodyStyle.copyWith(
                color: profet.secondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentContainer() {
    return ProphetContentContainer(
      primaryColor: profet.primaryColor,
      secondaryColor: profet.secondaryColor,
      child: Text(
        content,
        style: ThemeUtils.bodyStyle.copyWith(
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        FeedbackSection.defaultOptions(
          profet: profet,
          onFeedbackSelected: onFeedbackSelected,
          context: context,
        ),
        const SizedBox(height: 8),
        _buildDivider(),
        const SizedBox(height: 8),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: profet.primaryColor.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildActionButtons() {
    return ActionButtonsRow(
      buttons: [
        ActionButtonData.save(
          color: profet.primaryColor,
          onPressed: onSave,
        ),
        ActionButtonData.share(
          color: profet.secondaryColor,
          onPressed: onShare,
        ),
        ActionButtonData.close(
          onPressed: onClose,
        ),
      ],
    );
  }
}

/// A simplified version of the vision dialog for quick displays
class SimpleVisionDialog extends StatelessWidget {
  final String title;
  final String content;
  final Profet profet;
  final VoidCallback? onClose;

  const SimpleVisionDialog({
    super.key,
    required this.title,
    required this.content,
    required this.profet,
    this.onClose,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    required Profet profet,
    VoidCallback? onClose,
  }) {
    return ResponsiveDialog.show<void>(
      context: context,
      title: title,
      primaryColor: profet.primaryColor,
      content: ProphetContentContainer(
        primaryColor: profet.primaryColor,
        secondaryColor: profet.secondaryColor,
        child: Text(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose ?? () => Navigator.of(context).pop(),
          child: Text(
            'Chiudi',
            style: TextStyle(
              color: profet.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: title,
      primaryColor: profet.primaryColor,
      content: ProphetContentContainer(
        primaryColor: profet.primaryColor,
        secondaryColor: profet.secondaryColor,
        child: Text(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose ?? () => Navigator.of(context).pop(),
          child: Text(
            'Chiudi',
            style: TextStyle(
              color: profet.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Configuration data for the vision dialog
class VisionDialogData {
  final String title;
  final IconData titleIcon;
  final String content;
  final bool isAIEnabled;
  final String? question;

  const VisionDialogData({
    required this.title,
    required this.titleIcon,
    required this.content,
    required this.isAIEnabled,
    this.question,
  });

  /// Factory for question response dialog
  factory VisionDialogData.questionResponse({
    required String prophetName,
    required String content,
    required bool isAIEnabled,
    required String question,
  }) {
    return VisionDialogData(
      title: '🔮 $prophetName Risponde',
      titleIcon: Icons.psychology_alt,
      content: content,
      isAIEnabled: isAIEnabled,
      question: question,
    );
  }

  /// Factory for random vision dialog
  factory VisionDialogData.randomVision({
    required String prophetName,
    required String content,
    required bool isAIEnabled,
  }) {
    return VisionDialogData(
      title: '✨ Visione di $prophetName',
      titleIcon: Icons.auto_awesome,
      content: content,
      isAIEnabled: isAIEnabled,
    );
  }
}
