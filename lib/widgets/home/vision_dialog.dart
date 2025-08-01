import 'package:flutter/material.dart';
import '../../models/profet.dart';
import '../../models/vision_feedback.dart';
import '../../widgets/common/common_widgets.dart';
import '../../utils/theme_utils.dart';
import 'feedback_section.dart';

/// A comprehensive dialog widget for displaying oracle visions and responses.
/// Includes AI indicator, question display, content, feedback section, and action buttons.
class VisionDialog extends StatefulWidget {
  final String title;
  final IconData titleIcon;
  final String content;
  final Profet profet;
  final bool isAIEnabled;
  final String? question;
  final FeedbackType? initialFeedback;
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
    this.initialFeedback,
    required this.onFeedbackSelected,
    required this.onSave,
    required this.onShare,
    required this.onClose,
  });

  @override
  State<VisionDialog> createState() => _VisionDialogState();

  /// Shows the vision dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required IconData titleIcon,
    required String content,
    required Profet profet,
    required bool isAIEnabled,
    String? question,
    FeedbackType? initialFeedback,
    required Function(FeedbackType) onFeedbackSelected,
    required VoidCallback onSave,
    required VoidCallback onShare,
    required VoidCallback onClose,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      barrierColor: Colors.black.withValues(alpha: 0.3), // Much more transparent barrier
      builder: (BuildContext context) {
        return VisionDialog(
          title: title,
          titleIcon: titleIcon,
          content: content,
          profet: profet,
          isAIEnabled: isAIEnabled,
          question: question,
          initialFeedback: initialFeedback,
          onFeedbackSelected: onFeedbackSelected,
          onSave: onSave,
          onShare: onShare,
          onClose: onClose,
        );
      },
    );
  }
}

class _VisionDialogState extends State<VisionDialog> {
  FeedbackType? selectedFeedback;

  @override
  void initState() {
    super.initState();
    // Initialize with the provided initial feedback
    selectedFeedback = widget.initialFeedback;
  }

  void _handleFeedbackSelected(FeedbackType feedbackType) {
    setState(() {
      selectedFeedback = feedbackType;
    });
    // Call the original callback but don't close the dialog
    widget.onFeedbackSelected(feedbackType);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.8; // Increased from 0.7 to 0.8
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: screenHeight * 0.08, // Start higher on screen (8% from top)
        bottom: screenHeight * 0.12, // Keep some space at bottom
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.profet.primaryColor.withValues(alpha: 0.8), width: 2),
        ),
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildTitle(),
            ),
            // Scrollable Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildScrollableContent(context),
              ),
            ),
            // Fixed Action Buttons at bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildActionSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: ThemeUtils.titleStyle.copyWith(
              color: widget.profet.primaryColor,
              fontSize: 16, // Further reduced font size for better fit
            ),
            maxLines: 2, // Allow title to wrap to 2 lines if needed
            overflow: TextOverflow.ellipsis, // Add ellipsis if still too long
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.question != null && widget.question!.isNotEmpty) ...[
            _buildQuestionContainer(),
            const SizedBox(height: 15),
          ],
          _buildContentContainer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Feedback section
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: FeedbackSection.defaultOptions(
            profet: widget.profet,
            onFeedbackSelected: _handleFeedbackSelected,
            context: context,
            selectedFeedback: selectedFeedback,
          ),
        ),
        const SizedBox(height: 8),
        _buildDivider(),
        const SizedBox(height: 8),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildQuestionContainer() {
    return Container(
      padding: ThemeUtils.paddingSM,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.profet.secondaryColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: widget.profet.secondaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"${widget.question}"',
              style: ThemeUtils.bodyStyle.copyWith(
                color: widget.profet.secondaryColor,
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
      primaryColor: widget.profet.primaryColor,
      secondaryColor: widget.profet.secondaryColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 350, // Increased to 350 for better use of space
        ),
        child: SingleChildScrollView(
          child: Text(
            widget.content,
            style: ThemeUtils.bodyStyle.copyWith(
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: widget.profet.primaryColor.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionButton(
              icon: Icons.bookmark_add,
              label: 'Salva',
              color: widget.profet.primaryColor,
              onPressed: widget.onSave,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionButton(
              icon: Icons.share,
              label: 'Condividi',
              color: widget.profet.secondaryColor,
              onPressed: widget.onShare,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionButton(
              icon: Icons.close,
              label: 'Chiudi',
              color: Colors.grey,
              onPressed: widget.onClose,
            ),
          ),
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
