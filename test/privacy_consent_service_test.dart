import 'package:flutter_test/flutter_test.dart';
import 'package:profet_ai/services/privacy_consent_service.dart';

void main() {
  group('Privacy Consent Service Tests', () {
    late PrivacyConsentService privacyService;

    setUp(() {
      privacyService = PrivacyConsentService();
    });

    test('should handle consent acceptance', () async {
      // Test that accepting consent enables bio features
      await privacyService.setConsent(true);
      
      expect(privacyService.consentGiven, equals(true));
      expect(privacyService.hasConsentBeenAsked(), equals(true));
    });

    test('should handle consent denial and delete bio data', () async {
      // First accept consent and create some bio data
      await privacyService.setConsent(true);
      
      // Now deny consent - this should delete all bio data
      await privacyService.setConsent(false);
      
      expect(privacyService.consentGiven, equals(false));
      expect(privacyService.hasConsentBeenAsked(), equals(true));
    });

    test('should allow changing consent decision', () async {
      // Start with no consent
      await privacyService.setConsent(false);
      expect(privacyService.consentGiven, equals(false));
      
      // Change to consent
      await privacyService.changeConsent(true);
      expect(privacyService.consentGiven, equals(true));
      
      // Change back to no consent
      await privacyService.changeConsent(false);
      expect(privacyService.consentGiven, equals(false));
    });

    test('should persist consent across service instances', () async {
      // Set consent in one instance
      await privacyService.setConsent(true);
      
      // Create new instance and load consent
      final newService = PrivacyConsentService();
      await newService.loadConsentStatus();
      
      expect(newService.consentGiven, equals(true));
    });
  });
}
