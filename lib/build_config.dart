// build_config.dart
// This file contains build-time configuration that gets compiled into the app
// DO NOT commit this file with real credentials - use CI/CD to inject them

class BuildConfig {
  // These values will be replaced during CI/CD build process
  static const String azureOpenAIEndpoint = String.fromEnvironment(
    'AZURE_OPENAI_ENDPOINT',
    defaultValue: '', // Empty default for security
  );
  
  static const String azureOpenAIApiKey = String.fromEnvironment(
    'AZURE_OPENAI_API_KEY',
    defaultValue: '', // Empty default for security
  );
  
  static const String azureOpenAIDeploymentName = String.fromEnvironment(
    'AZURE_OPENAI_DEPLOYMENT_NAME',
    defaultValue: '', // Empty default for security
  );
  
  static const bool enableAI = bool.fromEnvironment(
    'ENABLE_AI',
    defaultValue: false, // Safe default
  );
  
  // Check if build configuration is complete
  static bool get isConfigured => 
    azureOpenAIEndpoint.isNotEmpty && 
    azureOpenAIApiKey.isNotEmpty && 
    azureOpenAIDeploymentName.isNotEmpty &&
    enableAI;
    
  // Get configuration as map for easy migration to secure storage
  static Map<String, String> get buildTimeConfig => {
    'endpoint': azureOpenAIEndpoint,
    'apiKey': azureOpenAIApiKey,
    'deploymentName': azureOpenAIDeploymentName,
    'enableAI': enableAI.toString(),
  };
}
