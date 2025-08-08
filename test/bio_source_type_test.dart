/// Test script to verify the new insight source type functionality
/// 
/// This script demonstrates the separation between USER and PROPHET insights
/// and verifies that bio generation only uses USER insights
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/bio/bio_storage_service.dart';
import '../lib/services/bio/bio_generation_service.dart';
import '../lib/utils/privacy/privacy_levels.dart';
import '../lib/utils/bio/insight_source_type.dart';

void main() {
  group('Bio System with Source Type Separation', () {
    late BioStorageService bioStorage;
    late BioGenerationService bioGeneration;
    
    setUpAll(() async {
      bioStorage = BioStorageService();
      bioGeneration = BioGenerationService.instance;
      await bioGeneration.initialize();
    });

    test('Should distinguish between USER and PROPHET insights', () async {
      // Clear any existing data
      await bioStorage.deleteAllUserBioData(userId: 'test_user');
      
      // Add USER insights (from user questions/statements)
      await bioStorage.addInsight(
        content: 'User is interested in learning about meditation',
        category: 'interests', 
        sourceQuestionId: 'q1',
        sourceAnswer: 'Here is guidance on meditation...',
        extractedFrom: 'user_question_analysis',
        privacyLevel: PrivacyLevel.personal,
        sourceType: InsightSourceType.user,
        userId: 'test_user',
      );
      
      await bioStorage.addInsight(
        content: 'User has experience with programming',
        category: 'background',
        sourceQuestionId: 'q2', 
        sourceAnswer: 'Programming wisdom...',
        extractedFrom: 'user_question_analysis',
        privacyLevel: PrivacyLevel.personal,
        sourceType: InsightSourceType.user,
        userId: 'test_user',
      );
      
      // Add PROPHET insights (inferred from prophet responses)
      await bioStorage.addInsight(
        content: 'Prophet suggests user needs more patience',
        category: 'prophet_advice',
        sourceQuestionId: 'q1',
        sourceAnswer: 'Here is guidance on meditation...',
        extractedFrom: 'prophet_response_analysis', 
        privacyLevel: PrivacyLevel.personal,
        sourceType: InsightSourceType.prophet,
        userId: 'test_user',
      );
      
      // Verify insights were stored correctly
      final userBio = await bioStorage.getUserBio(userId: 'test_user');
      expect(userBio, isNotNull);
      expect(userBio!.insights.length, equals(3));
      
      // Verify source types are correct
      final userInsights = userBio.insights.where((i) => i.sourceType == InsightSourceType.user).toList();
      final prophetInsights = userBio.insights.where((i) => i.sourceType == InsightSourceType.prophet).toList();
      
      expect(userInsights.length, equals(2));
      expect(prophetInsights.length, equals(1));
      
      print('✓ Successfully distinguished USER (${userInsights.length}) and PROPHET (${prophetInsights.length}) insights');
    });
    
    test('Bio generation should only use USER insights', () async {
      // Generate bio using both user and prophet insights
      await bioGeneration.generateBioOnDemand(userId: 'test_user');
      
      // Check the generated bio
      final generatedBio = await bioStorage.getGeneratedBio(userId: 'test_user');
      expect(generatedBio, isNotNull);
      
      // Verify only USER insights were used (should be 2, not 3)
      expect(generatedBio!.totalInsightsUsed, equals(2));
      
      // Check that bio content contains user-derived information, not prophet suggestions
      final bioContent = generatedBio.sections.values.join(' ').toLowerCase();
      expect(bioContent.contains('meditation') || bioContent.contains('programming'), isTrue);
      expect(bioContent.contains('patience'), isFalse); // Prophet advice should not appear
      
      print('✓ Bio generation correctly used only ${generatedBio.totalInsightsUsed} USER insights');
      print('✓ Prophet suggestions were excluded from bio content');
    });
    
    test('Source type display names work correctly', () {
      expect(InsightSourceType.user.displayName, equals('User Statement'));
      expect(InsightSourceType.prophet.displayName, equals('Prophet Interaction'));
      
      expect(InsightSourceType.user.shouldUseInBio, isTrue);
      expect(InsightSourceType.prophet.shouldUseInBio, isFalse);
      
      print('✓ Source type display names and bio usage flags are correct');
    });
    
    tearDownAll(() async {
      // Clean up test data
      await bioStorage.deleteAllUserBioData(userId: 'test_user');
      print('✓ Test data cleaned up successfully');
    });
  });
}
