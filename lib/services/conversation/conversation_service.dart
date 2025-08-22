import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/conversation/conversation.dart';
import '../../models/conversation/conversation_message.dart';
import '../../models/vision_feedback.dart';
import '../../models/profet.dart';
import '../../models/profet_manager.dart';
import '../../config/conversation_config.dart';
import '../../services/question_ad_service.dart';
import '../../utils/app_logger.dart';
import 'conversation_storage_service.dart';
import 'conversation_bio_service.dart';

/// Core service for managing conversation lifecycle and state
/// 
/// This service handles conversation creation, message flow, state management,
/// and integration with ad service for the 5-message interval logic
class ConversationService {
  static const String _component = 'ConversationService';
  
  final ConversationStorageService _storageService = ConversationStorageService();
  final QuestionAdService _adService = QuestionAdService();
  final ConversationBioService _bioService = ConversationBioService();
  
  // Current conversation state
  Conversation? _currentConversation;
  List<ConversationMessage> _currentMessages = [];
  
  // Stream controllers for real-time updates
  final StreamController<Conversation?> _conversationController = StreamController<Conversation?>.broadcast();
  final StreamController<List<ConversationMessage>> _messagesController = StreamController<List<ConversationMessage>>.broadcast();
  final StreamController<bool> _isTypingController = StreamController<bool>.broadcast();
  
  // Singleton pattern
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal() {
    _initializeAdService();
  }

  // Public getters for streams
  Stream<Conversation?> get conversationStream => _conversationController.stream;
  Stream<List<ConversationMessage>> get messagesStream => _messagesController.stream;
  Stream<bool> get isTypingStream => _isTypingController.stream;
  
  // Current state getters
  Conversation? get currentConversation => _currentConversation;
  List<ConversationMessage> get currentMessages => List.unmodifiable(_currentMessages);
  bool get hasActiveConversation => _currentConversation != null;
  int get messageCount => _currentMessages.length;

  /// Initialize the ad service
  Future<void> _initializeAdService() async {
    try {
      await _adService.initialize();
      AppLogger.logInfo(_component, 'Ad service initialized successfully');
    } catch (e) {
      AppLogger.logError(_component, 'Failed to initialize ad service', e);
      // Continue without ads if initialization fails
    }
  }

  /// Start a new conversation with the specified prophet
  Future<Conversation> startConversation({
    required ProfetType prophetType, // Use enum instead of string
    required bool isAIEnabled,
    String? customTitle,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Starting new conversation with ${prophetType.name}');
      
      // End current conversation if exists
      if (_currentConversation != null) {
        await endCurrentConversation();
      }
      
      // Generate title if not provided
      final title = customTitle ?? await _generateConversationTitle(prophetType);
      
      // Create new conversation (convert enum to string for storage)
      _currentConversation = await _storageService.createConversation(
        title: title,
        prophetType: ProfetManager.getProfetTypeString(prophetType),
        isAIEnabled: isAIEnabled,
      );
      
      _currentMessages = [];
      
      // Notify listeners
      _conversationController.add(_currentConversation);
      _messagesController.add(_currentMessages);
      
      AppLogger.logInfo(_component, 'Conversation started with ID: ${_currentConversation!.id}');
      return _currentConversation!;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to start conversation', e);
      rethrow;
    }
  }

  /// Send a user message and get prophet response
  Future<ConversationMessage> sendMessage({
    required String content,
    required BuildContext context,
  }) async {
    if (_currentConversation == null) {
      throw Exception('No active conversation. Start a conversation first.');
    }

    try {
      AppLogger.logInfo(_component, 'Processing user message in conversation ${_currentConversation!.id}');
      
      // Add user message
      final userMessage = await _storageService.addMessage(
        conversationId: _currentConversation!.id!,
        content: content,
        sender: MessageSender.user,
      );
      
      _currentMessages.add(userMessage);
      _messagesController.add(_currentMessages);
      
      // Show typing indicator
      if (ConversationConfig.showTypingIndicators) {
        _isTypingController.add(true);
      }

      // Generate prophet response
      final prophetMessage = await _generateProphetResponse(content, context);
      
      // Hide typing indicator
      if (ConversationConfig.showTypingIndicators) {
        _isTypingController.add(false);
      }

      _currentMessages.add(prophetMessage);
      _messagesController.add(_currentMessages);
      
      // Check if ad should be shown for prophet response
      final prophetResponseAllowed = await _adService.handleProphetResponse(context);
      if (!prophetResponseAllowed) {
        AppLogger.logInfo(_component, 'Prophet response completed but user is in cooldown');
      }
      
      AppLogger.logInfo(_component, 'Message exchange completed');
      return prophetMessage;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to process message', e);
      
      // Hide typing indicator on error
      if (ConversationConfig.showTypingIndicators) {
        _isTypingController.add(false);
      }
      
      rethrow;
    }
  }  /// Update feedback for a specific message
  Future<void> updateMessageFeedback({
    required int messageId,
    required FeedbackType feedbackType,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Updating feedback for message $messageId');
      
      await _storageService.updateMessageFeedback(
        messageId: messageId,
        feedbackType: feedbackType,
      );
      
      // Update local message list
      final messageIndex = _currentMessages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        _currentMessages[messageIndex] = _currentMessages[messageIndex].copyWith(
          feedbackType: feedbackType,
        );
        _messagesController.add(_currentMessages);
      }
      
      AppLogger.logInfo(_component, 'Message feedback updated successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to update message feedback', e);
      rethrow;
    }
  }

  /// Load an existing conversation
  Future<void> loadConversation(int conversationId) async {
    try {
      AppLogger.logInfo(_component, 'Loading conversation $conversationId');
      
      // End current conversation if exists
      if (_currentConversation != null && _currentConversation!.id != conversationId) {
        await endCurrentConversation();
      }
      
      // Load conversation and messages
      final conversation = await _storageService.getConversation(conversationId);
      if (conversation == null) {
        throw Exception('Conversation $conversationId not found');
      }
      
      final messages = await _storageService.getConversationMessages(conversationId);
      
      _currentConversation = conversation;
      _currentMessages = messages;
      
      // Notify listeners
      _conversationController.add(_currentConversation);
      _messagesController.add(_currentMessages);
      
      AppLogger.logInfo(_component, 'Conversation loaded with ${messages.length} messages');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to load conversation', e);
      rethrow;
    }
  }

  /// End the current conversation
  Future<void> endCurrentConversation() async {
    if (_currentConversation == null) return;
    
    try {
      AppLogger.logInfo(_component, 'Ending current conversation');
      
      // Update conversation status to completed
      await _storageService.updateConversationStatus(
        conversationId: _currentConversation!.id!,
        status: ConversationStatus.completed,
      );
      
      // Clear current state
      _currentConversation = null;
      _currentMessages = [];
      
      // Notify listeners
      _conversationController.add(null);
      _messagesController.add([]);
      _isTypingController.add(false);
      
      AppLogger.logInfo(_component, 'Conversation ended successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to end conversation', e);
      rethrow;
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(int conversationId) async {
    try {
      AppLogger.logInfo(_component, 'Deleting conversation $conversationId');
      
      // If deleting current conversation, end it first
      if (_currentConversation?.id == conversationId) {
        await endCurrentConversation();
      }
      
      await _storageService.deleteConversation(conversationId);
      
      AppLogger.logInfo(_component, 'Conversation deleted successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to delete conversation', e);
      rethrow;
    }
  }

  /// Get recent conversations for quick access
  Future<List<Conversation>> getRecentConversations({int limit = 5}) async {
    try {
      return await _storageService.getRecentConversations(limit: limit);
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get recent conversations', e);
      rethrow;
    }
  }

  /// Search conversations
  Future<List<Conversation>> searchConversations(String query) async {
    try {
      return await _storageService.searchConversations(query);
    } catch (e) {
      AppLogger.logError(_component, 'Failed to search conversations', e);
      rethrow;
    }
  }

  /// Private helper methods

  /// Generate prophet response for user message
  Future<ConversationMessage> _generateProphetResponse(String userContent, BuildContext context) async {
    try {
      final profet = ProfetManager.getProfet(_currentConversation!.prophetTypeEnum);
      
      // Generate response using enhanced bio integration
      String responseContent;
      bool isAIGenerated = false;
      
      if (_currentConversation!.isAIEnabled && Profet.isAIEnabled) {
        try {
          AppLogger.logInfo(_component, 'Using enhanced bio integration for AI response');
          
          // Use ConversationBioService for enhanced response with bio context
          responseContent = await _bioService.generateEnhancedProphetResponse(
            userMessage: userContent,
            context: context,
            prophetType: _currentConversation!.prophetTypeEnum,
            conversationHistory: _currentMessages,
            isAIEnabled: true,
            userId: 'default_user', // TODO: Get actual user ID
          );
          isAIGenerated = true;
        } catch (e) {
          AppLogger.logWarning(_component, 'Enhanced AI response failed, using standard fallback: $e');
          try {
            // Fallback to standard AI response without bio context
            responseContent = await profet.getAIPersonalizedResponse(userContent, context);
            isAIGenerated = true;
          } catch (e2) {
            AppLogger.logWarning(_component, 'Standard AI response also failed, using localized fallback: $e2');
            responseContent = await profet.getLocalizedPersonalizedResponse(context, userContent);
            isAIGenerated = false;
          }
        }
      } else {
        responseContent = await profet.getLocalizedPersonalizedResponse(context, userContent);
        isAIGenerated = false;
      }
      
      // Store prophet message
      final prophetMessage = await _storageService.addMessage(
        conversationId: _currentConversation!.id!,
        content: responseContent,
        sender: MessageSender.prophet,
        isAIGenerated: isAIGenerated,
        metadata: isAIGenerated ? 'ai_generated' : 'localized_response',
      );
      
      // Generate a proper title based on the first prophet response
      await _updateConversationTitleIfNeeded(responseContent, context);
      
      return prophetMessage;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to generate prophet response', e);
      rethrow;
    }
  }

  /// Generate conversation title based on prophet type
  Future<String> _generateConversationTitle(ProfetType prophetType) async {
    final prophet = ProfetManager.getProfet(prophetType);
    final timestamp = DateTime.now();
    
    // Create a descriptive title
    final time = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    return 'Chat with ${prophet.name} - $time';
  }

  /// Update conversation title if this is the first prophet response
  Future<void> _updateConversationTitleIfNeeded(String prophetResponseContent, BuildContext context) async {
    if (_currentConversation == null) return;
    
    try {
      // Check if this is the first prophet message (title still contains "Chat with")
      if (_currentConversation!.title.contains('Chat with')) {
        AppLogger.logInfo(_component, 'Generating proper title for conversation based on first prophet response');
        
        // Get the prophet and generate a meaningful title
        final prophetType = ProfetManager.getProfetTypeFromString(_currentConversation!.prophetType);
        final prophet = ProfetManager.getProfet(prophetType);
        
        // Use the prophet's title generation method to create a meaningful title
        final generatedTitle = await prophet.generateVisionTitle(
          context,
          answer: prophetResponseContent,
        );
        
        // Update the conversation title in the database
        await _storageService.updateConversationTitle(
          conversationId: _currentConversation!.id!,
          title: generatedTitle,
        );
        
        // Update the local conversation object
        _currentConversation = _currentConversation!.copyWith(title: generatedTitle);
        
        // Notify listeners about the updated conversation
        _conversationController.add(_currentConversation);
        
        AppLogger.logInfo(_component, 'Conversation title updated to: $generatedTitle');
      }
    } catch (e) {
      AppLogger.logError(_component, 'Failed to update conversation title', e);
      // Don't rethrow - title generation failure shouldn't break the conversation
    }
  }
  /// Dispose of streams and resources
  void dispose() {
    _conversationController.close();
    _messagesController.close();
    _isTypingController.close();
    AppLogger.logInfo(_component, 'ConversationService disposed');
  }
}
