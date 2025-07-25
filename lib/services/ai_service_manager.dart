import '../services/azure_openai_service.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';

/// Simplified AI service manager
/// 
/// This replaces the complex Profet static methods with a cleaner interface
class AIServiceManager {
  static const String _component = 'AIServiceManager';
  static final AzureOpenAIService _aiService = AzureOpenAIService();
  static bool _isInitialized = false;

  /// Initialize AI service with stored or build-time configuration
  static Future<bool> initialize() async {
    AppLogger.logInfo(_component, 'Initializing AI service...');
    
    try {
      // Initialize secure config first
      await SecureConfigManager.initialize();
      
      // Get configuration
      final storedConfig = await SecureConfigManager.getStoredConfig();
      final endpoint = storedConfig['endpoint'];
      final apiKey = storedConfig['apiKey'];
      final deploymentName = storedConfig['deploymentName'];
      final enableAI = storedConfig['enableAI'] == 'true';
      
      AppLogger.logDebug(_component, 'Config - AI enabled: $enableAI');
      AppLogger.logDebug(_component, 'Config - Endpoint present: ${endpoint?.isNotEmpty ?? false}');
      AppLogger.logDebug(_component, 'Config - API key present: ${apiKey?.isNotEmpty ?? false}');
      AppLogger.logDebug(_component, 'Config - Deployment present: ${deploymentName?.isNotEmpty ?? false}');
      
      if (enableAI && 
          endpoint != null && endpoint.isNotEmpty &&
          apiKey != null && apiKey.isNotEmpty &&
          deploymentName != null && deploymentName.isNotEmpty) {
        
        // Initialize Azure OpenAI service
        await _aiService.initialize(
          endpoint: endpoint,
          apiKey: apiKey,
          deploymentName: deploymentName,
        );
        
        _isInitialized = true;
        AppLogger.logInfo(_component, 'AI service initialized successfully');
        return true;
      } else {
        AppLogger.logWarning(_component, 'AI service not initialized - incomplete configuration');
        return false;
      }
    } catch (e) {
      AppLogger.logError(_component, 'Failed to initialize AI service', e);
      return false;
    }
  }

  /// Check if AI is available and working
  static bool get isAIAvailable => _isInitialized && _aiService.isInitialized;

  /// Generate AI response
  static Future<String?> generateResponse({
    required String prompt,
    String? systemMessage,
    int maxTokens = 150,
    double temperature = 0.7,
  }) async {
    if (!isAIAvailable) {
      AppLogger.logDebug(_component, 'AI not available, returning null');
      return null;
    }

    try {
      AppLogger.logDebug(_component, 'Generating AI response...');
      final response = await _aiService.generateResponse(
        prompt: prompt,
        systemMessage: systemMessage,
        maxTokens: maxTokens,
        temperature: temperature,
      );
      
      AppLogger.logDebug(_component, 'AI response generated successfully');
      return response;
    } catch (e) {
      AppLogger.logError(_component, 'Failed to generate AI response', e);
      return null;
    }
  }

  /// Get status information for debugging
  static Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'aiServiceInitialized': _aiService.isInitialized,
      'isAvailable': isAIAvailable,
      'buildConfigValid': AppConfig.isAIConfigured,
    };
  }

  /// Get detailed status as string
  static String getDetailedStatus() {
    final status = getStatus();
    final buffer = StringBuffer();
    buffer.writeln('=== AI Service Status ===');
    status.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    
    if (AppConfig.isDebugMode) {
      buffer.writeln('\n=== Build Configuration ===');
      buffer.writeln(AppConfig.getDebugInfo());
      
      buffer.writeln('\n=== Recent Logs ===');
      buffer.writeln(AppLogger.getLogsAsString(component: _component, lastN: 5));
    }
    
    return buffer.toString();
  }

  /// Clear AI configuration (for testing/reset)
  static Future<void> clearConfiguration() async {
    AppLogger.logInfo(_component, 'Clearing AI configuration...');
    await SecureConfigManager.clearConfig();
    await _aiService.clearCredentials();
    _isInitialized = false;
    AppLogger.logInfo(_component, 'AI configuration cleared');
  }
}
