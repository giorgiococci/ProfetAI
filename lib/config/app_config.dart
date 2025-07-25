import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_logger.dart';

/// Simplified configuration manager for ProfetAI
/// 
/// This replaces the complex BuildConfig and environment variable management
/// with a single, clear source of truth.
class AppConfig {
  static const String _component = 'AppConfig';
  
  // Build-time configuration (from --dart-define)
  static const String azureEndpoint = String.fromEnvironment(
    'AZURE_OPENAI_ENDPOINT',
    defaultValue: '',
  );
  
  static const String azureApiKey = String.fromEnvironment(
    'AZURE_OPENAI_API_KEY',
    defaultValue: '',
  );
  
  static const String azureDeploymentName = String.fromEnvironment(
    'AZURE_OPENAI_DEPLOYMENT_NAME',
    defaultValue: '',
  );
  
  static const bool enableAI = bool.fromEnvironment(
    'ENABLE_AI',
    defaultValue: false,
  );
  
  // Debug configuration
  static const bool isDebugMode = bool.fromEnvironment(
    'DEBUG_LOGGING',
    defaultValue: false,
  );
  
  static const bool showDebugAlerts = bool.fromEnvironment(
    'DEBUG_ALERTS',
    defaultValue: false,
  );

  /// Check if all required AI configuration is present
  static bool get isAIConfigured => 
    azureEndpoint.isNotEmpty && 
    azureApiKey.isNotEmpty && 
    azureDeploymentName.isNotEmpty &&
    enableAI;

  /// Get configuration as a map for easy handling
  static Map<String, dynamic> get configMap => {
    'endpoint': azureEndpoint,
    'apiKey': azureApiKey,
    'deploymentName': azureDeploymentName,
    'enableAI': enableAI,
    'isDebugMode': isDebugMode,
    'showDebugAlerts': showDebugAlerts,
  };

  /// Get safe configuration (without sensitive data) for logging
  static Map<String, dynamic> get safeConfigMap => {
    'endpoint': azureEndpoint.isNotEmpty ? 'CONFIGURED' : 'EMPTY',
    'apiKey': azureApiKey.isNotEmpty ? 'CONFIGURED' : 'EMPTY',
    'deploymentName': azureDeploymentName.isNotEmpty ? 'CONFIGURED' : 'EMPTY',
    'enableAI': enableAI,
    'isDebugMode': isDebugMode,
    'showDebugAlerts': showDebugAlerts,
  };

  /// Log current configuration status (safe)
  static void logConfigStatus() {
    AppLogger.logInfo(_component, 'Configuration status: $safeConfigMap');
  }

  /// Get debug information as string
  static String getDebugInfo() {
    if (!isDebugMode) {
      return 'Debug mode disabled';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('=== ProfetAI Configuration ===');
    safeConfigMap.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString();
  }
}

/// Secure storage manager for runtime configuration
class SecureConfigManager {
  static const String _component = 'SecureConfigManager';
  
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

  // Storage keys
  static const String _endpointKey = 'azure_openai_endpoint';
  static const String _apiKeyKey = 'azure_openai_api_key';
  static const String _deploymentKey = 'azure_openai_deployment_name';
  static const String _enableAIKey = 'enable_ai';
  static const String _versionKey = 'config_version';
  static const String _currentVersion = '2.0.0';

  /// Initialize configuration from build-time values
  static Future<bool> initialize() async {
    AppLogger.logInfo(_component, 'Initializing secure configuration...');
    
    try {
      // Check if we already have stored configuration
      final hasStored = await _hasStoredConfig();
      AppLogger.logDebug(_component, 'Has stored config: $hasStored');
      
      if (!hasStored && AppConfig.isAIConfigured) {
        // First time setup - store build-time config
        AppLogger.logInfo(_component, 'Storing build-time configuration');
        await _storeBuildTimeConfig();
      }
      
      AppLogger.logInfo(_component, 'Configuration initialized successfully');
      return true;
    } catch (e) {
      AppLogger.logError(_component, 'Failed to initialize configuration', e);
      return false;
    }
  }

  /// Check if we have stored configuration
  static Future<bool> _hasStoredConfig() async {
    try {
      final version = await _storage.read(key: _versionKey);
      return version != null;
    } catch (e) {
      AppLogger.logError(_component, 'Error checking stored config', e);
      return false;
    }
  }

  /// Store build-time configuration to secure storage
  static Future<void> _storeBuildTimeConfig() async {
    await Future.wait([
      _storage.write(key: _endpointKey, value: AppConfig.azureEndpoint),
      _storage.write(key: _apiKeyKey, value: AppConfig.azureApiKey),
      _storage.write(key: _deploymentKey, value: AppConfig.azureDeploymentName),
      _storage.write(key: _enableAIKey, value: AppConfig.enableAI.toString()),
      _storage.write(key: _versionKey, value: _currentVersion),
    ]);
    AppLogger.logInfo(_component, 'Build-time configuration stored securely');
  }

  /// Get stored configuration
  static Future<Map<String, String?>> getStoredConfig() async {
    try {
      final config = {
        'endpoint': await _storage.read(key: _endpointKey),
        'apiKey': await _storage.read(key: _apiKeyKey),
        'deploymentName': await _storage.read(key: _deploymentKey),
        'enableAI': await _storage.read(key: _enableAIKey),
        'version': await _storage.read(key: _versionKey),
      };
      
      AppLogger.logDebug(_component, 'Retrieved stored configuration');
      return config;
    } catch (e) {
      AppLogger.logError(_component, 'Failed to get stored config', e);
      return {};
    }
  }

  /// Clear all stored configuration
  static Future<void> clearConfig() async {
    try {
      await Future.wait([
        _storage.delete(key: _endpointKey),
        _storage.delete(key: _apiKeyKey),
        _storage.delete(key: _deploymentKey),
        _storage.delete(key: _enableAIKey),
        _storage.delete(key: _versionKey),
      ]);
      AppLogger.logInfo(_component, 'Configuration cleared');
    } catch (e) {
      AppLogger.logError(_component, 'Failed to clear configuration', e);
      throw e;
    }
  }
}
