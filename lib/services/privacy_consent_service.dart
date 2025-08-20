import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bio/bio_storage_service.dart';

/// Service for managing privacy consent and bio feature settings
/// 
/// This service handles:
/// - Storing user's privacy consent decision
/// - Enabling/disabling bio collection feature
/// - Managing bio feature state across app restarts
class PrivacyConsentService {
  static const String _consentKey = 'privacy_consent_given';
  static const String _consentBackupKey = 'privacy_consent_backup';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Singleton pattern
  static final PrivacyConsentService _instance = PrivacyConsentService._internal();
  factory PrivacyConsentService() => _instance;
  PrivacyConsentService._internal();

  bool? _consentGiven;
  final BioStorageService _bioStorageService = BioStorageService();

  /// Gets the current consent status
  /// Returns null if consent has not been asked yet
  bool? get consentGiven => _consentGiven;

  /// Loads the consent status from storage
  Future<void> loadConsentStatus() async {
    try {
      // Try FlutterSecureStorage first
      final consentString = await _storage.read(key: _consentKey);
      
      if (consentString != null) {
        _consentGiven = consentString == 'true';
        print('PrivacyConsentService: ✅ Consent status loaded from secure storage: $_consentGiven');
        return;
      }
      
      // If secure storage failed, try SharedPreferences backup
      final prefs = await SharedPreferences.getInstance();
      final backupConsent = prefs.getBool(_consentBackupKey);
      
      if (backupConsent != null) {
        _consentGiven = backupConsent;
        print('PrivacyConsentService: ✅ Consent status loaded from backup storage: $_consentGiven');
        return;
      }
      
      // If both failed, consent has not been given yet
      _consentGiven = null;
      print('PrivacyConsentService: No consent status found');
    } catch (e) {
      print('PrivacyConsentService: ❌ Error loading consent status: $e');
      _consentGiven = null;
    }
  }

  /// Saves the consent decision and applies bio feature settings
  Future<void> setConsent(bool consent) async {
    print('PrivacyConsentService: Setting consent to: $consent');
    
    bool secureStorageSuccess = false;
    bool sharedPrefsSuccess = false;
    
    // Save to FlutterSecureStorage
    try {
      await _storage.write(key: _consentKey, value: consent.toString());
      
      // Verify the write
      final verification = await _storage.read(key: _consentKey);
      if (verification == consent.toString()) {
        print('PrivacyConsentService: ✅ Secure storage consent write successful');
        secureStorageSuccess = true;
      } else {
        print('PrivacyConsentService: ❌ Secure storage consent verification failed');
      }
    } catch (e) {
      print('PrivacyConsentService: ❌ Secure storage consent write failed: $e');
    }
    
    // Save to SharedPreferences as backup
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_consentBackupKey, consent);
      
      // Verify the backup write
      final backupVerification = prefs.getBool(_consentBackupKey);
      if (backupVerification == consent) {
        print('PrivacyConsentService: ✅ Backup storage consent write successful');
        sharedPrefsSuccess = true;
      } else {
        print('PrivacyConsentService: ❌ Backup storage consent verification failed');
      }
    } catch (e) {
      print('PrivacyConsentService: ❌ Backup storage consent write failed: $e');
    }
    
    // Check if at least one storage method succeeded
    if (!secureStorageSuccess && !sharedPrefsSuccess) {
      throw Exception('Failed to save consent status to both secure and backup storage');
    }
    
    // Update in-memory status
    _consentGiven = consent;
    
    // Apply bio feature settings
    try {
      if (consent) {
        // Enable bio collection
        await _bioStorageService.setBioEnabled(enabled: true);
        print('PrivacyConsentService: ✅ Bio feature enabled');
      } else {
        // Disable bio collection and delete all existing bio data
        await _bioStorageService.setBioEnabled(enabled: false);
        print('PrivacyConsentService: ✅ Bio feature disabled');
        
        // Delete all existing bio data
        final deletionSuccess = await _bioStorageService.deleteAllBioData();
        if (deletionSuccess) {
          print('PrivacyConsentService: ✅ All existing bio data deleted successfully');
        } else {
          print('PrivacyConsentService: ⚠️ Warning: Failed to delete some bio data');
        }
      }
    } catch (e) {
      print('PrivacyConsentService: ❌ Error applying bio settings: $e');
      throw Exception('Failed to apply bio feature settings: $e');
    }
  }

  /// Checks if consent has been asked (regardless of the answer)
  bool hasConsentBeenAsked() {
    return _consentGiven != null;
  }

  /// Changes the existing consent decision
  /// This is different from setConsent as it allows users to change their mind
  /// and will handle data deletion accordingly
  Future<void> changeConsent(bool newConsent) async {
    if (_consentGiven == newConsent) {
      print('PrivacyConsentService: Consent already set to $newConsent, no change needed');
      return;
    }
    
    print('PrivacyConsentService: Changing consent from $_consentGiven to $newConsent');
    
    // If switching from consent to no consent, warn about data deletion
    if (_consentGiven == true && newConsent == false) {
      print('PrivacyConsentService: User revoking consent - will delete all bio data');
    }
    
    // Apply the new consent setting
    await setConsent(newConsent);
  }

  /// Resets consent status (for debugging/testing purposes)
  Future<void> resetConsent() async {
    try {
      await _storage.delete(key: _consentKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_consentBackupKey);
      _consentGiven = null;
      print('PrivacyConsentService: ✅ Consent status reset');
    } catch (e) {
      print('PrivacyConsentService: ❌ Error resetting consent: $e');
      throw Exception('Failed to reset consent status: $e');
    }
  }

  /// Gets debug information about storage status
  Future<Map<String, dynamic>> getStorageStatus() async {
    try {
      final secureStorageValue = await _storage.read(key: _consentKey);
      final prefs = await SharedPreferences.getInstance();
      final sharedPrefsValue = prefs.getBool(_consentBackupKey);
      
      return {
        'in_memory': _consentGiven,
        'secure_storage': secureStorageValue,
        'shared_prefs': sharedPrefsValue,
        'has_consent_been_asked': hasConsentBeenAsked(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'in_memory': _consentGiven,
        'has_consent_been_asked': hasConsentBeenAsked(),
      };
    }
  }
}
