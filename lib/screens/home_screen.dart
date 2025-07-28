import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../models/profet.dart';
import '../l10n/app_localizations.dart';
import '../widgets/common/common_widgets.dart';
import '../widgets/home/home_widgets.dart';
import '../widgets/dialogs/dialog_widgets.dart';
import '../utils/utils.dart';

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
    final name = await ProphetUtils.getProphetName(context, widget.selectedProfet);
    if (mounted) {
      setState(() {
        _prophetName = name;
      });
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
                prophetTypeString: ProphetUtils.prophetTypeToString(widget.selectedProfet),
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
                      if (!ValidationUtils.isNotEmpty(question)) {
                        NotificationUtils.showError(
                          context: context,
                          message: localizations.enterQuestionFirst,
                          duration: const Duration(seconds: 2),
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
            prophetName: await ProphetUtils.getProphetName(context, widget.selectedProfet),
            content: content,
            isAIEnabled: isAIEnabled,
            question: question,
          )
        : VisionDialogData.randomVision(
            prophetName: await ProphetUtils.getProphetName(context, widget.selectedProfet),
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
      onFeedbackSelected: (feedbackType) => VisionUtils.handleFeedback(
        context: context,
        profet: profet,
        feedbackType: feedbackType,
        visionContent: content,
        question: question,
        onComplete: () {
          Navigator.of(context).pop();
          if (hasQuestion) _questionController.clear();
        },
      ),
      onSave: () {
        Navigator.of(context).pop();
        NotificationUtils.showSaveConfirmation(
          context: context,
          prophetColor: profet.primaryColor,
        );
      },
      onShare: () {
        Navigator.of(context).pop();
        NotificationUtils.showShareConfirmation(
          context: context,
          prophetColor: profet.secondaryColor,
        );
      },
      onClose: () {
        Navigator.of(context).pop();
        if (hasQuestion) _questionController.clear();
      },
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
