import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../services/question_ad_service.dart';
import '../widgets/home/home_widgets.dart';
import '../utils/utils.dart';
import '../utils/app_logger.dart';

class HomeScreen extends StatefulWidget {
  final ProfetType selectedProfet;
  final int? conversationToLoad;
  final VoidCallback? onConversationLoaded;

  const HomeScreen({
    super.key,
    required this.selectedProfet,
    this.conversationToLoad,
    this.onConversationLoaded,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with LoadingStateMixin, FormStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final QuestionAdService _questionAdService = QuestionAdService();
  
  late VisionState _visionState;
  late ProphetSelectionState _prophetState;
  
  String _prophetName = '';
  bool _isConversationStarted = false;

  @override
  void initState() {
    super.initState();
    _visionState = VisionState();
    _prophetState = ProphetSelectionState();
    _prophetState.selectProphet(widget.selectedProfet);
    
    // Initialize ad service
    _initializeAdService();
    
    // Load prophet name after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProphetName();
      
      // Do NOT set _isConversationStarted for existing conversations
      // The HomeContentWidget will handle autoLoadConversationId directly
      // _isConversationStarted is only for NEW conversations from user input
    });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If conversation to load changed, do NOT set _isConversationStarted
    // The conversation will be loaded via autoLoadConversationId parameter
    if (widget.conversationToLoad != oldWidget.conversationToLoad) {
      // The HomeContentWidget will handle loading via autoLoadConversationId
      // No need to set _isConversationStarted as that's for NEW conversations
      AppLogger.logInfo('HomeScreen', 'Conversation to load changed to: ${widget.conversationToLoad}');
    }
  }

  /// Initialize the ad service for question tracking
  Future<void> _initializeAdService() async {
    try {
      await _questionAdService.initialize();
      AppLogger.logInfo('HomeScreen', 'Ad service initialized successfully');
    } catch (e) {
      AppLogger.logError('HomeScreen', 'Failed to initialize ad service', e);
      // Continue without ads if initialization fails
    }
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

  /// Handle asking the oracle and start conversation mode
  void _handleAskOracle() {
    // Check if question is not empty
    if (_questionController.text.trim().isNotEmpty) {
      setState(() {
        _isConversationStarted = true;
      });
      AppLogger.logInfo('HomeScreen', 'Conversation mode started with question: ${_questionController.text.substring(0, _questionController.text.length > 20 ? 20 : _questionController.text.length)}...');
    }
  }

  /// Reset to home screen from conversation
  void _handleResetToHome() {
    setState(() {
      _isConversationStarted = false;
    });
    // Clear the question controller
    _questionController.clear();
    AppLogger.logInfo('HomeScreen', 'Reset to home screen from conversation');
  }

  @override
  Widget build(BuildContext context) {
    final profet = ProfetManager.getProfet(widget.selectedProfet);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height,
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
          bottom: false,
          child: Padding(
            padding: ThemeUtils.paddingLG,
            child: HomeContentWidget(
              selectedProphet: widget.selectedProfet,
              prophetName: _prophetName,
              isLoading: isLoading,
              hasError: hasError,
              error: error,
              questionController: _questionController,
              onAskOracle: _handleAskOracle,
              onListenToOracle: _handleListenToOracle,
              isConversationStarted: _isConversationStarted,
              initialQuestion: _isConversationStarted ? _questionController.text.trim() : null,
              onResetToHome: _handleResetToHome,
              autoLoadConversationId: widget.conversationToLoad,
              onConversationLoaded: widget.onConversationLoaded,
            ),
          ),
        ),
      ),
    );
  }

  void _handleListenToOracle() async {
    AppLogger.logInfo('HomeScreen', '🎧 _handleListenToOracle called');
    
    // Remove focus from textbox before starting conversation
    FocusScope.of(context).unfocus();
    
    // Handle question with unified ad/cooldown logic
    try {
      AppLogger.logInfo('HomeScreen', '🎯 About to call handleUserQuestion for listen mode');
      final canProceed = await _questionAdService.handleUserQuestion(context);
      AppLogger.logInfo('HomeScreen', '✅ handleUserQuestion result: $canProceed');
      if (!canProceed) {
        AppLogger.logInfo('HomeScreen', '❌ Listen action blocked - user chose to wait');
        return;
      }
      AppLogger.logInfo('HomeScreen', '✅ Listen action approved - starting conversation');
    } catch (e) {
      AppLogger.logError('HomeScreen', 'Error in listen mode handling', e);
      // Continue with conversation even if ad/cooldown logic fails
    }

    // Start conversation without user question (oracle speaks first)
    setState(() {
      _isConversationStarted = true;
    });
    AppLogger.logInfo('HomeScreen', 'Conversation mode started via Listen to Oracle');
  }

  @override
  void dispose() {
    _questionController.dispose();
    _visionState.dispose();
    _prophetState.dispose();
    StateUtils.clearAllDebounce();
    super.dispose();
  }
}
