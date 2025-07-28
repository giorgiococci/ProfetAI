import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../models/profet.dart';
import '../models/vision_feedback.dart';
import '../services/feedback_service.dart';
import '../l10n/app_localizations.dart';
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

class _HomeScreenState extends State<HomeScreen> 
    with LoadingStateMixin, FormStateMixin {
  final TextEditingController _questionController = TextEditingController();
  late VisionState _visionState;
  late ProphetSelectionState _prophetState;
  String _prophetName = '';

  @override
  void initState() {
    super.initState();
    _visionState = VisionState();
    _prophetState = ProphetSelectionState();
    _prophetState.selectProphet(widget.selectedProfet);
    
    // Load prophet name after first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProphetName();
    });
  }

  Future<void> _loadProphetName() async {
    executeWithLoading(() async {
      final name = await ProphetUtils.getProphetName(context, widget.selectedProfet);
      if (mounted) {
        setState(() {
          _prophetName = name;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profet = ProfetManager.getProfet(widget.selectedProfet);

    return Container(
      decoration: BoxDecoration(
        image: profet.backgroundImagePath != null
            ? DecorationImage(
                image: AssetImage(profet.backgroundImagePath!),
                fit: BoxFit.cover,
                opacity: 0.7,
              )
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: ThemeUtils.paddingLG,
          child: HomeContentWidget(
            selectedProphet: widget.selectedProfet,
            questionController: _questionController,
            prophetName: _prophetName,
            isLoading: isLoading,
            hasError: hasError,
            error: error,
            onAskOracle: _handleAskOracle,
            onListenToOracle: _handleListenToOracle,
          ),
        ),
      ),
    );
  }

  // Handler methods using state utilities
  void _handleAskOracle() {
    final question = _questionController.text.trim();
    final validation = ValidationUtils.validateQuestion(question);
    
    if (validation != null) {
      NotificationUtils.showError(
        context: context,
        message: validation,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    _visionState.setQuestion(question);
    _showVisionDialog(hasQuestion: true, question: question);
  }

  void _handleListenToOracle() {
    _showVisionDialog(hasQuestion: false);
  }

  void _showVisionDialog({bool hasQuestion = false, String? question}) async {
    final profet = ProfetManager.getProfet(widget.selectedProfet);

    _visionState.setLoading(true);
    String content = '';
    bool isAIEnabled = Profet.isAIEnabled;

    try {
      if (hasQuestion && question != null && question.isNotEmpty) {
        if (isAIEnabled) {
          await ProphetLoadingDialog.show(context: context, profet: profet);
          
          if (mounted) {
            content = await profet.getAIPersonalizedResponse(question, context);
          }
          if (mounted) ProphetLoadingDialog.dismiss(context);
        } else {
          if (mounted) {
            content = await profet.getLocalizedPersonalizedResponse(context, question);
          }
        }
      } else {
        if (isAIEnabled) {
          await ProphetLoadingDialog.show(context: context, profet: profet);
          
          if (mounted) {
            content = await profet.getAIRandomVision(context);
          }
          if (mounted) ProphetLoadingDialog.dismiss(context);
        } else {
          if (mounted) {
            final visions = await profet.getLocalizedRandomVisions(context);
            final fallbackText = mounted ? AppLocalizations.of(context)!.oracleSilent : 'Silent...';
            content = visions.isNotEmpty ? visions.first : fallbackText;
          }
        }
      }

      _visionState.setVision(content);
      _visionState.setLoading(false);

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        final title = hasQuestion 
            ? localizations.oracleResponds(_prophetName)
            : localizations.visionOf(_prophetName);
        
        await VisionDialog.show(
          context: context,
          title: title,
          titleIcon: Icons.auto_awesome,
          content: content,
          profet: profet,
          isAIEnabled: isAIEnabled,
          question: question,
          onFeedbackSelected: (feedbackType) {
            if (mounted) {
              _showFeedbackDialog(
                profet: profet,
                feedbackType: feedbackType,
                question: question,
                hasQuestion: hasQuestion,
              );
            }
          },
          onSave: () {
            if (mounted) {
              NotificationUtils.showSaveConfirmation(
                context: context,
                prophetColor: ThemeUtils.getProphetColor(widget.selectedProfet),
              );
            }
          },
          onShare: () {
            if (mounted) {
              NotificationUtils.showShareConfirmation(
                context: context,
                prophetColor: ThemeUtils.getProphetColor(widget.selectedProfet),
              );
            }
          },
          onClose: () {
            if (hasQuestion) {
              _questionController.clear();
              _visionState.clearAll();
            }
          },
        );
      }
    } catch (e) {
      _visionState.setLoading(false);
      if (mounted) {
        NotificationUtils.showError(
          context: context,
          message: 'Error: ${e.toString()}',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _showFeedbackDialog({
    required Profet profet,
    required FeedbackType feedbackType,
    String? question,
    required bool hasQuestion,
  }) async {
    // For now, show a simple confirmation and save the feedback
    final localizations = AppLocalizations.of(context)!;
    String feedbackMessage;
    
    switch (feedbackType) {
      case FeedbackType.positive:
        feedbackMessage = localizations.positiveResponse;
        break;
      case FeedbackType.negative:
        feedbackMessage = localizations.negativeResponse;
        break;
      case FeedbackType.funny:
        feedbackMessage = "Feedback funny ricevuto!"; // Fallback
        break;
    }

    // Save the feedback
    final feedback = VisionFeedback(
      type: feedbackType,
      icon: feedbackType == FeedbackType.positive ? '🌟' : 
            feedbackType == FeedbackType.negative ? '👎' : '😄',
      action: 'Feedback received',
      thematicText: feedbackMessage,
      timestamp: DateTime.now(),
      visionContent: _visionState.currentVision,
      question: question,
    );

    // Save feedback using the service
    final feedbackService = FeedbackService();
    await feedbackService.saveFeedback(feedback);

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback saved: $feedbackMessage'),
          backgroundColor: profet.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Close the vision dialog and clear form if needed
      Navigator.of(context).pop();
      if (hasQuestion) {
        _questionController.clear();
        _visionState.clearAll();
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _visionState.dispose();
    _prophetState.dispose();
    StateUtils.clearAllDebounce(); // Clean up any pending debounce timers
    super.dispose();
  }
}
