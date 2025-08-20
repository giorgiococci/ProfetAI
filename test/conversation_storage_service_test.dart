import 'package:flutter_test/flutter_test.dart';
import 'package:profet_ai/services/conversation/conversation_storage_service.dart';
import 'package:profet_ai/models/conversation/conversation.dart';
import 'package:profet_ai/models/vision_feedback.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('ConversationStorageService Integration Tests', () {
    late ConversationStorageService storageService;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      storageService = ConversationStorageService();
    });

    test('should create and retrieve conversation', () async {
      final conversation = await storageService.createConversation(
        title: 'Test Conversation',
        prophetType: 'mystic_prophet',
        isAIEnabled: true,
      );

      expect(conversation.id, isNotNull);
      expect(conversation.title, equals('Test Conversation'));
      expect(conversation.prophetType, equals('mystic_prophet'));
      expect(conversation.isAIEnabled, isTrue);
      expect(conversation.messageCount, equals(0));

      final retrieved = await storageService.getConversation(conversation.id!);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals(conversation.title));
    });

    test('should add messages to conversation', () async {
      final conversation = await storageService.createConversation(
        title: 'Test Chat',
        prophetType: 'chaotic_prophet',
      );

      // Add user message
      final userMessage = await storageService.addMessage(
        conversationId: conversation.id!,
        content: 'Hello, oracle!',
        sender: MessageSender.user,
      );

      expect(userMessage.id, isNotNull);
      expect(userMessage.content, equals('Hello, oracle!'));
      expect(userMessage.sender, equals(MessageSender.user));

      // Add prophet response
      final prophetMessage = await storageService.addMessage(
        conversationId: conversation.id!,
        content: 'Greetings, seeker of chaos!',
        sender: MessageSender.prophet,
        isAIGenerated: true,
      );

      expect(prophetMessage.id, isNotNull);
      expect(prophetMessage.sender, equals(MessageSender.prophet));
      expect(prophetMessage.isAIGenerated, isTrue);

      // Retrieve all messages
      final messages = await storageService.getConversationMessages(conversation.id!);
      expect(messages.length, equals(2));
      expect(messages[0].sender, equals(MessageSender.user));
      expect(messages[1].sender, equals(MessageSender.prophet));
    });

    test('should update message feedback', () async {
      final conversation = await storageService.createConversation(
        title: 'Feedback Test',
        prophetType: 'cynical_prophet',
      );

      final message = await storageService.addMessage(
        conversationId: conversation.id!,
        content: 'Test response',
        sender: MessageSender.prophet,
      );

      expect(message.feedbackType, isNull);

      await storageService.updateMessageFeedback(
        messageId: message.id!,
        feedbackType: FeedbackType.positive,
      );

      final messages = await storageService.getConversationMessages(conversation.id!);
      expect(messages.first.feedbackType, equals(FeedbackType.positive));
    });

    test('should retrieve conversations ordered by most recent', () async {
      // Create multiple conversations
      await storageService.createConversation(
        title: 'First Conversation',
        prophetType: 'mystic_prophet',
      );

      // Add a small delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 10));

      await storageService.createConversation(
        title: 'Second Conversation',
        prophetType: 'chaotic_prophet',
      );

      final conversations = await storageService.getAllConversations();
      
      expect(conversations.length, greaterThanOrEqualTo(2));
      // Most recent should be first
      expect(conversations[0].title, equals('Second Conversation'));
    });

    test('should search conversations', () async {
      await storageService.createConversation(
        title: 'Mystic Wisdom Chat',
        prophetType: 'mystic_prophet',
      );

      await storageService.createConversation(
        title: 'Chaotic Fun Times',
        prophetType: 'chaotic_prophet',
      );

      final mysticResults = await storageService.searchConversations('Mystic');
      expect(mysticResults.length, equals(1));
      expect(mysticResults.first.title.contains('Mystic'), isTrue);

      final chatResults = await storageService.searchConversations('Chat');
      expect(chatResults.length, equals(1));
      expect(chatResults.first.title.contains('Chat'), isTrue);
    });

    test('should get conversation count', () async {
      final initialCount = await storageService.getConversationCount();

      await storageService.createConversation(
        title: 'Count Test',
        prophetType: 'mystic_prophet',
      );

      final newCount = await storageService.getConversationCount();
      expect(newCount, equals(initialCount + 1));
    });
  });
}
