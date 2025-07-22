import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:profet_ai/services/secure_config_service.dart';

void main() {
  group('SecureConfigService Tests', () {
    
    setUp(() async {
      // Clear any existing configuration before each test
      await SecureConfigService.clearAllConfiguration();
    });

    test('should initialize with default values when no config exists', () async {
      await SecureConfigService.initialize();
      
      expect(SecureConfigService.isAIEnabled, isFalse);
      expect(SecureConfigService.getStatus(), contains('AI disabled'));
    });

    test('should store and retrieve Azure OpenAI configuration', () async {
      const testEndpoint = 'https://test.openai.azure.com/';
      const testApiKey = 'test-api-key-12345';
      const testDeploymentName = 'test-deployment';

      await SecureConfigService.storeAzureOpenAIConfig(
        endpoint: testEndpoint,
        apiKey: testApiKey,
        deploymentName: testDeploymentName,
        enableAI: true,
      );

      // Re-initialize to test persistence
      await SecureConfigService.initialize();

      expect(SecureConfigService.isAIEnabled, isTrue);
      expect(SecureConfigService.getStatus(), contains('AI enabled'));

      // Test configuration status (should mask sensitive data)
      final status = await SecureConfigService.getConfigurationStatus();
      expect(status['endpoint'], equals('Configured'));
      expect(status['apiKey'], equals('Hidden for security'));
      expect(status['deploymentName'], equals(testDeploymentName));
      expect(status['enableAI'], equals('true'));
    });

    test('should clear all configuration', () async {
      // First store some config
      await SecureConfigService.storeAzureOpenAIConfig(
        endpoint: 'https://test.openai.azure.com/',
        apiKey: 'test-api-key',
        deploymentName: 'test-deployment',
        enableAI: true,
      );

      await SecureConfigService.initialize();
      expect(SecureConfigService.isAIEnabled, isTrue);

      // Clear configuration
      await SecureConfigService.clearAllConfiguration();
      await SecureConfigService.initialize();

      expect(SecureConfigService.isAIEnabled, isFalse);
      
      final status = await SecureConfigService.getConfigurationStatus();
      expect(status['endpoint'], equals('Not set'));
      expect(status['deploymentName'], equals('Not set'));
    });

    test('should handle migration from environment variables', () async {
      // This test would require mocking flutter_dotenv
      // For now, we'll just test that migration doesn't crash
      await SecureConfigService.initialize();
      expect(SecureConfigService.getStatus(), isNotEmpty);
    });

    tearDown(() async {
      // Clean up after each test
      await SecureConfigService.clearAllConfiguration();
    });
  });
}
