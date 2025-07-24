import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/profet.dart';
import '../build_config.dart';

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
  /// Priority order:
  /// 1. Existing secure storage (user has configured)
  /// 2. Build-time configuration (embedded in release)
  /// 3. Environment variables (.env file - development only)
  /// 4. Default disabled state
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check if we have secure configuration stored
      final hasSecureConfig = await _hasStoredConfiguration();
      
      if (hasSecureConfig) {
        print('Loading configuration from secure storage...');
        await _loadFromSecureStorage();
      } else {
        print('No secure configuration found, checking build-time config...');
        await _migrateFromBuildConfig();
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

  /// Migrate configuration from build-time config to secure storage
  /// 
  /// This handles the initial setup for release builds where credentials
  /// are embedded at build time via --dart-define flags
  static Future<void> _migrateFromBuildConfig() async {
    try {
      // Check if build-time configuration is available
      if (BuildConfig.isConfigured) {
        print('Found build-time configuration, migrating to secure storage...');
        await _migrateBuildConfigToSecure(BuildConfig.buildTimeConfig);
        return;
      }

      // Fall back to environment variables for development
      print('No build-time config, trying environment variables...');
      await _migrateFromEnvironment();
      
    } catch (e) {
      print('Build config migration failed: $e');
      await _migrateFromEnvironment();
    }
  }

  /// Migrate build-time configuration to secure storage
  static Future<void> _migrateBuildConfigToSecure(Map<String, String> config) async {
    final endpoint = config['endpoint'];
    final apiKey = config['apiKey'];
    final deploymentName = config['deploymentName'];
    final enableAI = config['enableAI']?.toLowerCase() == 'true';

    if (enableAI && endpoint != null && apiKey != null && deploymentName != null) {
      // Store in secure storage
      await storeConfiguration(
        endpoint: endpoint,
        apiKey: apiKey,
        deploymentName: deploymentName,
        enableAI: enableAI,
      );

      print('Successfully migrated build-time configuration to secure storage');
    } else {
      await _setDefaultConfiguration();
      print('Incomplete build-time configuration - set to disabled');
    }
  }

  /// Migrate configuration from environment variables to secure storage
  /// 
  /// This is a fallback for development builds when no build-time config exists
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

  /// Store configuration securely (Internal use only)
  /// 
  /// This method is used internally during migration from build-time config
  /// to secure storage. It should not be called directly by UI components
  /// in production builds with embedded credentials.
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

      print('Configuration stored securely (internal migration)');
    } catch (e) {
      print('Failed to store configuration: $e');
      throw e;
    }
  }

  /// Get current configuration status (Always masked for security)
  /// 
  /// This only returns non-sensitive configuration status information.
  /// API keys and other secrets are never exposed in production builds.
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

  /// Get configuration (Always masked for production security)
  /// 
  /// In production builds with embedded credentials, sensitive data
  /// is always masked to prevent credential exposure.
  static Future<Map<String, String?>> getConfiguration({bool maskSensitive = true}) async {
    // Always use masked version for production security
    return await getConfigurationStatus();
  }

  /// Clear all stored configuration (Emergency use only)
  /// 
  /// ⚠️  WARNING: This is for emergency use only (e.g., security incident)
  /// In production apps with embedded credentials, this will disable AI
  /// until the app is reinstalled or updated.
  /// 
  /// Use this for:
  /// - Security incident response (clear all secrets)
  /// - Factory reset functionality
  /// - Debugging/testing only
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
      print('⚠️  Configuration cleared - AI features disabled');
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
