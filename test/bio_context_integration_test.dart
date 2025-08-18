import 'package:flutter_test/flutter_test.dart';
import 'package:profet_ai/services/bio/bio_context_service.dart';
import 'package:profet_ai/models/oracolo_mistico.dart';

void main() {
  group('Phase 3 - Bio Context Integration Tests', () {
    late BioContextService bioContextService;

    setUp(() {
      bioContextService = BioContextService();
    });

    test('BioContextService initializes correctly', () {
      expect(bioContextService, isNotNull);
      expect(bioContextService, isA<BioContextService>());
    });

    test('BioContextService follows singleton pattern', () {
      final service1 = BioContextService();
      final service2 = BioContextService();
      expect(identical(service1, service2), true, 
        reason: 'BioContextService should be a singleton');
    });

    test('generatePersonalizedContext handles missing data gracefully', () async {
      // Test with a concrete prophet implementation
      final testProfet = OracoloMistico();
      
      try {
        final context = await bioContextService.generatePersonalizedContext(
          profet: testProfet,
          userQuestion: 'What is the meaning of life?',
          userId: 'test-user-id',
          maxInsights: 3,
        );
        
        // Should return null when no insights available (graceful degradation)
        expect(context, isNull);
      } catch (e) {
        fail('generatePersonalizedContext should handle missing data gracefully: $e');
      }
    });

    test('getUserInterestsSummary handles missing data gracefully', () async {
      try {
        final summary = await bioContextService.getUserInterestsSummary(
          userId: 'test-user-id',
          maxInterests: 5,
        );
        
        // Should return null when no insights available (graceful degradation)
        expect(summary, isNull);
      } catch (e) {
        fail('getUserInterestsSummary should handle missing data gracefully: $e');
      }
    });

    test('getUserEngagementPatterns handles missing data gracefully', () async {
      try {
        final patterns = await bioContextService.getUserEngagementPatterns(
          userId: 'test-user-id',
        );
        
        // Should return null when insufficient data available
        expect(patterns, isNull);
      } catch (e) {
        fail('getUserEngagementPatterns should handle missing data gracefully: $e');
      }
    });
  });

  group('Phase 3 - Enhanced Profet Methods', () {
    test('Profet enhanced methods exist and are accessible', () {
      final profet = OracoloMistico();
      
      // Check that enhanced methods exist (they should not throw compilation errors)
      expect(() => profet.getAIPersonalizedResponseWithContext, returnsNormally);
      expect(() => profet.getAIRandomVisionWithContext, returnsNormally);
    });
  });
}
