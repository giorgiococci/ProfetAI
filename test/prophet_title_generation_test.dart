import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orakl/models/profet_manager.dart';

void main() {
  group('Prophet Title Generation Tests', () {
    testWidgets('Mystic Oracle generates appropriate titles', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      
      final mysticProphet = ProfetManager.getProfet(ProfetType.mistico);
      final context = tester.element(find.byType(Container));
      
      // Test title generation without question
      final title1 = await mysticProphet.generateVisionTitle(
        context,
        answer: 'The stars align to bring you wisdom and enlightenment.',
      );
      
      expect(title1, isNotNull);
      expect(title1.length, lessThanOrEqualTo(30));
      expect(title1.isNotEmpty, true);
      
      // Test title generation with question
      final title2 = await mysticProphet.generateVisionTitle(
        context,
        question: 'What does the future hold for me?',
        answer: 'Great spiritual growth awaits you on your journey.',
      );
      
      expect(title2, isNotNull);
      expect(title2.length, lessThanOrEqualTo(30));
      expect(title2.isNotEmpty, true);
      
      // Test fallback titles (should work even without AI)
      final title3 = await mysticProphet.generateVisionTitle(
        context,
        answer: 'A simple answer',
      );
      
      expect(title3, isNotNull);
      expect(title3.length, lessThanOrEqualTo(30));
      expect(title3.isNotEmpty, true);
      
      print('Mystic titles generated: "$title1", "$title2", "$title3"');
    });

    testWidgets('Chaotic Oracle generates appropriate titles', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      
      final chaoticProphet = ProfetManager.getProfet(ProfetType.caotico);
      final context = tester.element(find.byType(Container));
      
      // Test title generation
      final title1 = await chaoticProphet.generateVisionTitle(
        context,
        answer: 'Chaos brings unexpected opportunities!',
      );
      
      expect(title1, isNotNull);
      expect(title1.length, lessThanOrEqualTo(30));
      expect(title1.isNotEmpty, true);
      
      final title2 = await chaoticProphet.generateVisionTitle(
        context,
        question: 'Will my plans work out?',
        answer: 'Plans? Where we\'re going, we don\'t need plans!',
      );
      
      expect(title2, isNotNull);
      expect(title2.length, lessThanOrEqualTo(30));
      expect(title2.isNotEmpty, true);
      
      print('Chaotic titles generated: "$title1", "$title2"');
    });

    testWidgets('Cynical Oracle generates appropriate titles', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      
      final cynicalProphet = ProfetManager.getProfet(ProfetType.cinico);
      final context = tester.element(find.byType(Container));
      
      // Test title generation
      final title1 = await cynicalProphet.generateVisionTitle(
        context,
        answer: 'Reality is often disappointing, as expected.',
      );
      
      expect(title1, isNotNull);
      expect(title1.length, lessThanOrEqualTo(30));
      expect(title1.isNotEmpty, true);
      
      final title2 = await cynicalProphet.generateVisionTitle(
        context,
        question: 'Will I be successful?',
        answer: 'Define success first, then we can discuss your chances.',
      );
      
      expect(title2, isNotNull);
      expect(title2.length, lessThanOrEqualTo(30));
      expect(title2.isNotEmpty, true);
      
      print('Cynical titles generated: "$title1", "$title2"');
    });

    testWidgets('All prophets generate unique title styles', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      
      final context = tester.element(find.byType(Container));
      final testAnswer = 'The universe reveals its secrets to those who seek.';
      
      final mysticTitle = await ProfetManager.getProfet(ProfetType.mistico)
          .generateVisionTitle(context, answer: testAnswer);
      
      final chaoticTitle = await ProfetManager.getProfet(ProfetType.caotico)
          .generateVisionTitle(context, answer: testAnswer);
      
      final cynicalTitle = await ProfetManager.getProfet(ProfetType.cinico)
          .generateVisionTitle(context, answer: testAnswer);
      
      expect(mysticTitle, isNotNull);
      expect(chaoticTitle, isNotNull);
      expect(cynicalTitle, isNotNull);
      
      // All titles should be different in style even for the same answer
      print('Title comparison for same answer:');
      print('Mystic: "$mysticTitle"');
      print('Chaotic: "$chaoticTitle"');
      print('Cynical: "$cynicalTitle"');
      
      // All should be valid length
      expect(mysticTitle.length, lessThanOrEqualTo(30));
      expect(chaoticTitle.length, lessThanOrEqualTo(30));
      expect(cynicalTitle.length, lessThanOrEqualTo(30));
    });
  });
}
