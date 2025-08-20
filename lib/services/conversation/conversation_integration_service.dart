import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/conversation/conversation.dart';
import '../../models/conversation/conversation_message.dart';
import '../../models/vision_feedback.dart';
import '../../models/profet_manager.dart';
import '../../config/conversation_config.dart';
import '../../utils/app_logger.dart';
import 'conversation_service.dart';
import 'conversation_storage_service.dart';
import 'conversation_bio_service.dart';

/// Integration service that orchestrates conversation flow between UI and services
/// 
/// This service provides a high-level API for the UI to interact with conversations
/// while managing the coordination between storage, bio analysis, and business logic
class ConversationIntegrationService {
  static const String _component = 'ConversationIntegrationService';
  
  final ConversationService _conversationService = ConversationService();
  final ConversationStorageService _storageService = ConversationStorageService();
  final ConversationBioService _bioService = ConversationBioService();
  
  // Singleton pattern
  static final ConversationIntegrationService _instance = ConversationIntegrationService._internal();
  factory ConversationIntegrationService() => _instance;
  ConversationIntegrationService._internal();

  // Stream getters for UI subscriptions
  Stream<Conversation?> get conversationStream => _conversationService.conversationStream;
  Stream<List<ConversationMessage>> get messagesStream => _conversationService.messagesStream;
  Stream<bool> get isTypingStream => _conversationService.isTypingStream;
  
  // Current state getters
  Conversation? get currentConversation => _conversationService.currentConversation;
  List<ConversationMessage> get currentMessages => _conversationService.currentMessages;
  bool get hasActiveConversation => _conversationService.hasActiveConversation;
  int get messageCount => _conversationService.messageCount;

  /// Initialize the service and its dependencies
  Future<void> initialize() async {
    try {
      AppLogger.logInfo(_component, 'Initializing conversation integration service');
      
      // Note: ConversationStorageService doesn't have an initialize method
      // It uses DatabaseService which is already initialized at app startup
      
      AppLogger.logInfo(_component, 'Conversation integration service initialized successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to initialize conversation integration service', e);
      rethrow;
    }
  }

  /// Start a new conversation with full integration
  Future<Conversation> startConversation({
    required BuildContext context,
    required ProfetType prophetType, // Use enum instead of string
    required bool isAIEnabled,
    String? customTitle,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Starting integrated conversation with ${prophetType.name}');
      
      // Start conversation through conversation service
      final conversation = await _conversationService.startConversation(
        prophetType: prophetType,
        isAIEnabled: isAIEnabled,
        customTitle: customTitle,
      );
      
      AppLogger.logInfo(_component, 'Integrated conversation started successfully');
      return conversation;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to start integrated conversation', e);
      rethrow;
    }
  }

  /// Send a message in the current conversation with full processing
  Future<ConversationMessage> sendMessage({
    required BuildContext context,
    required String content,
    String userId = 'default_user',
  }) async {
    if (!hasActiveConversation) {
      throw StateError('No active conversation - start a conversation first');
    }

    try {
      AppLogger.logInfo(_component, 'Processing message send with full integration');
      
      // Send message through conversation service (this handles both user message and prophet response)
      final prophetMessage = await _conversationService.sendMessage(
        content: content,
        context: context,
      );
      
      // Perform bio analysis on the message exchange (async, non-blocking)
      if (ConversationConfig.enableRealTimeBioUpdates) {
        AppLogger.logInfo(_component, 'Bio updates enabled - starting bio analysis for message exchange');
        _bioService.analyzeMessageExchange(
          context: context,
          userMessage: content,
          prophetResponse: prophetMessage.content,
          prophetType: currentConversation!.prophetTypeEnum, // Use enum getter
          userId: userId,
        ).catchError((error) {
          AppLogger.logWarning(_component, 'Bio analysis failed but continuing: $error');
        });
      }
      
      AppLogger.logInfo(_component, 'Message processing completed successfully');
      return prophetMessage;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to process message send', e);
      rethrow;
    }
  }

  /// Add a direct prophet message without user input (for "Listen to Oracle" feature)
  Future<ConversationMessage> addDirectProphetMessage({
    required String content,
    bool isAIGenerated = true,
    String? metadata,
    String userId = 'default_user',
  }) async {
    if (!hasActiveConversation) {
      throw StateError('No active conversation - start a conversation first');
    }

    try {
      AppLogger.logInfo(_component, 'Adding direct prophet message');
      
      // Add the prophet message directly to storage
      final prophetMessage = await _storageService.addMessage(
        conversationId: currentConversation!.id!,
        content: content,
        sender: MessageSender.prophet,
        isAIGenerated: isAIGenerated,
        metadata: metadata,
      );
      
      // Update conversation service state to keep everything in sync
      await _conversationService.loadConversation(currentConversation!.id!);
      
      // Perform bio analysis on the prophet message (async, non-blocking)
      // This is needed for "Listen to Oracle" and other direct prophet messages
      if (ConversationConfig.enableRealTimeBioUpdates) {
        AppLogger.logInfo(_component, 'Bio updates enabled - starting bio analysis for direct prophet message');
        _bioService.analyzeDirectProphetMessage(
          content: content,
          prophetType: currentConversation!.prophetTypeEnum,
          userId: userId,
        ).catchError((error) {
          AppLogger.logWarning(_component, 'Bio analysis failed for direct prophet message: $error');
        });
      }
      
      AppLogger.logInfo(_component, 'Direct prophet message added successfully');
      return prophetMessage;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to add direct prophet message', e);
      rethrow;
    }
  }

  /// Update message feedback with full integration
  Future<void> updateMessageFeedback({
    required int messageId,
    required FeedbackType feedbackType,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Updating message feedback with integration');
      
      // Update feedback through conversation service
      await _conversationService.updateMessageFeedback(
        messageId: messageId,
        feedbackType: feedbackType,
      );
      
      AppLogger.logInfo(_component, 'Message feedback updated successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to update message feedback', e);
      rethrow;
    }
  }

  /// End the current conversation
  Future<void> endCurrentConversation() async {
    try {
      AppLogger.logInfo(_component, 'Ending current conversation with integration');
      
      await _conversationService.endCurrentConversation();
      
      AppLogger.logInfo(_component, 'Conversation ended successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to end conversation', e);
      rethrow;
    }
  }

  /// Load an existing conversation with full state restoration
  Future<void> loadConversation({
    required BuildContext context,
    required int conversationId,
    String userId = 'default_user',
  }) async {
    try {
      AppLogger.logInfo(_component, 'Loading conversation with full integration');
      
      // Load conversation through conversation service
      await _conversationService.loadConversation(conversationId);
      
      // Optionally trigger bio analysis on loaded conversation
      if (ConversationConfig.enableRealTimeBioUpdates && 
          ConversationConfig.analyzePastConversations) {
        final conversation = currentConversation;
        final messages = currentMessages;
        
        if (conversation != null && messages.isNotEmpty) {
          _bioService.analyzeFullConversation(
            context: context,
            conversation: conversation,
            messages: messages,
            userId: userId,
          ).catchError((error) {
            AppLogger.logWarning(_component, 'Past conversation bio analysis failed: $error');
          });
        }
      }
      
      AppLogger.logInfo(_component, 'Conversation loaded successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to load conversation', e);
      rethrow;
    }
  }

  /// Get conversation history with pagination
  Future<List<Conversation>> getConversationHistory({
    String userId = 'default_user',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _storageService.getAllConversations(
        limit: limit,
        offset: offset,
      );
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get conversation history', e);
      rethrow;
    }
  }

  /// Delete a conversation permanently
  Future<void> deleteConversation({
    required int conversationId,
    String userId = 'default_user',
  }) async {
    try {
      AppLogger.logInfo(_component, 'Deleting conversation with integration');
      
      // If this is the current conversation, end it first
      if (currentConversation?.id == conversationId) {
        await endCurrentConversation();
      }
      
      // Delete through storage service
      await _storageService.deleteConversation(conversationId);
      
      AppLogger.logInfo(_component, 'Conversation deleted successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to delete conversation', e);
      rethrow;
    }
  }

  /// Get conversation statistics for monitoring
  Future<Map<String, dynamic>> getConversationStatistics({
    String userId = 'default_user',
  }) async {
    try {
      final conversations = await _storageService.getAllConversations();
      final totalMessages = conversations.fold<int>(
        0, 
        (sum, conv) => sum + conv.messageCount,
      );
      
      final prophetTypeCounts = <String, int>{};
      for (final conv in conversations) {
        prophetTypeCounts[conv.prophetType] = (prophetTypeCounts[conv.prophetType] ?? 0) + 1;
      }
      
      return {
        'totalConversations': conversations.length,
        'totalMessages': totalMessages,
        'averageMessagesPerConversation': conversations.isNotEmpty 
            ? (totalMessages / conversations.length).round() 
            : 0,
        'prophetTypeDistribution': prophetTypeCounts,
        'hasActiveConversation': hasActiveConversation,
        'currentMessageCount': messageCount,
      };
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get conversation statistics', e);
      return <String, dynamic>{};
    }
  }

  /// Dispose of resources
  void dispose() {
    AppLogger.logInfo(_component, 'Disposing conversation integration service');
    // Note: Individual services manage their own disposal
  }
}
