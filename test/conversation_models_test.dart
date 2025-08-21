import 'package:flutter_test/flutter_test.dart';
import 'package:orakl/models/conversation/conversation.dart';
import 'package:orakl/models/conversation/conversation_message.dart';
import 'package:orakl/models/vision_feedback.dart';

void main() {
  group('Conversation Model Tests', () {
    test('should create conversation with required fields', () {
      final now = DateTime.now();
      final conversation = Conversation(
        title: 'Test Conversation',
        prophetType: 'mystic_prophet',
        startedAt: now,
        lastUpdatedAt: now,
        messageCount: 0,
      );

      expect(conversation.title, equals('Test Conversation'));
      expect(conversation.prophetType, equals('mystic_prophet'));
      expect(conversation.messageCount, equals(0));
      expect(conversation.status, equals(ConversationStatus.active));
    });

    test('should serialize to and from map correctly', () {
      final now = DateTime.now();
      final original = Conversation(
        id: 1,
        title: 'Test Conversation',
        prophetType: 'mystic_prophet',
        startedAt: now,
        lastUpdatedAt: now,
        messageCount: 5,
        status: ConversationStatus.completed,
        isAIEnabled: true,
      );

      final map = original.toMap();
      final deserialized = Conversation.fromMap(map);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.title, equals(original.title));
      expect(deserialized.prophetType, equals(original.prophetType));
      expect(deserialized.messageCount, equals(original.messageCount));
      expect(deserialized.status, equals(original.status));
      expect(deserialized.isAIEnabled, equals(original.isAIEnabled));
    });

    test('should get correct prophet display name', () {
      final conversation = Conversation(
        title: 'Test',
        prophetType: 'mystic_prophet',
        startedAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        messageCount: 0,
      );

      expect(conversation.prophetDisplayName, equals('The Mystic Oracle'));
    });

    test('should calculate duration correctly', () {
      final start = DateTime.now();
      final end = start.add(const Duration(hours: 1, minutes: 30));
      
      final conversation = Conversation(
        title: 'Test',
        prophetType: 'mystic_prophet',
        startedAt: start,
        lastUpdatedAt: end,
        messageCount: 0,
      );

      expect(conversation.duration.inMinutes, equals(90));
    });
  });

  group('ConversationMessage Model Tests', () {
    test('should create user message correctly', () {
      final message = ConversationMessage.userMessage(
        conversationId: 1,
        content: 'Hello, oracle!',
      );

      expect(message.conversationId, equals(1));
      expect(message.content, equals('Hello, oracle!'));
      expect(message.sender, equals(MessageSender.user));
      expect(message.isUserMessage, isTrue);
      expect(message.isProphetMessage, isFalse);
      expect(message.isAIGenerated, isFalse);
    });

    test('should create prophet message correctly', () {
      final message = ConversationMessage.prophetMessage(
        conversationId: 1,
        content: 'Greetings, seeker.',
        isAIGenerated: true,
      );

      expect(message.conversationId, equals(1));
      expect(message.content, equals('Greetings, seeker.'));
      expect(message.sender, equals(MessageSender.prophet));
      expect(message.isUserMessage, isFalse);
      expect(message.isProphetMessage, isTrue);
      expect(message.isAIGenerated, isTrue);
    });

    test('should serialize to and from map correctly', () {
      final now = DateTime.now();
      final original = ConversationMessage(
        id: 1,
        conversationId: 1,
        content: 'Test message',
        sender: MessageSender.user,
        timestamp: now,
        feedbackType: FeedbackType.positive,
        isAIGenerated: false,
        metadata: '{"test": "data"}',
      );

      final map = original.toMap();
      final deserialized = ConversationMessage.fromMap(map);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.conversationId, equals(original.conversationId));
      expect(deserialized.content, equals(original.content));
      expect(deserialized.sender, equals(original.sender));
      expect(deserialized.feedbackType, equals(original.feedbackType));
      expect(deserialized.isAIGenerated, equals(original.isAIGenerated));
      expect(deserialized.metadata, equals(original.metadata));
    });

    test('should generate preview correctly', () {
      final shortMessage = ConversationMessage.userMessage(
        conversationId: 1,
        content: 'Short message',
      );

      final longMessage = ConversationMessage.userMessage(
        conversationId: 1,
        content: 'This is a very long message that should be truncated when displayed as a preview in the UI' * 2,
      );

      expect(shortMessage.preview, equals('Short message'));
      expect(longMessage.preview.length, lessThanOrEqualTo(103)); // 100 + "..."
      expect(longMessage.preview.endsWith('...'), isTrue);
    });

    test('should update feedback correctly', () {
      final message = ConversationMessage.prophetMessage(
        conversationId: 1,
        content: 'Test response',
      );

      expect(message.hasFeedback, isFalse);

      final updatedMessage = message.copyWith(feedbackType: FeedbackType.funny);
      expect(updatedMessage.hasFeedback, isTrue);
      expect(updatedMessage.feedbackType, equals(FeedbackType.funny));
    });
  });
}
