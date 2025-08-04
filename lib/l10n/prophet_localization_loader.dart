import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_logger.dart';

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
    
    // Build the path to the prophet's localization file
    final prophetFolder = _getProphetFolderName(prophetType);
    final fileName = '${prophetFolder}_$locale.json';
    final path = 'lib/l10n/prophets/$prophetFolder/$fileName';
    
    try {
      // Load the JSON file
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> data = json.decode(jsonString);
      
      // Cache the data
      _cache[cacheKey] = data;
      
      return data;
    } catch (e) {
      // If the current locale fails, try to fallback to English
      if (locale != 'en') {
        try {
          final prophetFolder = _getProphetFolderName(prophetType);
          final englishFileName = '${prophetFolder}_en.json';
          final englishPath = 'lib/l10n/prophets/$prophetFolder/$englishFileName';
          
          final String englishJsonString = await rootBundle.loadString(englishPath);
          final Map<String, dynamic> englishData = json.decode(englishJsonString);
          
          // Cache the English fallback data with the original locale key
          _cache[cacheKey] = englishData;
          
          return englishData;
        } catch (englishError) {
          AppLogger.logError('ProphetLocalizationLoader', 'Failed to load English fallback for $prophetType', englishError);
          return {};
        }
      } else {
        // If English itself fails, return empty map
        AppLogger.logError('ProphetLocalizationLoader', 'Failed to load English localization for $prophetType', e);
        return {};
      }
    }
  }
  
  /// Get the AI system prompt for a prophet in the current locale
  static Future<String> getAISystemPrompt(BuildContext context, String prophetType) async {
    final locale = Localizations.localeOf(context).languageCode;
    
    final data = await loadProphetLocalization(prophetType, locale);
    
    final prompt = data['aiSystemPrompt'] ?? 'You are a wise oracle providing guidance.';
    final isDefault = !data.containsKey('aiSystemPrompt');
    
    if (isDefault) {
      AppLogger.logWarning('ProphetLocalizationLoader', 'Using default prompt for $prophetType');
    }
    
    return prompt;
  }
  
  /// Get the AI loading message for a prophet in the current locale
  static Future<String> getAILoadingMessage(BuildContext context, String prophetType) async {
    final locale = Localizations.localeOf(context).languageCode;
    final data = await loadProphetLocalization(prophetType, locale);
    return data['aiLoadingMessage'] ?? 'The oracle is thinking...';
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
        return data['positiveFeedbackText'] ?? 'The vision was enlightening!';
      case 'negative':
        return data['negativeFeedbackText'] ?? 'The vision was unclear';
      case 'funny':
        return data['funnyFeedbackText'] ?? 'The vision was amusing!';
      default:
        return data['positiveFeedbackText'] ?? 'Thank you for the feedback!';
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
    return ['The oracle gazes into the unknown...'];
  }
  
  /// Get fallback responses for a prophet in the current locale
  static Future<List<String>> getFallbackResponses(BuildContext context, String prophetType) async {
    final locale = Localizations.localeOf(context).languageCode;
    final data = await loadProphetLocalization(prophetType, locale);
    
    final responses = data['fallbackResponses'];
    if (responses is List) {
      return responses.cast<String>();
    }
    return ['The oracle provides wisdom when needed.'];
  }
  
  /// Get a random fallback response for a prophet in the current locale
  static Future<String> getRandomFallbackResponse(BuildContext context, String prophetType) async {
    final responses = await getFallbackResponses(context, prophetType);
    if (responses.isEmpty) return 'The oracle shares its wisdom with you.';
    
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
      case 'oracolo_roaster':
      case 'roaster':
        return 'roaster_prophet';
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
  
  /// Verify that prophet localization assets are properly loaded
  /// This is useful for debugging APK issues
  static Future<bool> verifyAssetsLoaded() async {
    bool allAssetsLoaded = true;
    final prophetTypes = ['chaotic_prophet', 'mystic_prophet', 'cynical_prophet', 'roaster_prophet']; // Use direct folder names
    final locales = ['en', 'it'];
    
    for (final prophetType in prophetTypes) {
      for (final locale in locales) {
        try {
          final fileName = '${prophetType}_$locale.json';
          final path = 'lib/l10n/prophets/$prophetType/$fileName';
          
          await rootBundle.loadString(path);
        } catch (e) {
          AppLogger.logError('ProphetLocalizationLoader', 'Asset missing: lib/l10n/prophets/$prophetType/${prophetType}_$locale.json', e);
          allAssetsLoaded = false;
        }
      }
    }
    
    if (!allAssetsLoaded) {
      AppLogger.logError('ProphetLocalizationLoader', 'Some prophet localization assets are missing. Check pubspec.yaml assets section.');
    }
    
    return allAssetsLoaded;
  }
}
