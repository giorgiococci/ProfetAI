import 'dart:async';
import '../database_service.dart';
import '../../models/conversation/conversation.dart';
import '../../models/conversation/conversation_message.dart';
import '../../models/vision_feedback.dart';
import '../../config/conversation_config.dart';
import '../../utils/app_logger.dart';

/// Storage service for conversation data operations
/// 
/// This service handles all database operations related to conversations
/// and messages, including CRUD operations, conversation limits, and data validation
class ConversationStorageService {
  static const String _component = 'ConversationStorageService';
  
  final DatabaseService _databaseService = DatabaseService();
  
  // Singleton pattern
  static final ConversationStorageService _instance = ConversationStorageService._internal();
  factory ConversationStorageService() => _instance;
  ConversationStorageService._internal();

  /// Create a new conversation
  Future<Conversation> createConversation({
    required String title,
    required String prophetType,
    bool isAIEnabled = false,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Creating new conversation: $title');
      
      // Check conversation limit before creating
      await _enforceConversationLimit();
      
      final db = await _databaseService.database;
      final now = DateTime.now();
      
      final conversationMap = {
        'title': title,
        'prophet_type': prophetType,
        'started_at': now.millisecondsSinceEpoch,
        'last_updated_at': now.millisecondsSinceEpoch,
        'message_count': 0,
        'status': ConversationStatus.active.name,
        'is_ai_enabled': isAIEnabled ? 1 : 0,
      };
      
      final id = await db.insert('conversations', conversationMap);
      
      final conversation = Conversation(
        id: id,
        title: title,
        prophetType: prophetType,
        startedAt: now,
        lastUpdatedAt: now,
        messageCount: 0,
        status: ConversationStatus.active,
        isAIEnabled: isAIEnabled,
      );
      
      AppLogger.logInfo(_component, 'Conversation created with ID: $id');
      return conversation;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to create conversation', e);
      rethrow;
    }
  }

  /// Add a message to a conversation
  Future<ConversationMessage> addMessage({
    required int conversationId,
    required String content,
    required MessageSender sender,
    FeedbackType? feedbackType,
    bool isAIGenerated = false,
    String? metadata,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Adding message to conversation $conversationId');
      
      final db = await _databaseService.database;
      final now = DateTime.now();
      
      // Check message limit per conversation
      await _enforceMessageLimit(conversationId);
      
      final messageMap = {
        'conversation_id': conversationId,
        'content': content,
        'sender': sender.name,
        'timestamp': now.millisecondsSinceEpoch,
        'feedback_type': feedbackType?.name,
        'is_ai_generated': isAIGenerated ? 1 : 0,
        'metadata': metadata,
      };
      
      final messageId = await db.insert('conversation_messages', messageMap);
      
      // Update conversation message count and last updated time
      await _updateConversationMetadata(conversationId);
      
      final message = ConversationMessage(
        id: messageId,
        conversationId: conversationId,
        content: content,
        sender: sender,
        timestamp: now,
        feedbackType: feedbackType,
        isAIGenerated: isAIGenerated,
        metadata: metadata,
      );
      
      AppLogger.logInfo(_component, 'Message added with ID: $messageId');
      return message;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to add message', e);
      rethrow;
    }
  }

  /// Update message feedback
  Future<void> updateMessageFeedback({
    required int messageId,
    required FeedbackType feedbackType,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Updating feedback for message $messageId');
      
      final db = await _databaseService.database;
      
      await db.update(
        'conversation_messages',
        {'feedback_type': feedbackType.name},
        where: 'id = ?',
        whereArgs: [messageId],
      );
      
      AppLogger.logInfo(_component, 'Message feedback updated successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to update message feedback', e);
      rethrow;
    }
  }

  /// Get all conversations, ordered by most recent
  Future<List<Conversation>> getAllConversations({
    int? limit,
    int? offset,
    ConversationStatus? statusFilter,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Retrieving conversations');
      
      final db = await _databaseService.database;
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (statusFilter != null) {
        whereClause = 'WHERE status = ?';
        whereArgs.add(statusFilter.name);
      }
      
      String query = '''
        SELECT * FROM conversations 
        $whereClause
        ORDER BY last_updated_at DESC
      ''';
      
      if (limit != null) {
        query += ' LIMIT $limit';
        if (offset != null) {
          query += ' OFFSET $offset';
        }
      }
      
      final results = await db.rawQuery(query, whereArgs);
      
      final conversations = results.map((map) => Conversation.fromMap(map)).toList();
      
      AppLogger.logInfo(_component, 'Retrieved ${conversations.length} conversations');
      return conversations;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to retrieve conversations', e);
      rethrow;
    }
  }

  /// Get a specific conversation by ID
  Future<Conversation?> getConversation(int conversationId) async {
    try {
      AppLogger.logInfo(_component, 'Retrieving conversation $conversationId');
      
      final db = await _databaseService.database;
      
      final results = await db.query(
        'conversations',
        where: 'id = ?',
        whereArgs: [conversationId],
      );
      
      if (results.isEmpty) {
        AppLogger.logWarning(_component, 'Conversation $conversationId not found');
        return null;
      }
      
      final conversation = Conversation.fromMap(results.first);
      AppLogger.logInfo(_component, 'Conversation retrieved successfully');
      return conversation;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to retrieve conversation', e);
      rethrow;
    }
  }

  /// Get all messages for a conversation
  Future<List<ConversationMessage>> getConversationMessages(int conversationId) async {
    try {
      AppLogger.logInfo(_component, 'Retrieving messages for conversation $conversationId');
      
      final db = await _databaseService.database;
      
      final results = await db.query(
        'conversation_messages',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
        orderBy: 'timestamp ASC',
      );
      
      final messages = results.map((map) => ConversationMessage.fromMap(map)).toList();
      
      AppLogger.logInfo(_component, 'Retrieved ${messages.length} messages');
      return messages;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to retrieve conversation messages', e);
      rethrow;
    }
  }

  /// Delete a conversation and all its messages
  Future<void> deleteConversation(int conversationId) async {
    try {
      AppLogger.logInfo(_component, 'Deleting conversation $conversationId');
      
      final db = await _databaseService.database;
      
      // Delete messages first (though CASCADE should handle this)
      await db.delete(
        'conversation_messages',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
      );
      
      // Delete conversation
      await db.delete(
        'conversations',
        where: 'id = ?',
        whereArgs: [conversationId],
      );
      
      AppLogger.logInfo(_component, 'Conversation deleted successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to delete conversation', e);
      rethrow;
    }
  }

  /// Update conversation status
  Future<void> updateConversationStatus({
    required int conversationId,
    required ConversationStatus status,
  }) async {
    try {
      AppLogger.logInfo(_component, 'Updating conversation status to ${status.name}');
      
      final db = await _databaseService.database;
      
      await db.update(
        'conversations',
        {
          'status': status.name,
          'last_updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [conversationId],
      );
      
      AppLogger.logInfo(_component, 'Conversation status updated successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to update conversation status', e);
      rethrow;
    }
  }

  /// Get conversation count
  Future<int> getConversationCount({ConversationStatus? statusFilter}) async {
    try {
      final db = await _databaseService.database;
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (statusFilter != null) {
        whereClause = 'WHERE status = ?';
        whereArgs.add(statusFilter.name);
      }
      
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM conversations $whereClause',
        whereArgs,
      );
      
      return result.first['count'] as int;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get conversation count', e);
      rethrow;
    }
  }

  /// Get recent conversations (for quick access)
  Future<List<Conversation>> getRecentConversations({int limit = 5}) async {
    return getAllConversations(
      limit: limit,
      statusFilter: ConversationStatus.active,
    );
  }

  /// Search conversations by title or content
  Future<List<Conversation>> searchConversations(String query) async {
    try {
      AppLogger.logInfo(_component, 'Searching conversations with query: $query');
      
      final db = await _databaseService.database;
      
      // Search in both conversation titles and message content
      final results = await db.rawQuery('''
        SELECT DISTINCT c.* FROM conversations c
        LEFT JOIN conversation_messages m ON c.id = m.conversation_id
        WHERE c.title LIKE ? OR m.content LIKE ?
        ORDER BY c.last_updated_at DESC
      ''', ['%$query%', '%$query%']);
      
      final conversations = results.map((map) => Conversation.fromMap(map)).toList();
      
      AppLogger.logInfo(_component, 'Found ${conversations.length} conversations matching query');
      return conversations;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to search conversations', e);
      rethrow;
    }
  }

  /// Private helper methods

  /// Enforce conversation limit by archiving oldest if necessary
  Future<void> _enforceConversationLimit() async {
    final activeCount = await getConversationCount(statusFilter: ConversationStatus.active);
    
    if (activeCount >= ConversationConfig.maxConversations) {
      AppLogger.logInfo(_component, 'Conversation limit reached, archiving oldest conversations');
      
      // Get oldest active conversations
      final db = await _databaseService.database;
      final oldest = await db.query(
        'conversations',
        where: 'status = ?',
        whereArgs: [ConversationStatus.active.name],
        orderBy: 'last_updated_at ASC',
        limit: activeCount - ConversationConfig.maxConversations + 1,
      );
      
      // Archive oldest conversations
      for (final conversation in oldest) {
        await updateConversationStatus(
          conversationId: conversation['id'] as int,
          status: ConversationStatus.archived,
        );
      }
    }
  }

  /// Enforce message limit per conversation
  Future<void> _enforceMessageLimit(int conversationId) async {
    final conversation = await getConversation(conversationId);
    
    if (conversation != null && 
        conversation.messageCount >= ConversationConfig.maxMessagesPerConversation) {
      throw Exception('Conversation has reached the maximum message limit of ${ConversationConfig.maxMessagesPerConversation} messages');
    }
  }

  /// Update conversation metadata (message count, last updated)
  Future<void> _updateConversationMetadata(int conversationId) async {
    final db = await _databaseService.database;
    
    // Get current message count
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM conversation_messages WHERE conversation_id = ?',
      [conversationId],
    );
    
    final messageCount = countResult.first['count'] as int;
    
    // Update conversation
    await db.update(
      'conversations',
      {
        'message_count': messageCount,
        'last_updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }
}
