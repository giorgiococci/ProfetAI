import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../models/profet.dart';
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
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: ThemeUtils.getProphetGradientDecoration(widget.selectedProfet),
      child: Container(
        decoration: BoxDecoration(
          image: profet.backgroundImagePath != null
              ? DecorationImage(
                  image: AssetImage(profet.backgroundImagePath!),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                )
              : null,
        ),
        child: SafeArea(
          child: Padding(
            padding: ThemeUtils.paddingLG,
            child: Column(
              children: [
                // Prophet Header with theme styling
                Container(
                  decoration: ThemeUtils.getProphetCardDecoration(widget.selectedProfet),
                  padding: ThemeUtils.paddingMD,
                  child: ProphetHeader(
                    profet: profet,
                    prophetTypeString: ProphetUtils.prophetTypeToString(widget.selectedProfet),
                  ),
                ),

                ThemeUtils.spacerLG,

                // Oracle Avatar with loading state
                if (isLoading)
                  Column(
                    children: [
                      CircularProgressIndicator(
                        color: ThemeUtils.getProphetColor(widget.selectedProfet),
                      ),
                      ThemeUtils.spacerSM,
                      Text(
                        'Loading...',
                        style: ThemeUtils.getProphetTextStyle(widget.selectedProfet),
                      ),
                    ],
                  )
                else
                  OracleAvatar(profet: profet),

                ThemeUtils.spacerLG,

                // Question Input Field with theme styling
                Container(
                  decoration: ThemeUtils.getCardDecoration(),
                  padding: ThemeUtils.paddingMD,
                  child: TextFormField(
                    controller: _questionController,
                    decoration: ThemeUtils.getProphetInputDecoration(
                      widget.selectedProfet,
                      labelText: localizations.enterQuestionPlaceholder(
                        _prophetName.isNotEmpty ? _prophetName : 'Oracle'
                      ),
                      prefixIcon: Icons.help_outline,
                    ),
                    maxLines: 3,
                    validator: ValidationUtils.validateQuestion,
                  ),
                ),

                ThemeUtils.spacerXL,

                // Action buttons with theme styling
                Column(
                  children: [
                    // Ask Oracle Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ThemeUtils.getProphetButtonStyle(widget.selectedProfet),
                        onPressed: _handleAskOracle,
                        icon: const Icon(Icons.help_outline),
                        label: Text(
                          localizations.askTheOracle,
                          style: ThemeUtils.buttonTextStyle,
                        ),
                      ),
                    ),

                    ThemeUtils.spacerMD,

                    // Listen to Oracle Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: ThemeUtils.getSecondaryButtonStyle(
                          borderColor: ThemeUtils.getProphetColor(widget.selectedProfet),
                        ),
                        onPressed: _handleListenToOracle,
                        icon: Icon(
                          Icons.hearing,
                          color: ThemeUtils.getProphetColor(widget.selectedProfet),
                        ),
                        label: Text(
                          localizations.listenToOracle,
                          style: ThemeUtils.getProphetTextStyle(widget.selectedProfet),
                        ),
                      ),
                    ),
                  ],
                ),

                // Error display
                if (hasError)
                  Container(
                    margin: ThemeUtils.verticalPaddingMD,
                    padding: ThemeUtils.paddingMD,
                    decoration: ThemeUtils.getCardDecoration(
                      backgroundColor: Colors.red.shade50,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        ThemeUtils.horizontalSpacerSM,
                        Expanded(
                          child: Text(
                            error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),
              ],
            ),
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

      _visionState.setVision(content, aiEnabled: isAIEnabled);
      
    } catch (e) {
      _visionState.setError(e.toString());
      if (mounted) ProphetLoadingDialog.dismiss(context);
      
      // Fallback to localized content
      if (hasQuestion && question != null) {
        if (mounted) {
          content = await profet.getLocalizedPersonalizedResponse(context, question);
        }
      } else {
        if (mounted) {
          final visions = await profet.getLocalizedRandomVisions(context);
          final fallbackText = mounted ? AppLocalizations.of(context)!.oracleSilent : 'Silent...';
          content = visions.isNotEmpty ? visions.first : fallbackText;
        }
      }
      _visionState.setVision(content, aiEnabled: false);
    }

    if (!mounted) return;

    final dialogData = hasQuestion && question != null && question.isNotEmpty
        ? VisionDialogData.questionResponse(
            prophetName: await ProphetUtils.getProphetName(context, widget.selectedProfet),
            content: _visionState.currentVision,
            isAIEnabled: _visionState.isAIEnabled,
            question: question,
          )
        : VisionDialogData.randomVision(
            prophetName: await ProphetUtils.getProphetName(context, widget.selectedProfet),
            content: _visionState.currentVision,
            isAIEnabled: _visionState.isAIEnabled,
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
        visionContent: _visionState.currentVision,
        question: question,
        onComplete: () {
          Navigator.of(context).pop();
          if (hasQuestion) {
            _questionController.clear();
            _visionState.clearAll();
          }
        },
      ),
      onSave: () {
        Navigator.of(context).pop();
        NotificationUtils.showSaveConfirmation(
          context: context,
          prophetColor: ThemeUtils.getProphetColor(widget.selectedProfet),
        );
      },
      onShare: () {
        Navigator.of(context).pop();
        NotificationUtils.showShareConfirmation(
          context: context,
          prophetColor: ThemeUtils.getProphetColor(widget.selectedProfet),
        );
      },
      onClose: () {
        Navigator.of(context).pop();
        if (hasQuestion) {
          _questionController.clear();
          _visionState.clearAll();
        }
      },
    );
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
