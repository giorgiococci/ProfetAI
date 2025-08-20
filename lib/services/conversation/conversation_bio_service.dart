import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/conversation/conversation.dart';
import '../../models/conversation/conversation_message.dart';
import '../../models/profet_manager.dart';
import '../../config/conversation_config.dart';
import '../../services/bio/bio_analysis_agent.dart';
import '../../services/bio/bio_generation_service.dart';
import '../../utils/app_logger.dart';

/// Service for integrating bio analysis with ongoing conversations
/// 
/// This service handles real-time bio analysis during conversations,
/// context building from conversation history, and bio updates after each message
class ConversationBioService {
  static const String _component = 'ConversationBioService';
  
  final BioAnalysisAgent _bioAgent = BioAnalysisAgent();
  final BioGenerationService _bioGeneration = BioGenerationService.instance;
  
  // Singleton pattern
  static final ConversationBioService _instance = ConversationBioService._internal();
  factory ConversationBioService() => _instance;
  ConversationBioService._internal();

  /// Analyze and extract bio insights from a conversation message exchange
  Future<void> analyzeMessageExchange({
    required BuildContext context,
    required String userMessage,
    required String prophetResponse,
    required ProfetType prophetType, // Use enum instead of string
    String userId = 'default_user',
  }) async {
    if (!ConversationConfig.enableRealTimeBioUpdates) {
      AppLogger.logInfo(_component, 'Real-time bio updates disabled, skipping analysis');
      return;
    }

    try {
      AppLogger.logInfo(_component, 'Analyzing message exchange for bio insights');
      AppLogger.logInfo(_component, 'User message length: ${userMessage.length}, Prophet response length: ${prophetResponse.length}');
      
      // Get Profet instance from enum
      final profet = ProfetManager.getProfet(prophetType);
      
      // Use the enhanced BioAnalysisAgent method
      await _bioAgent.analyzeMessageExchange(
        context: context,
        userMessage: userMessage,
        prophetResponse: prophetResponse,
        profet: profet,
        userId: userId,
      );
      
      AppLogger.logInfo(_component, 'Bio analysis completed for message exchange');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to analyze message exchange', e);
      // Don't throw - bio analysis should not block conversation flow
    }
  }

  /// Analyze a direct prophet message (like "Listen to Oracle") for bio insights
  Future<void> analyzeDirectProphetMessage({
    required String content,
    required ProfetType prophetType,
    String userId = 'default_user',
  }) async {
    if (!ConversationConfig.enableRealTimeBioUpdates) {
      AppLogger.logInfo(_component, 'Real-time bio updates disabled, skipping direct prophet analysis');
      return;
    }

    try {
      AppLogger.logInfo(_component, 'Analyzing direct prophet message for bio insights');
      AppLogger.logInfo(_component, 'Prophet message length: ${content.length}, Prophet type: ${prophetType.name}');
      
      // Get Profet instance from enum
      final profet = ProfetManager.getProfet(prophetType);
      
      // Analyze the prophet response without a user question
      // This can provide insights into user interests based on how they engage
      // with oracle visions or direct prophet messages
      await _bioAgent.analyzeDirectProphetResponse(
        response: content,
        profet: profet,
        userId: userId,
      );
      
      AppLogger.logInfo(_component, 'Bio analysis completed for direct prophet message');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to analyze direct prophet message', e);
      // Don't throw - bio analysis should not block conversation flow
    }
  }

  /// Generate personalized context for prophet response based on conversation history
  Future<String> generateConversationContext({
    required String userId,
    required ProfetType prophetType, // Use enum instead of string
    required List<ConversationMessage> conversationHistory,
    int maxContextMessages = 5,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Generating conversation context for ${prophetType.name}');
      
      // Get base bio context (convert enum to string for storage service)
      String bioContext = await _bioGeneration.generateContextForProphet(
        userId: userId,
        prophetType: ProfetManager.getProfetTypeString(prophetType),
      );
      
      // Build conversation history context
      String conversationContext = _buildConversationHistoryContext(
        conversationHistory,
        maxContextMessages,
      );
      
      // Combine bio and conversation context
      if (bioContext.isNotEmpty && conversationContext.isNotEmpty) {
        return '''
Bio Context:
$bioContext

Recent Conversation:
$conversationContext''';
      } else if (bioContext.isNotEmpty) {
        return bioContext;
      } else if (conversationContext.isNotEmpty) {
        return '''
Recent Conversation:
$conversationContext''';
      }
      
      return '';
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to generate conversation context', e);
      return '';
    }
  }

  /// Analyze entire conversation for patterns and insights
  Future<void> analyzeFullConversation({
    required BuildContext context,
    required Conversation conversation,
    required List<ConversationMessage> messages,
    String userId = 'default_user',
  }) async {
    try {
      AppLogger.logInfo(_component, 'Analyzing full conversation ${conversation.id} for patterns');
      
      // Group messages into user-prophet pairs
      final messagePairs = _groupMessagesIntoPairs(messages);
      
      // Analyze each pair for insights
      for (final pair in messagePairs) {
        if (pair.userMessage != null && pair.prophetMessage != null) {
          await analyzeMessageExchange(
            context: context,
            userMessage: pair.userMessage!.content,
            prophetResponse: pair.prophetMessage!.content,
            prophetType: conversation.prophetTypeEnum, // Use enum getter
            userId: userId,
          );
        }
      }
      
      // Analyze conversation patterns
      await _analyzeConversationPatterns(context, conversation, messages, userId);
      
      AppLogger.logInfo(_component, 'Full conversation analysis completed');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to analyze full conversation', e);
    }
  }

  /// Generate enhanced prophet response with full conversation context
  Future<String> generateEnhancedProphetResponse({
    required String userMessage,
    required BuildContext context,
    required ProfetType prophetType,
    required List<ConversationMessage> conversationHistory,
    required bool isAIEnabled,
    String userId = 'default_user',
  }) async {
    try {
      AppLogger.logInfo(_component, 'Generating enhanced prophet response');
      
      final profet = ProfetManager.getProfet(prophetType);
      
      if (isAIEnabled) {
        // Generate personalized context including conversation history
        final personalizedContext = await generateConversationContext(
          userId: userId,
          prophetType: prophetType, // Use enum directly
          conversationHistory: conversationHistory,
        );
        
        if (personalizedContext.isNotEmpty) {
          // Use enhanced method with both bio and conversation context
          return await profet.getAIPersonalizedResponseWithContext(
            userMessage,
            context,
            personalizedContext: personalizedContext,
          );
        } else {
          // Fall back to standard AI response
          return await profet.getAIPersonalizedResponse(userMessage, context);
        }
      } else {
        // Use localized response
        return await profet.getLocalizedPersonalizedResponse(context, userMessage);
      }
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to generate enhanced response', e);
      rethrow;
    }
  }

  /// Private helper methods

  /// Build conversation history context string
  String _buildConversationHistoryContext(
    List<ConversationMessage> messages,
    int maxMessages,
  ) {
    if (messages.isEmpty) return '';
    
    // Get the most recent messages, respecting the limit
    final recentMessages = messages.length > maxMessages
        ? messages.sublist(messages.length - maxMessages)
        : messages;
    
    final contextBuilder = StringBuffer();
    
    for (int i = 0; i < recentMessages.length; i++) {
      final message = recentMessages[i];
      final sender = message.isUserMessage ? 'User' : 'Prophet';
      
      contextBuilder.writeln('$sender: ${message.content}');
      
      // Add separator between exchanges (not after last message)
      if (i < recentMessages.length - 1 && 
          message.isProphetMessage && 
          i + 1 < recentMessages.length && 
          recentMessages[i + 1].isUserMessage) {
        contextBuilder.writeln('---');
      }
    }
    
    return contextBuilder.toString().trim();
  }

  /// Group messages into user-prophet pairs for analysis
  List<MessagePair> _groupMessagesIntoPairs(List<ConversationMessage> messages) {
    final pairs = <MessagePair>[];
    ConversationMessage? pendingUserMessage;
    
    for (final message in messages) {
      if (message.isUserMessage) {
        // Store user message, wait for prophet response
        pendingUserMessage = message;
      } else if (message.isProphetMessage && pendingUserMessage != null) {
        // Create pair with user message and prophet response
        pairs.add(MessagePair(
          userMessage: pendingUserMessage,
          prophetMessage: message,
        ));
        pendingUserMessage = null;
      }
    }
    
    return pairs;
  }

  /// Analyze conversation patterns for additional insights
  Future<void> _analyzeConversationPatterns(
    BuildContext context,
    Conversation conversation,
    List<ConversationMessage> messages,
    String userId,
  ) async {
    try {
      // Analyze conversation themes
      final userMessages = messages.where((m) => m.isUserMessage).toList();
      final prophetMessages = messages.where((m) => m.isProphetMessage).toList();
      
      if (userMessages.length >= 3) {
        // Analyze user's recurring themes/interests using the enhanced BioAnalysisAgent
        final messageContents = userMessages.map((m) => m.content).toList();
        
        await _bioAgent.analyzeConversationPatterns(
          context: context,
          userMessages: messageContents,
          profet: conversation.profet, // Use the profet getter
          userId: userId,
        );
        
        AppLogger.logInfo(_component, 'Conversation pattern analysis completed');
      }
      
      // Analyze feedback patterns
      _analyzeFeedbackPatterns(prophetMessages);
      
    } catch (e) {
      AppLogger.logWarning(_component, 'Pattern analysis failed: $e');
    }
  }

  /// Analyze feedback patterns for insights
  void _analyzeFeedbackPatterns(List<ConversationMessage> prophetMessages) {
    final feedbackCounts = <String, int>{};
    
    for (final message in prophetMessages) {
      if (message.feedbackType != null) {
        final feedback = message.feedbackType!.name;
        feedbackCounts[feedback] = (feedbackCounts[feedback] ?? 0) + 1;
      }
    }
    
    AppLogger.logInfo(_component, 'Conversation feedback patterns: $feedbackCounts');
  }
}

/// Helper class for grouping user-prophet message pairs
class MessagePair {
  final ConversationMessage? userMessage;
  final ConversationMessage? prophetMessage;
  
  const MessagePair({
    this.userMessage,
    this.prophetMessage,
  });
}
