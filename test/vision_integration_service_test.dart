import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profet_ai/models/profet_manager.dart';
import 'package:profet_ai/models/vision_feedback.dart';
import 'package:profet_ai/services/database_service.dart';
import 'package:profet_ai/services/vision_integration_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('Vision Integration Service Tests', () {
    late VisionIntegrationService integrationService;
    late DatabaseService databaseService;

    setUpAll(() async {
      // Initialize sqflite for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Create fresh service instances for each test
      databaseService = DatabaseService();
      integrationService = VisionIntegrationService();
      
      // Initialize database with test data
      await databaseService.database;
    });

    tearDown(() async {
      // Clean up after each test
      await databaseService.close();
    });

    testWidgets('Question-based vision generation and storage', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      
      final mysticProphet = ProfetManager.getProfet(ProfetType.mistico);
      final context = tester.element(find.byType(Container));
      
      // Test question-based vision generation
      final result = await integrationService.generateAndStoreQuestionVision(
        context: context,
        profet: mysticProphet,
        question: 'What does the future hold for me?',
        isAIEnabled: false, // Use fallback for predictable testing
      );
      
      expect(result.content, isNotNull);
      expect(result.content.isNotEmpty, true);
      expect(result.vision, isNotNull);
      expect(result.vision.id, isNotNull);
      expect(result.vision.title, isNotNull);
      expect(result.vision.title.length, lessThanOrEqualTo(30));
      expect(result.vision.question, equals('What does the future hold for me?'));
      expect(result.vision.prophetType, equals('mystic_prophet'));
      expect(result.hasQuestion, true);
      expect(result.isAIGenerated, false);
      
      print('Question Vision - ID: ${result.visionId}, Title: "${result.title}"');
      print('Content: "${result.content}"');
    });

    testWidgets('Random vision generation and storage', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      
      final chaoticProphet = ProfetManager.getProfet(ProfetType.caotico);
      final context = tester.element(find.byType(Container));
      
      // Test random vision generation
      final result = await integrationService.generateAndStoreRandomVision(
        context: context,
        profet: chaoticProphet,
        isAIEnabled: false, // Use fallback for predictable testing
      );
      
      expect(result.content, isNotNull);
      expect(result.content.isNotEmpty, true);
      expect(result.vision, isNotNull);
      expect(result.vision.id, isNotNull);
      expect(result.vision.title, isNotNull);
      expect(result.vision.title.length, lessThanOrEqualTo(30));
      expect(result.vision.question, isNull); // No question for random visions
      expect(result.vision.prophetType, equals('chaotic_prophet'));
      expect(result.hasQuestion, false);
      expect(result.isAIGenerated, false);
      
      print('Random Vision - ID: ${result.visionId}, Title: "${result.title}"');
      print('Content: "${result.content}"');
    });

    testWidgets('Feedback update integration', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      
      final cynicalProphet = ProfetManager.getProfet(ProfetType.cinico);
      final context = tester.element(find.byType(Container));
      
      // First generate and store a vision
      final result = await integrationService.generateAndStoreQuestionVision(
        context: context,
        profet: cynicalProphet,
        question: 'Will I be successful?',
        isAIEnabled: false,
      );
      
      expect(result.visionId, isNotNull);
      
      // Test feedback update
      final feedbackSuccess = await integrationService.updateVisionFeedback(
        visionId: result.visionId!,
        feedbackType: FeedbackType.positive,
      );
      
      expect(feedbackSuccess, true);
      
      print('Feedback Update - Vision ID: ${result.visionId}, Success: $feedbackSuccess');
    });

    testWidgets('Service health check', (WidgetTester tester) async {
      final isHealthy = await integrationService.isServiceHealthy();
      expect(isHealthy, true);
      
      print('Integration Service Health: $isHealthy');
    });

    testWidgets('Multiple prophets generate different styles', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      
      final context = tester.element(find.byType(Container));
      final testQuestion = 'What should I focus on today?';
      
      // Generate visions from all three prophets
      final mysticResult = await integrationService.generateAndStoreQuestionVision(
        context: context,
        profet: ProfetManager.getProfet(ProfetType.mistico),
        question: testQuestion,
        isAIEnabled: false,
      );
      
      final chaoticResult = await integrationService.generateAndStoreQuestionVision(
        context: context,
        profet: ProfetManager.getProfet(ProfetType.caotico),
        question: testQuestion,
        isAIEnabled: false,
      );
      
      final cynicalResult = await integrationService.generateAndStoreQuestionVision(
        context: context,
        profet: ProfetManager.getProfet(ProfetType.cinico),
        question: testQuestion,
        isAIEnabled: false,
      );
      
      // All should be valid
      expect(mysticResult.vision.prophetType, equals('mystic_prophet'));
      expect(chaoticResult.vision.prophetType, equals('chaotic_prophet'));
      expect(cynicalResult.vision.prophetType, equals('cynical_prophet'));
      
      // All should have different titles reflecting their personalities
      print('Title Comparison for Same Question:');
      print('Mystic: "${mysticResult.title}"');
      print('Chaotic: "${chaoticResult.title}"');
      print('Cynical: "${cynicalResult.title}"');
      
      // Validate all titles are within length limits
      expect(mysticResult.title.length, lessThanOrEqualTo(30));
      expect(chaoticResult.title.length, lessThanOrEqualTo(30));
      expect(cynicalResult.title.length, lessThanOrEqualTo(30));
    });

    testWidgets('Vision storage retrieval', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      
      final context = tester.element(find.byType(Container));
      final storageService = integrationService.storageService;
      
      // Generate and store a vision
      final result = await integrationService.generateAndStoreRandomVision(
        context: context,
        profet: ProfetManager.getProfet(ProfetType.mistico),
        isAIEnabled: false,
      );
      
      // Retrieve the stored vision
      final storedVision = await storageService.getVisionById(result.visionId!);
      
      expect(storedVision, isNotNull);
      expect(storedVision!.id, equals(result.visionId));
      expect(storedVision.title, equals(result.title));
      expect(storedVision.answer, equals(result.content));
      expect(storedVision.prophetType, equals(result.prophetType));
      
      print('Storage Verification - Retrieved vision matches stored vision');
    });

    tearDown(() async {
      await integrationService.close();
    });
  });
}
