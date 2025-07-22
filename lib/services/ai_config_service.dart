import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/profet.dart';

/// Application-level AI configuration service
/// 
/// This service handles the initialization of Azure OpenAI credentials
/// from environment variables or application configuration.
class AIConfigService {
  static bool _isInitialized = false;
  static bool _isAIEnabled = false;

  /// Initialize AI configuration from environment or assets
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Try to load .env file if it exists
      await _loadFromEnvironment();
    } catch (e) {
      print('Environment file not found, trying hardcoded configuration...');
      // Fallback to hardcoded configuration for production
      await _loadHardcodedConfiguration();
    }

    _isInitialized = true;
  }

  /// Load configuration from .env file (development)
  static Future<void> _loadFromEnvironment() async {
    try {
      await dotenv.load(fileName: ".env");
      
      final endpoint = dotenv.env['AZURE_OPENAI_ENDPOINT'];
      final apiKey = dotenv.env['AZURE_OPENAI_API_KEY'];
      final deploymentName = dotenv.env['AZURE_OPENAI_DEPLOYMENT_NAME'];
      final enableAI = dotenv.env['ENABLE_AI']?.toLowerCase() == 'true';

      if (enableAI && endpoint != null && apiKey != null && deploymentName != null) {
        await Profet.initializeAI(
          endpoint: endpoint,
          apiKey: apiKey,
          deploymentName: deploymentName,
        );
        _isAIEnabled = true;
        print('AI configured from environment variables');
      } else {
        _isAIEnabled = false;
        print('AI disabled or incomplete configuration in environment');
      }
    } catch (e) {
      print('Failed to load .env file: $e');
      throw e;
    }
  }

  /// Load hardcoded configuration (production)
  /// 
  /// For production apps, you would typically:
  /// 1. Store credentials in secure cloud config (Azure Key Vault, AWS Secrets Manager)
  /// 2. Load them at app startup
  /// 3. Or embed them in the app build process
  static Future<void> _loadHardcodedConfiguration() async {
    // TODO: Replace with your production configuration method
    // 
    // Example approaches:
    // 1. Fetch from secure remote config service
    // 2. Load from encrypted local storage
    // 3. Compile-time configuration injection
    
    // For now, disable AI if no environment file is found
    const bool enableAI = false; // Set to true and configure below for production
    
    if (enableAI) {
      // Uncomment and configure for production:
      /*
      const endpoint = 'https://your-production-resource.openai.azure.com';
      const apiKey = 'your-production-api-key';
      const deploymentName = 'your-production-deployment';
      
      await Profet.initializeAI(
        endpoint: endpoint,
        apiKey: apiKey,
        deploymentName: deploymentName,
      );
      _isAIEnabled = true;
      print('AI configured from hardcoded production config');
      */
    } else {
      _isAIEnabled = false;
      print('AI disabled - using original responses only');
    }
  }

  /// Check if AI is enabled and properly configured
  static bool get isAIEnabled => _isInitialized && _isAIEnabled;

  /// Get AI status for debugging
  static String getStatus() {
    if (!_isInitialized) return 'AI not initialized';
    if (!_isAIEnabled) return 'AI disabled - using original responses';
    return 'AI enabled - using Azure OpenAI';
  }
}
