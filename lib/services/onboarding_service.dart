import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _onboardingCompleteBackupKey = 'onboarding_complete_backup';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Singleton pattern
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  /// Check if onboarding has been completed using both storage methods for reliability
  Future<bool> isOnboardingComplete() async {
    try {
      // First try FlutterSecureStorage (primary method)
      final secureValue = await _storage.read(key: _onboardingCompleteKey);
      print('OnboardingService: Secure storage value: $secureValue');
      
      // Also check SharedPreferences as backup
      final prefs = await SharedPreferences.getInstance();
      final backupValue = prefs.getBool(_onboardingCompleteBackupKey) ?? false;
      print('OnboardingService: Backup storage value: $backupValue');
      
      // If either storage indicates completion, consider it complete
      final isComplete = (secureValue == 'true') || backupValue;
      print('OnboardingService: Final completion status: $isComplete');
      
      return isComplete;
    } catch (e) {
      print('OnboardingService: Error checking onboarding status: $e');
      // If there's an error, try just SharedPreferences as ultimate fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final backupValue = prefs.getBool(_onboardingCompleteBackupKey) ?? false;
        print('OnboardingService: Fallback check result: $backupValue');
        return backupValue;
      } catch (e2) {
        print('OnboardingService: Backup check also failed: $e2');
        return false;
      }
    }
  }

  /// Mark onboarding as completed in both storage methods
  Future<void> completeOnboarding() async {
    print('OnboardingService: Starting onboarding completion...');
    
    bool secureStorageSuccess = false;
    bool sharedPrefsSuccess = false;
    
    // Try to save in FlutterSecureStorage
    try {
      await _storage.write(key: _onboardingCompleteKey, value: 'true');
      
      // Verify the write was successful
      final verification = await _storage.read(key: _onboardingCompleteKey);
      if (verification == 'true') {
        print('OnboardingService: ✅ Secure storage write successful');
        secureStorageSuccess = true;
      } else {
        print('OnboardingService: ❌ Secure storage verification failed - Expected "true", got "$verification"');
      }
    } catch (e) {
      print('OnboardingService: ❌ Secure storage write failed: $e');
    }
    
    // Try to save in SharedPreferences as backup
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteBackupKey, true);
      
      // Verify the backup write
      final backupVerification = prefs.getBool(_onboardingCompleteBackupKey) ?? false;
      if (backupVerification) {
        print('OnboardingService: ✅ Backup storage write successful');
        sharedPrefsSuccess = true;
      } else {
        print('OnboardingService: ❌ Backup storage verification failed');
      }
    } catch (e) {
      print('OnboardingService: ❌ Backup storage write failed: $e');
    }
    
    // Ensure at least one storage method worked
    if (!secureStorageSuccess && !sharedPrefsSuccess) {
      print('OnboardingService: 🚨 CRITICAL ERROR - Both storage methods failed!');
      throw Exception('Failed to persist onboarding completion in both storage methods');
    }
    
    print('OnboardingService: ✅ Onboarding completion saved successfully (Secure: $secureStorageSuccess, Backup: $sharedPrefsSuccess)');
  }

  /// Debug method to check detailed storage status
  Future<Map<String, dynamic>> getStorageStatus() async {
    final status = <String, dynamic>{};
    
    try {
      final secureValue = await _storage.read(key: _onboardingCompleteKey);
      status['secureStorage'] = {
        'value': secureValue,
        'isComplete': secureValue == 'true',
      };
    } catch (e) {
      status['secureStorage'] = {
        'error': e.toString(),
        'isComplete': false,
      };
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupValue = prefs.getBool(_onboardingCompleteBackupKey);
      status['backupStorage'] = {
        'value': backupValue,
        'isComplete': backupValue == true,
      };
    } catch (e) {
      status['backupStorage'] = {
        'error': e.toString(),
        'isComplete': false,
      };
    }
    
    final overallComplete = await isOnboardingComplete();
    status['overall'] = {
      'isComplete': overallComplete,
    };
    
    return status;
  }

  /// Reset onboarding in both storage methods
  Future<void> resetOnboarding() async {
    print('OnboardingService: Resetting onboarding status...');
    
    try {
      await _storage.delete(key: _onboardingCompleteKey);
      print('OnboardingService: ✅ Secure storage cleared');
    } catch (e) {
      print('OnboardingService: ❌ Error clearing secure storage: $e');
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompleteBackupKey);
      print('OnboardingService: ✅ Backup storage cleared');
    } catch (e) {
      print('OnboardingService: ❌ Error clearing backup storage: $e');
    }
    
    print('OnboardingService: ✅ Onboarding reset complete');
  }
}
