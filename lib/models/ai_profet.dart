import '../services/azure_openai_service.dart';
import 'profet.dart';

/// Enhanced Profet class with Azure OpenAI integration
/// 
/// This class extends the base Profet functionality with AI-powered responses
/// while maintaining the original personality and characteristics.
abstract class AIProfet extends Profet {
  final AzureOpenAIService _aiService = AzureOpenAIService();
  
  AIProfet({
    required super.name,
    required super.description,
    required super.location,
    required super.primaryColor,
    required super.secondaryColor,
    required super.backgroundGradient,
    required super.icon,
    super.backgroundImagePath,
  });
  
  /// Get the system prompt that defines this profet's personality
  String get systemPrompt;
  
  /// Initialize the AI service
  Future<void> initializeAI({
    required String endpoint,
    required String apiKey,
    required String deploymentName,
  }) async {
    await _aiService.initialize(
      endpoint: endpoint,
      apiKey: apiKey,
      deploymentName: deploymentName,
    );
  }

  /// Load stored AI credentials
  Future<bool> loadStoredAICredentials() async {
    return await _aiService.loadStoredCredentials();
  }

  /// Override the base method to provide AI-enhanced responses
  @override
  String getPersonalizedResponse(String question) {
    // This method will be overridden to provide AI responses
    // Fallback to base implementation if AI is not available
    return getRandomVision();
  }

  /// Generate an AI-powered prophecy or response
  Future<String> generateAIResponse(String userQuery) async {
    if (!_aiService.isInitialized) {
      throw Exception('AI service not initialized. Please configure Azure OpenAI first.');
    }

    try {
      final response = await _aiService.generateResponse(
        prompt: userQuery,
        systemMessage: systemPrompt,
        maxTokens: 200,
        temperature: 0.8, // Higher temperature for more creative responses
      );
      
      return response;
    } catch (e) {
      // Fallback to original behavior if AI fails
      print('AI response failed, falling back to original: $e');
      return getRandomVision(); // Return random vision as fallback
    }
  }

  /// Generate a streaming AI response for real-time interaction
  Stream<String> generateStreamingAIResponse(String userQuery) async* {
    if (!_aiService.isInitialized) {
      throw Exception('AI service not initialized. Please configure Azure OpenAI first.');
    }

    try {
      yield* _aiService.generateStreamingResponse(
        prompt: userQuery,
        systemMessage: systemPrompt,
        maxTokens: 200,
        temperature: 0.8,
      );
    } catch (e) {
      print('AI streaming failed: $e');
      yield getRandomVision(); // Fallback response
    }
  }

  /// Check if AI is available and configured
  bool get isAIEnabled => _aiService.isInitialized;
}
