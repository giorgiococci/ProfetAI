import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../models/profet.dart';
import '../models/vision_feedback.dart';
import '../services/vision_integration_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/home/home_widgets.dart';
import '../widgets/dialogs/dialog_widgets.dart';
import '../utils/utils.dart';
import '../utils/app_logger.dart';

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
  final VisionIntegrationService _visionIntegrationService = VisionIntegrationService();
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
    AppLogger.logDebug('HomeScreen', '_showVisionDialog called with hasQuestion=$hasQuestion, question=$question');
    final profet = ProfetManager.getProfet(widget.selectedProfet);

    // Only update vision state if widget is mounted and state is not disposed
    if (mounted) {
      try {
        _visionState.setLoading(true);
      } catch (stateError) {
        AppLogger.logWarning('HomeScreen', 'Vision state already disposed, cannot start vision generation');
        return;
      }
    } else {
      AppLogger.logWarning('HomeScreen', 'Widget not mounted, cannot start vision generation');
      return;
    }
    
    bool isAIEnabled = Profet.isAIEnabled;
    AppLogger.logDebug('HomeScreen', 'isAIEnabled=$isAIEnabled');

    try {
      VisionResult visionResult;
      
      // Show loading dialog for AI-powered visions
      if (isAIEnabled) {
        AppLogger.logDebug('HomeScreen', 'Showing loading dialog');
        await ProphetLoadingDialog.show(context: context, profet: profet);
      }

      AppLogger.logDebug('HomeScreen', 'About to generate vision...');
      // Generate and store vision using integrated service
      if (hasQuestion && question != null && question.isNotEmpty) {
        AppLogger.logDebug('HomeScreen', 'Generating question vision');
        visionResult = await _visionIntegrationService.generateAndStoreQuestionVision(
          context: context,
          profet: profet,
          question: question,
          isAIEnabled: isAIEnabled,
        );
      } else {
        AppLogger.logDebug('HomeScreen', 'Generating random vision');
        visionResult = await _visionIntegrationService.generateAndStoreRandomVision(
          context: context,
          profet: profet,
          isAIEnabled: isAIEnabled,
        );
      }

      AppLogger.logDebug('HomeScreen', 'Vision generated successfully: ${visionResult.content.substring(0, 50)}...');

      // Dismiss loading dialog IMMEDIATELY after successful generation
      if (isAIEnabled) {
        AppLogger.logDebug('HomeScreen', 'Dismissing loading dialog immediately');
        try {
          ProphetLoadingDialog.dismiss(context);
          AppLogger.logDebug('HomeScreen', 'Loading dialog dismissed successfully');
          
          // Double-check that dialog was dismissed
          await Future.delayed(const Duration(milliseconds: 100));
          
        } catch (e) {
          AppLogger.logError('HomeScreen', 'Failed to dismiss loading dialog: $e');
          // Force dismiss by trying multiple approaches
          try {
            Navigator.of(context).pop();
            AppLogger.logDebug('HomeScreen', 'Force dismissed with Navigator.pop()');
          } catch (e2) {
            AppLogger.logError('HomeScreen', 'Force dismiss also failed: $e2');
          }
        }
      }

      // Only update vision state if widget is still mounted and state is not disposed
      if (mounted) {
        try {
          _visionState.setVision(visionResult.content);
          _visionState.setLoading(false);
        } catch (stateError) {
          AppLogger.logWarning('HomeScreen', 'Vision state already disposed, skipping state update');
        }
      }

      // Add a small delay to ensure UI updates properly
      await Future.delayed(const Duration(milliseconds: 50));

      // FORCE SHOW VISION DIALOG - This is the critical part!
      if (mounted) {
        AppLogger.logInfo('HomeScreen', 'FORCE SHOWING VISION DIALOG - Vision: ${visionResult.content.substring(0, 30)}...');
        
        final localizations = AppLocalizations.of(context)!;
        final title = hasQuestion 
            ? localizations.oracleResponds(_prophetName)
            : localizations.visionOf(_prophetName);
        
        try {
          // One final force dismiss before showing vision dialog
          if (isAIEnabled) {
            try {
              ProphetLoadingDialog.dismiss(context);
            } catch (e) {
              // Ignore dismiss errors at this point
            }
            
            try {
              Navigator.of(context).pop();
            } catch (e) {
              // Ignore Navigator errors at this point  
            }
          }
          
          // Wait a bit more to ensure loading dialog is gone
          await Future.delayed(const Duration(milliseconds: 100));
          
          AppLogger.logInfo('HomeScreen', 'Calling VisionDialog.show with title: $title');
          await VisionDialog.show(
            context: context,
            title: title,
            titleIcon: Icons.auto_awesome,
            content: visionResult.content,
            profet: profet,
            isAIEnabled: visionResult.isAIGenerated,
            question: question,
            onFeedbackSelected: (feedbackType) {
              if (mounted && visionResult.visionId != null) {
                _showFeedbackDialog(
                  profet: profet,
                  feedbackType: feedbackType,
                  question: question,
                  hasQuestion: hasQuestion,
                  visionId: visionResult.visionId!,
                );
              }
            },
          onSave: () {
            if (mounted) {
              NotificationUtils.showSaveConfirmation(
                context: context,
                prophetColor: ThemeUtils.getProphetColor(widget.selectedProfet),
                message: 'Vision "${visionResult.title}" saved to Vision Book!',
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
            if (mounted) {
              Navigator.of(context).pop(); // Actually close the dialog
              if (hasQuestion) {
                _questionController.clear();
                try {
                  _visionState.clearAll();
                } catch (stateError) {
                  AppLogger.logWarning('HomeScreen', 'Vision state already disposed, skipping clear operation');
                }
              }
            }
          },
        );
        AppLogger.logDebug('HomeScreen', 'Vision dialog shown successfully');
        } catch (dialogError) {
          AppLogger.logError('HomeScreen', 'Failed to show vision dialog', dialogError);
          if (mounted) {
            NotificationUtils.showError(
              context: context,
              message: 'Failed to show vision: ${dialogError.toString()}',
              duration: const Duration(seconds: 3),
            );
          }
        }
      } else {
        AppLogger.logWarning('HomeScreen', 'Widget unmounted after vision generation, vision stored but dialog not shown');
      }
    } catch (e) {
      AppLogger.logError('HomeScreen', 'Error in _showVisionDialog', e);
      AppLogger.logError('HomeScreen', 'Stack trace: ${StackTrace.current}');
      
      // Always try to dismiss loading dialog on error
      if (isAIEnabled) {
        try {
          ProphetLoadingDialog.dismiss(context);
          AppLogger.logDebug('HomeScreen', 'Loading dialog dismissed after error');
          
          // Also try force dismiss with Navigator
          try {
            Navigator.of(context).pop();
            AppLogger.logDebug('HomeScreen', 'Force dismissed with Navigator after error');
          } catch (navError) {
            AppLogger.logDebug('HomeScreen', 'Navigator force dismiss failed: $navError');
          }
          
        } catch (dismissError) {
          AppLogger.logWarning('HomeScreen', 'Failed to dismiss loading dialog after error: $dismissError');
        }
      }
      
      // Only update vision state if widget is still mounted and state is not disposed
      if (mounted) {
        try {
          _visionState.setLoading(false);
        } catch (stateError) {
          AppLogger.logWarning('HomeScreen', 'Vision state already disposed, skipping state update');
        }
        
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
    required int visionId,
  }) async {
    try {
      // Update the stored vision with feedback
      final success = await _visionIntegrationService.updateVisionFeedback(
        visionId: visionId,
        feedbackType: feedbackType,
      );

      if (success) {
        // Get localized feedback message
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
            feedbackMessage = localizations.funnyResponse;
            break;
        }

        // Show confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Feedback saved: $feedbackMessage'),
              backgroundColor: profet.primaryColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Show error if feedback update failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to save feedback'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors during feedback update
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving feedback: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
