import 'package:flutter/material.dart';
import '../../models/profet_manager.dart';
import '../../models/conversation/conversation.dart';
import '../../models/conversation/conversation_message.dart';
import '../../models/vision_feedback.dart';
import '../../services/conversation/conversation_integration_service.dart';
import '../../services/vision_integration_service.dart';
import '../../models/profet.dart';
import '../../utils/utils.dart';
import '../../utils/app_logger.dart';
import '../../l10n/app_localizations.dart';
import '../conversation/message_bubble.dart';
import 'prophet_header.dart';
import 'oracle_avatar.dart';
import 'loading_state_widget.dart';
import 'error_display_widget.dart';

/// The main content widget for the home screen.
/// Combines all home screen elements and conversation functionality in one unified widget.
class HomeContentWidget extends StatefulWidget {
  final ProfetType selectedProphet;
  final TextEditingController questionController;
  final String prophetName;
  final bool isLoading;
  final bool hasError;
  final String? error;
  final VoidCallback onAskOracle;
  final VoidCallback onListenToOracle;
  final VoidCallback? onResetToHome;
  final bool isConversationStarted;
  final String? initialQuestion;
  final int? autoLoadConversationId;
  final VoidCallback? onConversationLoaded;

  const HomeContentWidget({
    super.key,
    required this.selectedProphet,
    required this.questionController,
    required this.prophetName,
    required this.isLoading,
    required this.hasError,
    this.error,
    required this.onAskOracle,
    required this.onListenToOracle,
    this.onResetToHome,
    this.isConversationStarted = false,
    this.initialQuestion,
    this.autoLoadConversationId,
    this.onConversationLoaded,
  });

  @override
  State<HomeContentWidget> createState() => _HomeContentWidgetState();
}

class _HomeContentWidgetState extends State<HomeContentWidget> 
    with TickerProviderStateMixin {
  bool _isQuestionEmpty = true;
  
  // Conversation state
  final ConversationIntegrationService _conversationService = ConversationIntegrationService();
  final VisionIntegrationService _visionService = VisionIntegrationService();
  final ScrollController _scrollController = ScrollController();
  Conversation? _currentConversation;
  List<ConversationMessage> _messages = [];
  bool _isConversationLoading = false;
  bool _isSendingMessage = false;
  
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isQuestionEmpty = widget.questionController.text.trim().isEmpty;
    widget.questionController.addListener(_onTextChanged);
    
    // Initialize animations
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to conversation updates
    _conversationService.messagesStream.listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    });
    
    _conversationService.conversationStream.listen((conversation) {
      if (mounted) {
        setState(() {
          _currentConversation = conversation;
        });
      }
    });
    
    // Single initialization path based on parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversation();
    });
  }

  /// Single, clear initialization method based on widget parameters
  Future<void> _initializeConversation() async {
    // Clear any existing conversation state first
    if (_conversationService.hasActiveConversation) {
      print('DEBUG: Clearing existing conversation state');
      // Note: We might want to add a method to clear state without ending conversation
    }
    
    if (widget.autoLoadConversationId != null && widget.autoLoadConversationId! > 0) {
      // Path 1: Load specific conversation by ID (only positive IDs are valid conversations)
      print('DEBUG: Loading specific conversation ID: ${widget.autoLoadConversationId}');
      await _loadExistingConversation(widget.autoLoadConversationId!);
    } else if (widget.isConversationStarted) {
      // Path 2: Start new conversation
      print('DEBUG: Starting new conversation');
      await _startConversation();
    } else {
      // Path 3: Ready state - no conversation
      print('DEBUG: Ready state - no conversation to load');
    }
  }

  @override
  void didUpdateWidget(HomeContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle conversation parameter changes
    if (widget.autoLoadConversationId != oldWidget.autoLoadConversationId) {
      print('DEBUG: autoLoadConversationId changed from ${oldWidget.autoLoadConversationId} to ${widget.autoLoadConversationId}');
      if (widget.autoLoadConversationId != null) {
        if (widget.autoLoadConversationId == -1) {
          // Special flag to reset to home
          print('DEBUG: Resetting conversation state to home (explicit home button click)');
          _resetToHomeState();
        } else {
          // Normal conversation loading
          _initializeConversation();
        }
      }
    }
    
    // Handle new conversation start (only for NEW conversations, not loading existing ones)
    if (widget.isConversationStarted && !oldWidget.isConversationStarted && widget.autoLoadConversationId == null) {
      print('DEBUG: isConversationStarted changed to true for NEW conversation');
      _initializeConversation();
    }
  }

  @override
  void dispose() {
    widget.questionController.removeListener(_onTextChanged);
    _fadeAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Reset conversation state back to home
  void _resetToHomeState() {
    print('DEBUG: Resetting conversation state to home');
    
    // Schedule the reset after the current build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentConversation = null;
        _messages = [];
        _isConversationLoading = false;
        _isSendingMessage = false;
      });
      
      // Reset animation
      _fadeAnimationController.reset();
      
      // Call parent reset if available
      widget.onResetToHome?.call();
      
      print('DEBUG: Conversation state reset to home');
    });
  }

  void _onTextChanged() {
    final isEmpty = widget.questionController.text.trim().isEmpty;
    if (_isQuestionEmpty != isEmpty) {
      setState(() {
        _isQuestionEmpty = isEmpty;
      });
    }
  }
  
  Future<void> _startConversation() async {
    setState(() {
      _isConversationLoading = true;
    });

    try {
      // Start a new conversation
      AppLogger.logInfo('HomeContentWidget', 'Starting new conversation with ${widget.selectedProphet}');
      
      _currentConversation = await _conversationService.startConversation(
        context: context,
        prophetType: widget.selectedProphet,
        isAIEnabled: true,
      );
      
      // Get messages using the current messages from service
      _messages = _conversationService.currentMessages;
      
      AppLogger.logInfo('HomeContentWidget', 'New conversation started with ${_messages.length} messages');
      
      // If there's an initial question, send it automatically
      if (widget.initialQuestion != null && widget.initialQuestion!.trim().isNotEmpty) {
        AppLogger.logInfo('HomeContentWidget', 'Sending initial question: ${widget.initialQuestion!.substring(0, widget.initialQuestion!.length > 20 ? 20 : widget.initialQuestion!.length)}...');
        await _sendMessage(widget.initialQuestion!);
      } else {
        // If no initial question (Listen to Oracle), trigger prophet to speak first without showing user message
        AppLogger.logInfo('HomeContentWidget', 'No initial question - triggering prophet to speak first');
        await _triggerProphetFirstMessage();
      }
      
      // Start fade in animation
      _fadeAnimationController.forward();
      
    } catch (e) {
      AppLogger.logError('HomeContentWidget', 'Failed to start conversation', e);
      _showErrorSnackBar('Failed to start conversation. Please try again.');
    } finally {
      setState(() {
        _isConversationLoading = false;
      });
    }
  }
  
  /// Load an existing conversation by ID
  Future<void> _loadExistingConversation(int conversationId) async {
    try {
      print('DEBUG: Loading conversation ID: $conversationId');
      
      setState(() {
        _isConversationLoading = true;
      });
      
      // Load conversation through integration service
      await _conversationService.loadConversation(
        context: context,
        conversationId: conversationId,
      );
      
      // Verify the conversation was loaded correctly
      final loadedConversation = _conversationService.currentConversation;
      final loadedMessages = _conversationService.currentMessages;
      
      if (loadedConversation != null && loadedConversation.id == conversationId) {
        // Update state with loaded conversation
        setState(() {
          _currentConversation = loadedConversation;
          _messages = loadedMessages;
          _isConversationLoading = false;
        });
        
        // Start fade in animation
        _fadeAnimationController.forward();
        
        // Scroll to bottom to show latest messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        
        print('DEBUG: Conversation loaded successfully - ${loadedConversation.title}, ${_messages.length} messages');
        
        // Notify parent that conversation was loaded successfully
        widget.onConversationLoaded?.call();
      } else {
        throw Exception('Loaded conversation ID ${loadedConversation?.id} does not match requested ID $conversationId');
      }
      
    } catch (e) {
      AppLogger.logError('HomeContentWidget', 'Failed to load conversation', e);
      _showErrorSnackBar('Failed to load conversation. Please try again.');
      print('ERROR: Failed to load conversation $conversationId: $e');
      
      setState(() {
        _isConversationLoading = false;
      });
    }
  }
  
  Future<void> _triggerProphetFirstMessage() async {
    if (_currentConversation == null || _isSendingMessage) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final profet = ProfetManager.getProfet(widget.selectedProphet);
      
      // Generate a proper oracle vision using the VisionIntegrationService
      AppLogger.logInfo('HomeContentWidget', 'Generating oracle vision for Listen to Oracle');
      final visionResult = await _visionService.generateAndStoreRandomVision(
        context: context,
        profet: profet,
        isAIEnabled: Profet.isAIEnabled,
      );
      
      print('DEBUG: Saving prophet message to conversation ${_currentConversation!.id}');
      
      // Save the prophet message directly to the conversation using the integration service
      // This ensures the message is properly persisted to the database
      final prophetMessage = await _conversationService.addDirectProphetMessage(
        content: visionResult.content,
        isAIGenerated: visionResult.isAIGenerated,
        metadata: 'oracle_vision',
        userId: 'default_user', // Add userId parameter for bio analysis
      );
      
      print('DEBUG: Prophet message saved successfully with ID: ${prophetMessage.id}');
      
      // Update local state from the conversation service (which is now in sync)
      setState(() {
        _messages = _conversationService.currentMessages;
      });
      
      // Clear the input controller
      widget.questionController.clear();
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
    } catch (e) {
      AppLogger.logError('HomeContentWidget', 'Failed to generate oracle vision', e);
      _showErrorSnackBar('Failed to receive oracle vision. Please try again.');
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_currentConversation == null || _isSendingMessage) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      await _conversationService.sendMessage(
        context: context,
        content: message,
      );
      
      // Update messages from service
      _messages = _conversationService.currentMessages;
      
      // Clear input if it matches the sent message
      if (widget.questionController.text.trim() == message) {
        widget.questionController.clear();
      }
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
    } catch (e) {
      AppLogger.logError('HomeContentWidget', 'Failed to send message', e);
      _showErrorSnackBar('Failed to send message. Please try again.');
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final profet = ProfetManager.getProfet(widget.selectedProphet);
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          // Main content area - shows prophet content OR conversation messages
          Expanded(
            child: (widget.isConversationStarted || _currentConversation != null)
                ? _buildConversationArea(profet)
                : _buildProphetContent(profet, localizations, isSmallScreen),
          ),
          
          // Bottom input area (always visible)
          _buildBottomInput(profet, localizations),
        ],
      ),
    );
  }

  Widget _buildProphetContent(dynamic profet, AppLocalizations localizations, bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Prophet Header
          ProphetHeader(
            profet: profet,
            prophetTypeString: ProphetUtils.prophetTypeToString(widget.selectedProphet),
          ),

          isSmallScreen ? ThemeUtils.spacerMD : ThemeUtils.spacerLG,

          // Oracle Avatar with loading state
          if (widget.isLoading)
            LoadingStateWidget(selectedProphet: widget.selectedProphet)
          else
            OracleAvatar(profet: profet),

          // Listen to Oracle Button (below the oracle image)
          isSmallScreen ? ThemeUtils.spacerMD : ThemeUtils.spacerLG,
          
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: OutlinedButton.icon(
                onPressed: widget.onListenToOracle,
                icon: const Icon(Icons.hearing),
                label: Text(localizations.listenToOracle),
                style: OutlinedButton.styleFrom(
                  foregroundColor: profet.primaryColor,
                  side: BorderSide(color: profet.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          // Error display
          if (widget.hasError && widget.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ErrorDisplayWidget(errorMessage: widget.error!),
            ),

          // Bottom spacing
          isSmallScreen ? ThemeUtils.spacerLG : ThemeUtils.spacerXL,
        ],
      ),
    );
  }

  Widget _buildConversationArea(dynamic profet) {
    if (_isConversationLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Header without back button
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              _currentConversation?.title ?? 'Conversation with ${profet.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: MessageBubble(
                    message: message,
                    prophetType: widget.selectedProphet,
                    prophetImagePath: ProfetManager.getProfet(widget.selectedProphet).profetImagePath,
                    onFeedbackUpdate: message.isProphetMessage ? (feedbackType) => _updateMessageFeedback(message, feedbackType) : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInput(dynamic profet, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: widget.questionController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.isConversationStarted 
                        ? localizations.typeYourMessage
                        : localizations.enterQuestionPlaceholder(
                            widget.prophetName.isNotEmpty ? widget.prophetName : 'Oracle'
                          ),
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    suffixIcon: _isQuestionEmpty 
                        ? null 
                        : IconButton(
                            onPressed: (widget.isConversationStarted || _currentConversation != null)
                                ? () => _sendMessage(widget.questionController.text.trim())
                                : widget.onAskOracle,
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: (widget.isConversationStarted || _currentConversation != null)
                                ? 'Send Message' 
                                : 'Start Conversation',
                          ),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _isQuestionEmpty 
                      ? null 
                      : (widget.isConversationStarted || _currentConversation != null)
                          ? (text) => _sendMessage(text.trim())
                          : (_) => widget.onAskOracle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Update feedback for a specific message
  Future<void> _updateMessageFeedback(ConversationMessage message, FeedbackType feedbackType) async {
    if (message.id == null) return;
    
    try {
      AppLogger.logInfo('HomeContentWidget', 'Updating feedback for message ${message.id}');
      
      // Update feedback through conversation service
      await _conversationService.updateMessageFeedback(
        messageId: message.id!,
        feedbackType: feedbackType,
      );
      
      // Update local state with the latest messages
      setState(() {
        _messages = _conversationService.currentMessages;
      });
      
      // Show confirmation to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(_getFeedbackEmoji(feedbackType)),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.feedbackUpdated),
              ],
            ),
            backgroundColor: _getFeedbackColor(feedbackType).withValues(alpha: 0.8),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
    } catch (e) {
      AppLogger.logError('HomeContentWidget', 'Failed to update feedback', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToUpdateFeedback(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Get emoji for feedback type
  String _getFeedbackEmoji(FeedbackType feedbackType) {
    switch (feedbackType) {
      case FeedbackType.positive:
        return '👍';
      case FeedbackType.negative:
        return '👎';
      case FeedbackType.funny:
        return '�';
    }
  }

  /// Get color for feedback type
  Color _getFeedbackColor(FeedbackType feedbackType) {
    switch (feedbackType) {
      case FeedbackType.positive:
        return Colors.green;
      case FeedbackType.negative:
        return Colors.red;
      case FeedbackType.funny:
        return Colors.orange;
    }
  }
}
