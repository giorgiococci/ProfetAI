import 'package:flutter/material.dart';
import '../../models/conversation/conversation.dart';
import '../../models/conversation/conversation_message.dart';
import '../../models/profet_manager.dart';
import '../../models/vision_feedback.dart';
import '../../services/conversation/conversation_integration_service.dart';
import '../../utils/app_logger.dart';
import '../../l10n/app_localizations.dart';
import 'message_bubble.dart';

/// Main conversation view widget that displays the chat interface
/// Handles the conversation flow, message display, and user interactions
class ConversationView extends StatefulWidget {
  final ProfetType prophetType;
  final String? prophetImagePath;
  final String? initialQuestion;
  final VoidCallback? onConversationEnd;
  final Function(String message)? onMessageSent;
  final VoidCallback? onListenToOracle;

  const ConversationView({
    super.key,
    required this.prophetType,
    this.prophetImagePath,
    this.initialQuestion,
    this.onConversationEnd,
    this.onMessageSent,
    this.onListenToOracle,
  });

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView>
    with TickerProviderStateMixin {
  static const String _component = 'ConversationView';
  
  final ConversationIntegrationService _conversationService = 
      ConversationIntegrationService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  
  Conversation? _currentConversation;
  List<ConversationMessage> _messages = [];
  bool _isLoading = false;
  bool _isSendingMessage = false;
  
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startConversation();
  }

  void _initializeAnimations() {
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
  }

  Future<void> _startConversation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.logInfo(_component, 'Starting new conversation with ${widget.prophetType}');
      
      _currentConversation = await _conversationService.startConversation(
        context: context,
        prophetType: widget.prophetType,
        isAIEnabled: true,
      );
      
      // Get messages using the current messages from service
      _messages = _conversationService.currentMessages;
      
      AppLogger.logInfo(_component, 'Conversation started with ${_messages.length} messages');
      
      // Start fade in animation
      _fadeAnimationController.forward();
      
      // If there's an initial question, send it automatically
      if (widget.initialQuestion != null && widget.initialQuestion!.trim().isNotEmpty) {
        AppLogger.logInfo(_component, 'Sending initial question: ${widget.initialQuestion!.substring(0, widget.initialQuestion!.length > 20 ? 20 : widget.initialQuestion!.length)}...');
        _sendMessage(widget.initialQuestion!);
      }
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to start conversation', e);
      _showErrorSnackBar('Failed to start conversation. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty || _currentConversation == null || _isSendingMessage) {
      return;
    }

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final truncatedContent = content.length > 20 ? content.substring(0, 20) : content;
      AppLogger.logInfo(_component, 'Sending message: $truncatedContent...');
      
      // Clear input immediately
      _inputController.clear();
      
      // Notify parent
      widget.onMessageSent?.call(content);
      
      // Send message through integration service
      await _conversationService.sendMessage(
        context: context,
        content: content,
      );
      
      // Update messages from the service
      setState(() {
        _messages = _conversationService.currentMessages;
      });
      
      // Scroll to bottom to show response
      _scrollToBottom();
      
      AppLogger.logInfo(_component, 'Message exchange completed successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to send message', e);
      _showErrorSnackBar('Failed to send message. Please try again.');
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _endConversation() async {
    try {
      AppLogger.logInfo(_component, 'Ending conversation');
      
      // End conversation through service
      await _conversationService.endCurrentConversation();
      
      // Fade out animation
      await _fadeAnimationController.reverse();
      
      // Notify parent
      widget.onConversationEnd?.call();
      
    } catch (e) {
      AppLogger.logError(_component, 'Error ending conversation', e);
    }
  }

  Future<void> _updateMessageFeedback(ConversationMessage message, FeedbackType feedbackType) async {
    if (message.id == null) return;
    
    try {
      AppLogger.logInfo(_component, 'Updating feedback for message ${message.id}');
      
      // Update feedback through integration service
      await _conversationService.updateMessageFeedback(
        messageId: message.id!,
        feedbackType: feedbackType,
      );
      
      // Update local state
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
      AppLogger.logError(_component, 'Failed to update message feedback', e);
      if (mounted) {
        _showErrorSnackBar('Failed to update feedback. Please try again.');
      }
    }
  }

  String _getFeedbackEmoji(FeedbackType feedbackType) {
    switch (feedbackType) {
      case FeedbackType.positive:
        return '🌟';
      case FeedbackType.negative:
        return '🪨';
      case FeedbackType.funny:
        return '🐸';
    }
  }

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

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_currentConversation == null) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Starting conversation...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to start conversation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please try again',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _startConversation,
            child: Text(AppLocalizations.of(context)!.retryButton),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final prophet = ProfetManager.getProfet(widget.prophetType);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: prophet.primaryColor.withValues(alpha: 0.2),
            child: Icon(
              prophet.icon,
              color: prophet.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prophet.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Active Conversation',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Listen to Oracle button
          if (widget.onListenToOracle != null)
            IconButton(
              onPressed: widget.onListenToOracle,
              icon: const Icon(
                Icons.hearing,
                color: Colors.white70,
              ),
              tooltip: 'Listen to Oracle',
            ),
          IconButton(
            onPressed: _endConversation,
            icon: const Icon(
              Icons.close,
              color: Colors.white70,
            ),
            tooltip: 'End Conversation',
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ConversationMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: MessageBubble(
          message: message,
          prophetType: widget.prophetType,
          prophetImagePath: widget.prophetImagePath,
          onFeedbackUpdate: message.isProphetMessage ? (feedbackType) => _updateMessageFeedback(message, feedbackType) : null,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final prophet = ProfetManager.getProfet(widget.prophetType);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            prophet.icon,
            color: prophet.primaryColor.withValues(alpha: 0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation with ${prophet.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask a question or share your thoughts',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.typeYourMessage,
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _isSendingMessage ? null : _sendMessage,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _isSendingMessage 
                ? null 
                : () => _sendMessage(_inputController.text),
            icon: _isSendingMessage
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
            style: IconButton.styleFrom(
              backgroundColor: widget.prophetType == ProfetType.mistico
                  ? Colors.purple.withValues(alpha: 0.3)
                  : widget.prophetType == ProfetType.caotico
                      ? Colors.orange.withValues(alpha: 0.3)
                      : widget.prophetType == ProfetType.cinico
                          ? Colors.grey.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
