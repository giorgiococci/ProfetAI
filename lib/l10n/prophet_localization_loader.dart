import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Prophet-specific localization loader
/// This class handles loading localized content for individual prophets
class ProphetLocalizationLoader {
  static final Map<String, Map<String, dynamic>> _cache = {};
  
  /// Load localization data for a specific prophet and locale
  static Future<Map<String, dynamic>> loadProphetLocalization(
    String prophetType, 
    String locale
  ) async {
    final cacheKey = '${prophetType}_$locale';
    
    // Return cached data if available
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    
    try {
      // Build the path to the prophet's localization file
      final prophetFolder = _getProphetFolderName(prophetType);
      final fileName = '${prophetFolder}_$locale.json';
      final path = 'lib/l10n/prophets/$prophetFolder/$fileName';
      
      // Load the JSON file
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> data = json.decode(jsonString);
      
      // Cache the data
      _cache[cacheKey] = data;
      
      return data;
    } catch (e) {
      // Return empty map if file doesn't exist or can't be loaded
      debugPrint('Warning: Could not load prophet localization for $prophetType ($locale): $e');
      return {};
    }
  }
  
  /// Get the AI system prompt for a prophet in the current locale
  static Future<String> getAISystemPrompt(BuildContext context, String prophetType) async {
    final locale = Localizations.localeOf(context).languageCode;
    final data = await loadProphetLocalization(prophetType, locale);
    return data['aiSystemPrompt'] ?? '';
  }
  
  /// Get the AI loading message for a prophet in the current locale
  static Future<String> getAILoadingMessage(BuildContext context, String prophetType) async {
    final locale = Localizations.localeOf(context).languageCode;
    final data = await loadProphetLocalization(prophetType, locale);
    return data['aiLoadingMessage'] ?? 'Loading...';
  }
  
  /// Get feedback text for a prophet in the current locale
  static Future<String> getFeedbackText(
    BuildContext context, 
    String prophetType, 
    String feedbackType
  ) async {
    final locale = Localizations.localeOf(context).languageCode;
    final data = await loadProphetLocalization(prophetType, locale);
    
    switch (feedbackType.toLowerCase()) {
      case 'positive':
        return data['positiveFeedbackText'] ?? 'Great!';
      case 'negative':
        return data['negativeFeedbackText'] ?? 'Not clear';
      case 'funny':
        return data['funnyFeedbackText'] ?? 'Interesting!';
      default:
        return data['positiveFeedbackText'] ?? 'Thank you!';
    }
  }
  
  /// Get random visions for a prophet in the current locale
  static Future<List<String>> getRandomVisions(BuildContext context, String prophetType) async {
    final locale = Localizations.localeOf(context).languageCode;
    final data = await loadProphetLocalization(prophetType, locale);
    
    final visions = data['randomVisions'];
    if (visions is List) {
      return visions.cast<String>();
    }
    return ['The future is mysterious...'];
  }
  
  /// Get fallback responses for a prophet in the current locale
  static Future<List<String>> getFallbackResponses(BuildContext context, String prophetType) async {
    final locale = Localizations.localeOf(context).languageCode;
    final data = await loadProphetLocalization(prophetType, locale);
    
    final responses = data['fallbackResponses'];
    if (responses is List) {
      return responses.cast<String>();
    }
    return ['The oracle is currently unavailable.'];
  }
  
  /// Get a random fallback response for a prophet in the current locale
  static Future<String> getRandomFallbackResponse(BuildContext context, String prophetType) async {
    final responses = await getFallbackResponses(context, prophetType);
    if (responses.isEmpty) return 'The oracle is silent.';
    
    final randomIndex = DateTime.now().millisecondsSinceEpoch % responses.length;
    return responses[randomIndex];
  }
  
  /// Convert prophet type to folder name
  static String _getProphetFolderName(String prophetType) {
    switch (prophetType.toLowerCase()) {
      case 'oracolo_caotico':
      case 'chaotic':
        return 'chaotic_prophet';
      case 'oracolo_mistico':
      case 'mystic':
        return 'mystic_prophet';
      case 'oracolo_cinico':
      case 'cynical':
        return 'cynical_prophet';
      default:
        return prophetType.toLowerCase();
    }
  }
  
  /// Clear the cache (useful for testing or language changes)
  static void clearCache() {
    _cache.clear();
  }
  
  /// Get all available locales for a prophet
  static Future<List<String>> getAvailableLocales(String prophetType) async {
    final prophetFolder = _getProphetFolderName(prophetType);
    final locales = <String>[];
    
    // Try to load common locales
    for (final locale in ['en', 'it', 'es', 'fr', 'de']) {
      try {
        final fileName = '${prophetFolder}_$locale.json';
        final path = 'lib/l10n/prophets/$prophetFolder/$fileName';
        await rootBundle.loadString(path);
        locales.add(locale);
      } catch (e) {
        // Locale not available, continue
      }
    }
    
    return locales;
  }
}
