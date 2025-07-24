import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service class for Azure OpenAI API integration
/// 
/// This class handles authentication, API calls, and error handling
/// following Azure security best practices for Flutter applications.
class AzureOpenAIService {
  static const String _apiKeyStorageKey = 'azure_openai_api_key';
  static const String _endpointStorageKey = 'azure_openai_endpoint';
  static const String _deploymentStorageKey = 'azure_openai_deployment_name';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  String? _apiKey;
  String? _endpoint;
  String? _deploymentName;

  /// Initialize the service with Azure OpenAI configuration
  /// 
  /// [endpoint]: Your Azure OpenAI endpoint (e.g., https://your-resource.openai.azure.com/)
  /// [apiKey]: Your Azure OpenAI API key
  /// [deploymentName]: The name of your deployed model
  Future<void> initialize({
    required String endpoint,
    required String apiKey,
    required String deploymentName,
  }) async {
    _endpoint = endpoint.endsWith('/') ? endpoint.substring(0, endpoint.length - 1) : endpoint;
    _deploymentName = deploymentName;
    
    // Store credentials securely
    await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
    await _secureStorage.write(key: _endpointStorageKey, value: _endpoint);
    await _secureStorage.write(key: _deploymentStorageKey, value: deploymentName);
    
    _apiKey = apiKey;
  }

  /// Load stored credentials
  Future<bool> loadStoredCredentials() async {
    try {
      _apiKey = await _secureStorage.read(key: _apiKeyStorageKey);
      _endpoint = await _secureStorage.read(key: _endpointStorageKey);
      _deploymentName = await _secureStorage.read(key: _deploymentStorageKey);
      return _apiKey != null && _endpoint != null && _deploymentName != null;
    } catch (e) {
      print('Error loading stored credentials: $e');
      return false;
    }
  }

  /// Generate a response using Azure OpenAI
  /// 
  /// [prompt]: The user prompt to send to the model
  /// [maxTokens]: Maximum tokens in the response (default: 150)
  /// [temperature]: Controls randomness (0.0 to 1.0, default: 0.7)
  /// [systemMessage]: Optional system message to set behavior
  Future<String> generateResponse({
    required String prompt,
    int maxTokens = 150,
    double temperature = 0.7,
    String? systemMessage,
  }) async {
    if (_apiKey == null || _endpoint == null || _deploymentName == null) {
      throw Exception('Azure OpenAI service not properly initialized. Call initialize() first.');
    }

    try {
      final url = Uri.parse('$_endpoint/openai/deployments/$_deploymentName/chat/completions?api-version=2024-02-15-preview');
      
      final messages = <Map<String, String>>[];
      
      // Add system message if provided
      if (systemMessage != null && systemMessage.isNotEmpty) {
        messages.add({
          'role': 'system',
          'content': systemMessage,
        });
      }
      
      // Add user message
      messages.add({
        'role': 'user',
        'content': prompt,
      });

      final requestBody = {
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'top_p': 1.0,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'api-key': _apiKey!,
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['choices'] != null && responseData['choices'].isNotEmpty) {
          return responseData['choices'][0]['message']['content'] as String;
        } else {
          throw Exception('No response generated from Azure OpenAI');
        }
      } else {
        // Handle specific Azure OpenAI error codes
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error occurred';
        
        switch (response.statusCode) {
          case 400:
            throw Exception('Bad request: $errorMessage');
          case 401:
            throw Exception('Authentication failed. Please check your API key.');
          case 429:
            throw Exception('Rate limit exceeded. Please try again later.');
          case 500:
            throw Exception('Azure OpenAI service error. Please try again.');
          default:
            throw Exception('HTTP ${response.statusCode}: $errorMessage');
        }
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Request timed out. Please check your connection.');
      }
      rethrow;
    }
  }

  /// Generate a streaming response (for real-time responses)
  Stream<String> generateStreamingResponse({
    required String prompt,
    int maxTokens = 150,
    double temperature = 0.7,
    String? systemMessage,
  }) async* {
    if (_apiKey == null || _endpoint == null || _deploymentName == null) {
      throw Exception('Azure OpenAI service not properly initialized. Call initialize() first.');
    }

    try {
      final url = Uri.parse('$_endpoint/openai/deployments/$_deploymentName/chat/completions?api-version=2024-02-15-preview');
      
      final messages = <Map<String, String>>[];
      
      if (systemMessage != null && systemMessage.isNotEmpty) {
        messages.add({
          'role': 'system',
          'content': systemMessage,
        });
      }
      
      messages.add({
        'role': 'user',
        'content': prompt,
      });

      final requestBody = {
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'top_p': 1.0,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0,
        'stream': true,
      };

      final request = http.Request('POST', url);
      request.headers.addAll({
        'Content-Type': 'application/json',
        'api-key': _apiKey!,
      });
      request.body = json.encode(requestBody);

      final streamedResponse = await http.Client().send(request);
      
      if (streamedResponse.statusCode == 200) {
        await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ') && !line.contains('[DONE]')) {
              try {
                final jsonStr = line.substring(6);
                final data = json.decode(jsonStr);
                final content = data['choices']?[0]?['delta']?['content'];
                if (content != null) {
                  yield content as String;
                }
              } catch (e) {
                // Skip malformed JSON chunks
                continue;
              }
            }
          }
        }
      } else {
        throw Exception('HTTP ${streamedResponse.statusCode}: Failed to get streaming response');
      }
    } catch (e) {
      throw Exception('Streaming error: ${e.toString()}');
    }
  }

  /// Clear stored credentials
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _apiKeyStorageKey);
    await _secureStorage.delete(key: _endpointStorageKey);
    await _secureStorage.delete(key: _deploymentStorageKey);
    _apiKey = null;
    _endpoint = null;
    _deploymentName = null;
  }

  /// Check if service is properly configured
  bool get isInitialized => _apiKey != null && _endpoint != null && _deploymentName != null;
}
