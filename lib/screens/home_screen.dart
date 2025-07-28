import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../models/profet.dart';
import '../models/vision_feedback.dart';
import '../services/feedback_service.dart';
import '../l10n/app_localizations.dart';
import '../prophet_localizations.dart';
import '../widgets/common/common_widgets.dart';
import '../widgets/home/home_widgets.dart';
import '../widgets/dialogs/dialog_widgets.dart';

class HomeScreen extends StatefulWidget {
  final ProfetType selectedProfet;

  const HomeScreen({
    super.key,
    required this.selectedProfet,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _questionController = TextEditingController();
  String _prophetName = '';

  @override
  void initState() {
    super.initState();
    // Load prophet name after first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProphetName();
    });
  }

  Future<void> _loadProphetName() async {
    final name = await ProphetLocalizations.getName(context, _getProphetTypeString(widget.selectedProfet));
    if (mounted) {
      setState(() {
        _prophetName = name;
      });
    }
  }

  // Helper function to get prophet type string for localization
  String _getProphetTypeString(ProfetType profetType) {
    switch (profetType) {
      case ProfetType.mistico:
        return 'mystic';
      case ProfetType.caotico:
        return 'chaotic';
      case ProfetType.cinico:
        return 'cynical';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profet = ProfetManager.getProfet(widget.selectedProfet);
    final localizations = AppLocalizations.of(context)!;

    return GradientContainer.prophetThemed(
      gradientColors: profet.backgroundGradient,
      backgroundImagePath: profet.backgroundImagePath,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Prophet Header
              ProphetHeader(
                profet: profet,
                prophetTypeString: _getProphetTypeString(widget.selectedProfet),
              ),

              const Spacer(flex: 1),

              // Oracle Avatar
              OracleAvatar(profet: profet),

              const Spacer(flex: 1),

              // Question Input Field
              QuestionInputField(
                controller: _questionController,
                profet: profet,
                hintText: _prophetName.isNotEmpty 
                    ? localizations.enterQuestionPlaceholder(_prophetName)
                    : localizations.enterQuestionPlaceholder('Oracle'),
              ),

              const SizedBox(height: 30),

              // Due bottoni separati per le diverse modalità
              Column(
                children: [
                  // Pulsante "Domanda all'Oracolo"
                  CustomButton.primary(
                    text: localizations.askTheOracle,
                    icon: Icons.help_outline,
                    primaryColor: profet.primaryColor,
                    onPressed: () {
                      final question = _questionController.text.trim();
                      if (question.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(localizations.enterQuestionFirst),
                            backgroundColor: Colors.red[700],
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      _showVisionDialog(hasQuestion: true, question: question);
                    },
                  ),

                  const SizedBox(height: 15),

                  // Pulsante "Ascolta l'Oracolo"
                  CustomButton.outlined(
                    text: localizations.listenToOracle,
                    icon: Icons.hearing,
                    primaryColor: profet.primaryColor,
                    onPressed: () {
                      _showVisionDialog(hasQuestion: false);
                    },
                  ),
                ],
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  void _showVisionDialog({bool hasQuestion = false, String? question}) async {
    final profet = ProfetManager.getProfet(widget.selectedProfet);

    // Determina il contenuto in base alla modalità
    String content = ''; // Initialize to avoid null errors
    bool isAIEnabled = Profet.isAIEnabled; // Check if AI is available

    if (hasQuestion && question != null && question.isNotEmpty) {
      if (isAIEnabled) {
        // Show loading dialog first
        await ProphetLoadingDialog.show(context: context, profet: profet);

        try {
          if (mounted) {
            content = await profet.getAIPersonalizedResponse(question, context);
          }
          if (mounted) ProphetLoadingDialog.dismiss(context); // Close loading dialog - check mounted first
        } catch (e) {
          if (mounted) ProphetLoadingDialog.dismiss(context); // Close loading dialog - check mounted first
          // Use localized fallback response
          if (mounted) {
            content = await profet.getLocalizedPersonalizedResponse(context, question);
            isAIEnabled = false; // Fallback to regular response
          } else {
            return; // Widget is no longer mounted, exit early
          }
        }
      } else {
        // Use localized fallback response when AI is disabled
        if (mounted) {
          content = await profet.getLocalizedPersonalizedResponse(context, question);
        } else {
          return; // Widget is no longer mounted, exit early
        }
      }
    } else {
      if (isAIEnabled) {
        // Show loading dialog first
        await ProphetLoadingDialog.show(context: context, profet: profet);

        try {
          if (mounted) {
            content = await profet.getAIRandomVision(context);
          }
          if (mounted) ProphetLoadingDialog.dismiss(context); // Close loading dialog - check mounted first
        } catch (e) {
          if (mounted) ProphetLoadingDialog.dismiss(context); // Close loading dialog - check mounted first
          // Use localized random visions as fallback
          if (mounted) {
            final visions = await profet.getLocalizedRandomVisions(context);
            final fallbackText = mounted ? AppLocalizations.of(context)!.oracleSilent : 'Silent...';
            content = visions.isNotEmpty ? visions.first : fallbackText;
            isAIEnabled = false; // Fallback to regular response
          } else {
            return; // Widget is no longer mounted, exit early
          }
        }
      } else {
        // Use localized random visions when AI is disabled
        if (mounted) {
          final visions = await profet.getLocalizedRandomVisions(context);
          final fallbackText = mounted ? AppLocalizations.of(context)!.oracleSilent : 'Silent...';
          content = visions.isNotEmpty ? visions.first : fallbackText;
        } else {
          return; // Widget is no longer mounted, exit early
        }
      }
    }

    // Check mounted one more time before showing dialog
    if (!mounted) return;

    final dialogData = hasQuestion && question != null && question.isNotEmpty
        ? VisionDialogData.questionResponse(
            prophetName: await ProphetLocalizations.getName(context, _getProphetTypeString(widget.selectedProfet)),
            content: content,
            isAIEnabled: isAIEnabled,
            question: question,
          )
        : VisionDialogData.randomVision(
            prophetName: await ProphetLocalizations.getName(context, _getProphetTypeString(widget.selectedProfet)),
            content: content,
            isAIEnabled: isAIEnabled,
          );

    await VisionDialog.show(
      context: context,
      title: dialogData.title,
      titleIcon: dialogData.titleIcon,
      content: dialogData.content,
      profet: profet,
      isAIEnabled: dialogData.isAIEnabled,
      question: dialogData.question,
      onFeedbackSelected: (feedbackType) => _handleFeedback(
        context,
        profet,
        feedbackType,
        content,
        question,
      ),
      onSave: () {
        Navigator.of(context).pop();
        _showSavedMessage();
      },
      onShare: () {
        Navigator.of(context).pop();
        _showShareMessage();
      },
      onClose: () {
        Navigator.of(context).pop();
        if (hasQuestion) _questionController.clear();
      },
    );
  }

  void _showSavedMessage() {
    final profet = ProfetManager.getProfet(widget.selectedProfet);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.bookmark_added, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Visione salvata nel Libro delle Visioni',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: profet.primaryColor.withValues(alpha: 0.9),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showShareMessage() {
    final profet = ProfetManager.getProfet(widget.selectedProfet);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.share, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Preparando la condivisione della visione...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: profet.secondaryColor.withValues(alpha: 0.9),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Handle feedback selection
  void _handleFeedback(
    BuildContext context,
    profet,
    FeedbackType feedbackType,
    String visionContent,
    String? question,
  ) async {
    // Create feedback using the prophet's custom localized texts
    final feedback = await profet.createFeedback(
      context,
      type: feedbackType,
      visionContent: visionContent,
      question: question,
    );

    // Save feedback
    await FeedbackService().saveFeedback(feedback);

    // Check mounted before using context
    if (!mounted) return;

    // Close the current dialog
    Navigator.of(context).pop();

    // Show feedback confirmation
    _showFeedbackConfirmation(context, profet, feedback);

    // Clear question if it was a question-based vision
    if (question != null && question.isNotEmpty) {
      _questionController.clear();
    }
  }

  // Show feedback confirmation
  void _showFeedbackConfirmation(
    BuildContext context,
    profet,
    VisionFeedback feedback,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              feedback.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    feedback.action,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    feedback.thematicText,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: profet.primaryColor.withValues(alpha: 0.9),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
