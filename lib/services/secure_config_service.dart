import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/profet.dart';

/// Secure configuration service for storing and retrieving sensitive data
/// 
/// This service uses platform secure storage (Android Keystore / iOS Keychain)
/// to securely store API keys and other sensitive configuration.
class SecureConfigService {
  static bool _isInitialized = false;
  static bool _isAIEnabled = false;
  
  // Secure storage instance with Android-specific options for enhanced security
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for storing configuration values
  static const String _azureEndpointKey = 'azure_openai_endpoint';
  static const String _azureApiKeyKey = 'azure_openai_api_key';
  static const String _azureDeploymentKey = 'azure_openai_deployment';
  static const String _enableAIKey = 'enable_ai';
  static const String _configVersionKey = 'config_version';

  /// Current configuration version for migration support
  static const String _currentConfigVersion = '1.0.0';

  /// Initialize secure configuration
  /// 
  /// This will:
  /// 1. Try to load from secure storage first
  /// 2. Fall back to environment variables if no secure config exists
  /// 3. Migrate environment config to secure storage if needed
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check if we have secure configuration stored
      final hasSecureConfig = await _hasStoredConfiguration();
      
      if (hasSecureConfig) {
        print('Loading configuration from secure storage...');
        await _loadFromSecureStorage();
      } else {
        print('No secure configuration found, trying migration from environment...');
        await _migrateFromEnvironment();
      }
    } catch (e) {
      print('Failed to initialize secure configuration: $e');
      _isAIEnabled = false;
    }

    _isInitialized = true;
  }

  /// Check if we have stored configuration in secure storage
  static Future<bool> _hasStoredConfiguration() async {
    try {
      final version = await _storage.read(key: _configVersionKey);
      return version != null;
    } catch (e) {
      return false;
    }
  }

  /// Load configuration from secure storage
  static Future<void> _loadFromSecureStorage() async {
    try {
      final endpoint = await _storage.read(key: _azureEndpointKey);
      final apiKey = await _storage.read(key: _azureApiKeyKey);
      final deploymentName = await _storage.read(key: _azureDeploymentKey);
      final enableAI = await _storage.read(key: _enableAIKey) == 'true';

      if (enableAI && endpoint != null && apiKey != null && deploymentName != null) {
        await Profet.initializeAI(
          endpoint: endpoint,
          apiKey: apiKey,
          deploymentName: deploymentName,
        );
        _isAIEnabled = true;
        print('AI configured from secure storage');
      } else {
        _isAIEnabled = false;
        print('AI disabled or incomplete configuration in secure storage');
      }
    } catch (e) {
      print('Failed to load from secure storage: $e');
      _isAIEnabled = false;
    }
  }

  /// Migrate configuration from environment variables to secure storage
  /// 
  /// This is a one-time migration that will read from .env file (if it exists)
  /// and store the values securely. After migration, the app will use secure storage.
  static Future<void> _migrateFromEnvironment() async {
    try {
      // Try to load from environment file for migration
      try {
        final env = await _tryLoadEnvironment();
        if (env != null) {
          await _migrateEnvironmentToSecure(env);
          return;
        }
      } catch (e) {
        print('Could not load environment file: $e');
      }

      // If no environment file, set up with default disabled state
      await _setDefaultConfiguration();
    } catch (e) {
      print('Migration failed: $e');
      await _setDefaultConfiguration();
    }
  }

  /// Try to load environment variables (fallback for migration)
  static Future<Map<String, String>?> _tryLoadEnvironment() async {
    try {
      // Try to load .env file using flutter_dotenv
      await dotenv.load(fileName: ".env");
      
      return {
        'AZURE_OPENAI_ENDPOINT': dotenv.env['AZURE_OPENAI_ENDPOINT'] ?? '',
        'AZURE_OPENAI_API_KEY': dotenv.env['AZURE_OPENAI_API_KEY'] ?? '',
        'AZURE_OPENAI_DEPLOYMENT_NAME': dotenv.env['AZURE_OPENAI_DEPLOYMENT_NAME'] ?? '',
        'ENABLE_AI': dotenv.env['ENABLE_AI'] ?? 'false',
      };
    } catch (e) {
      print('Could not load .env file: $e');
      return null;
    }
  }

  /// Migrate environment variables to secure storage
  static Future<void> _migrateEnvironmentToSecure(Map<String, String> env) async {
    final endpoint = env['AZURE_OPENAI_ENDPOINT'];
    final apiKey = env['AZURE_OPENAI_API_KEY'];
    final deploymentName = env['AZURE_OPENAI_DEPLOYMENT_NAME'];
    final enableAI = env['ENABLE_AI']?.toLowerCase() == 'true';

    if (enableAI && endpoint != null && apiKey != null && deploymentName != null) {
      // Store in secure storage
      await storeConfiguration(
        endpoint: endpoint,
        apiKey: apiKey,
        deploymentName: deploymentName,
        enableAI: enableAI,
      );

      print('Successfully migrated configuration from environment to secure storage');
    } else {
      await _setDefaultConfiguration();
      print('Incomplete environment configuration - set to disabled');
    }
  }

  /// Set default disabled configuration
  static Future<void> _setDefaultConfiguration() async {
    await storeConfiguration(
      endpoint: '',
      apiKey: '',
      deploymentName: '',
      enableAI: false,
    );
    _isAIEnabled = false;
  }

  /// Store configuration securely
  /// 
  /// This method allows you to update the secure configuration programmatically.
  /// Useful for:
  /// - Initial setup after user enters credentials
  /// - Key rotation
  /// - Configuration updates
  static Future<void> storeConfiguration({
    required String endpoint,
    required String apiKey,
    required String deploymentName,
    required bool enableAI,
  }) async {
    try {
      // Store all configuration values
      await Future.wait([
        _storage.write(key: _azureEndpointKey, value: endpoint),
        _storage.write(key: _azureApiKeyKey, value: apiKey),
        _storage.write(key: _azureDeploymentKey, value: deploymentName),
        _storage.write(key: _enableAIKey, value: enableAI.toString()),
        _storage.write(key: _configVersionKey, value: _currentConfigVersion),
      ]);

      // Reinitialize AI with new configuration if enabled
      if (enableAI && endpoint.isNotEmpty && apiKey.isNotEmpty && deploymentName.isNotEmpty) {
        await Profet.initializeAI(
          endpoint: endpoint,
          apiKey: apiKey,
          deploymentName: deploymentName,
        );
        _isAIEnabled = true;
      } else {
        _isAIEnabled = false;
      }

      print('Configuration stored securely');
    } catch (e) {
      print('Failed to store configuration: $e');
      throw e;
    }
  }

  /// Get current configuration status (masked for security)
  /// 
  /// This only returns non-sensitive configuration status information.
  /// API keys and other secrets are never exposed.
  static Future<Map<String, String?>> getConfigurationStatus() async {
    try {
      final endpoint = await _storage.read(key: _azureEndpointKey);
      final deploymentName = await _storage.read(key: _azureDeploymentKey);
      final enableAI = await _storage.read(key: _enableAIKey);
      final version = await _storage.read(key: _configVersionKey);

      return {
        'endpoint': endpoint != null && endpoint.isNotEmpty ? 'Configured' : 'Not set',
        'apiKey': 'Hidden for security', // Never expose API keys
        'deploymentName': deploymentName ?? 'Not set',
        'enableAI': enableAI,
        'configVersion': version,
      };
    } catch (e) {
      print('Failed to get configuration status: $e');
      return {};
    }
  }

  /// Clear all stored configuration
  /// 
  /// Use this for:
  /// - User logout
  /// - Reset to factory settings
  /// - Security incident response (clear all secrets)
  static Future<void> clearConfiguration() async {
    try {
      await Future.wait([
        _storage.delete(key: _azureEndpointKey),
        _storage.delete(key: _azureApiKeyKey),
        _storage.delete(key: _azureDeploymentKey),
        _storage.delete(key: _enableAIKey),
        _storage.delete(key: _configVersionKey),
      ]);

      _isAIEnabled = false;
      print('Configuration cleared');
    } catch (e) {
      print('Failed to clear configuration: $e');
      throw e;
    }
  }

  /// Check if AI is enabled and properly configured
  static bool get isAIEnabled => _isInitialized && _isAIEnabled;

  /// Get AI status for debugging
  static String getStatus() {
    if (!_isInitialized) return 'AI not initialized';
    if (!_isAIEnabled) return 'AI disabled - using original responses';
    return 'AI enabled - using Azure OpenAI (secure storage)';
  }

  /// Check if secure storage is available on this device
  static Future<bool> isSecureStorageAvailable() async {
    try {
      await _storage.write(key: 'test_key', value: 'test_value');
      final value = await _storage.read(key: 'test_key');
      await _storage.delete(key: 'test_key');
      return value == 'test_value';
    } catch (e) {
      return false;
    }
  }
}
