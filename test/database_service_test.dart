import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:profet_ai/services/database_service.dart';
import 'package:profet_ai/models/vision.dart';
import 'package:profet_ai/models/vision_feedback.dart';

void main() {
  group('DatabaseService Tests', () {
    late DatabaseService databaseService;

    setUpAll(() async {
      // Initialize sqflite for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      databaseService = DatabaseService();
    });

    tearDown(() async {
      await databaseService.close();
    });

    test('should initialize database successfully', () async {
      final database = await databaseService.database;
      expect(database, isNotNull);
      
      final isHealthy = await databaseService.isDatabaseHealthy();
      expect(isHealthy, isTrue);
    });

    test('should get database statistics', () async {
      final stats = await databaseService.getDatabaseStats();
      expect(stats, isNotEmpty);
      expect(stats['totalVisions'], equals(0));
    });

    test('should handle database reset', () async {
      // Initialize database first
      await databaseService.database;
      
      // Reset database
      await databaseService.resetDatabase();
      
      // Verify it's still healthy
      final isHealthy = await databaseService.isDatabaseHealthy();
      expect(isHealthy, isTrue);
    });
  });
}
