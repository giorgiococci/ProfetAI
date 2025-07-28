import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:profet_ai/services/vision_storage_service.dart';
import 'package:profet_ai/models/vision.dart';
import 'package:profet_ai/models/vision_feedback.dart';

void main() {
  group('VisionStorageService Tests', () {
    late VisionStorageService visionService;

    setUpAll(() async {
      // Initialize sqflite for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      visionService = VisionStorageService();
      
      // Ensure clean state
      await visionService.deleteAllVisions();
    });

    tearDown(() async {
      await visionService.close();
    });

    test('should store vision successfully', () async {
      final vision = await visionService.storeVision(
        title: 'Test Vision',
        question: 'What is the meaning of life?',
        answer: 'The answer is 42',
        prophetType: 'mystic_prophet',
        feedbackType: FeedbackType.positive,
        isAIGenerated: true,
      );

      expect(vision.id, isNotNull);
      expect(vision.title, equals('Test Vision'));
      expect(vision.question, equals('What is the meaning of life?'));
      expect(vision.answer, equals('The answer is 42'));
      expect(vision.prophetType, equals('mystic_prophet'));
      expect(vision.feedbackType, equals(FeedbackType.positive));
      expect(vision.isAIGenerated, isTrue);
    });

    test('should retrieve visions with pagination', () async {
      // Store multiple visions with slight delay to ensure proper ordering
      for (int i = 1; i <= 5; i++) {
        await visionService.storeVision(
          title: 'Vision $i',
          answer: 'Answer $i',
          prophetType: 'mystic_prophet',
        );
        // Small delay to ensure different timestamps
        await Future.delayed(Duration(milliseconds: 10));
      }

      // Get first page
      final firstPage = await visionService.getVisions(
        offset: 0,
        limit: 3,
      );

      expect(firstPage.length, equals(3));
      // Most recent first (Vision 5 should be first)
      expect(firstPage.map((v) => v.title).toList(), contains('Vision 5'));

      // Get second page
      final secondPage = await visionService.getVisions(
        offset: 3,
        limit: 3,
      );

      expect(secondPage.length, equals(2));
    });

    test('should filter visions by prophet type', () async {
      // Store visions with different prophets
      await visionService.storeVision(
        title: 'Mystic Vision',
        answer: 'Mystic answer',
        prophetType: 'mystic_prophet',
      );
      
      await visionService.storeVision(
        title: 'Chaotic Vision',
        answer: 'Chaotic answer',
        prophetType: 'chaotic_prophet',
      );

      final filter = VisionFilter(prophetType: 'mystic_prophet');
      final filteredVisions = await visionService.getVisions(filter: filter);

      expect(filteredVisions.length, equals(1));
      expect(filteredVisions.first.title, equals('Mystic Vision'));
    });

    test('should filter visions by feedback type', () async {
      await visionService.storeVision(
        title: 'Positive Vision',
        answer: 'Great answer',
        prophetType: 'mystic_prophet',
        feedbackType: FeedbackType.positive,
      );
      
      await visionService.storeVision(
        title: 'Negative Vision',
        answer: 'Bad answer',
        prophetType: 'mystic_prophet',
        feedbackType: FeedbackType.negative,
      );

      final filter = VisionFilter(feedbackType: FeedbackType.positive);
      final filteredVisions = await visionService.getVisions(filter: filter);

      expect(filteredVisions.length, equals(1));
      expect(filteredVisions.first.title, equals('Positive Vision'));
    });

    test('should filter visions by question presence', () async {
      await visionService.storeVision(
        title: 'With Question',
        question: 'What should I do?',
        answer: 'Follow your heart',
        prophetType: 'mystic_prophet',
      );
      
      await visionService.storeVision(
        title: 'Random Vision',
        answer: 'Random wisdom',
        prophetType: 'mystic_prophet',
      );

      // Filter for visions with questions
      final withQuestions = await visionService.getVisions(
        filter: VisionFilter(hasQuestion: true),
      );
      expect(withQuestions.length, equals(1));
      expect(withQuestions.first.title, equals('With Question'));

      // Filter for random visions
      final withoutQuestions = await visionService.getVisions(
        filter: VisionFilter(hasQuestion: false),
      );
      expect(withoutQuestions.length, equals(1));
      expect(withoutQuestions.first.title, equals('Random Vision'));
    });

    test('should search visions using full-text search', () async {
      await visionService.storeVision(
        title: 'Love and Peace',
        question: 'How to find love?',
        answer: 'Love comes from within',
        prophetType: 'mystic_prophet',
      );
      
      await visionService.storeVision(
        title: 'War and Conflict',
        answer: 'Sometimes conflict is necessary',
        prophetType: 'cynical_prophet',
      );

      final searchResults = await visionService.searchVisions(
        searchQuery: 'love',
      );

      expect(searchResults.length, equals(1));
      expect(searchResults.first.title, equals('Love and Peace'));
    });

    test('should update vision feedback', () async {
      final vision = await visionService.storeVision(
        title: 'Test Vision',
        answer: 'Test answer',
        prophetType: 'mystic_prophet',
      );

      final success = await visionService.updateVisionFeedback(
        vision.id!,
        FeedbackType.funny,
      );

      expect(success, isTrue);

      final updatedVision = await visionService.getVisionById(vision.id!);
      expect(updatedVision?.feedbackType, equals(FeedbackType.funny));
    });

    test('should delete vision by ID', () async {
      final vision = await visionService.storeVision(
        title: 'To Delete',
        answer: 'Will be deleted',
        prophetType: 'mystic_prophet',
      );

      final success = await visionService.deleteVision(vision.id!);
      expect(success, isTrue);

      final deletedVision = await visionService.getVisionById(vision.id!);
      expect(deletedVision, isNull);
    });

    test('should get vision count', () async {
      // Store some visions
      await visionService.storeVision(
        title: 'Vision 1',
        answer: 'Answer 1',
        prophetType: 'mystic_prophet',
      );
      
      await visionService.storeVision(
        title: 'Vision 2',
        answer: 'Answer 2',
        prophetType: 'chaotic_prophet',
      );

      final totalCount = await visionService.getVisionCount();
      expect(totalCount, equals(2));

      final mysticCount = await visionService.getVisionCount(
        filter: VisionFilter(prophetType: 'mystic_prophet'),
      );
      expect(mysticCount, equals(1));
    });

    test('should get vision statistics', () async {
      // Store test data
      await visionService.storeVision(
        title: 'Mystic Vision',
        question: 'Test question',
        answer: 'Mystic answer',
        prophetType: 'mystic_prophet',
        feedbackType: FeedbackType.positive,
      );
      
      await visionService.storeVision(
        title: 'Chaotic Vision',
        answer: 'Chaotic answer',
        prophetType: 'chaotic_prophet',
        feedbackType: FeedbackType.negative,
      );

      final stats = await visionService.getVisionStatistics();

      expect(stats['total'], equals(2));
      expect(stats['prophetStats'], isNotEmpty);
      expect(stats['feedbackStats'], isNotEmpty);
      expect(stats['questionStats'], isNotEmpty);
      expect(stats['recentVisions'], isNotEmpty);
    });

    test('should handle service health check', () async {
      final isHealthy = await visionService.isServiceHealthy();
      expect(isHealthy, isTrue);
    });
  });
}
