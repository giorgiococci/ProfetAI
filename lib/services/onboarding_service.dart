import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Singleton pattern
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  /// Check if onboarding has been completed
  Future<bool> isOnboardingComplete() async {
    try {
      final value = await _storage.read(key: _onboardingCompleteKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      await _storage.write(key: _onboardingCompleteKey, value: 'true');
    } catch (e) {
      // Silently handle storage errors
    }
  }

  /// Reset onboarding (useful for testing)
  Future<void> resetOnboarding() async {
    try {
      await _storage.delete(key: _onboardingCompleteKey);
    } catch (e) {
      // Silently handle storage errors
    }
  }
}
