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
    
    debugPrint('=== PROPHET LOCALIZATION LOADING ===');
    debugPrint('Prophet Type: $prophetType');
    debugPrint('Locale: $locale');
    debugPrint('Cache Key: $cacheKey');
    
    AppLogger.logInfo('ProphetLocalizationLoader', '=== PROPHET LOCALIZATION LOADING ===');
    AppLogger.logInfo('ProphetLocalizationLoader', 'Prophet Type: $prophetType');
    AppLogger.logInfo('ProphetLocalizationLoader', 'Locale: $locale');
    AppLogger.logInfo('ProphetLocalizationLoader', 'Cache Key: $cacheKey');
    
    // Return cached data if available
    if (_cache.containsKey(cacheKey)) {
      debugPrint('Found cached data for $cacheKey');
      debugPrint('Cached data keys: ${_cache[cacheKey]!.keys.toList()}');
      debugPrint('=== END PROPHET LOCALIZATION LOADING (CACHED) ===');
      
      AppLogger.logInfo('ProphetLocalizationLoader', 'Found cached data for $cacheKey');
      AppLogger.logInfo('ProphetLocalizationLoader', 'Cached data keys: ${_cache[cacheKey]!.keys.toList()}');
      AppLogger.logInfo('ProphetLocalizationLoader', '=== END PROPHET LOCALIZATION LOADING (CACHED) ===');
      
      return _cache[cacheKey]!;
    }
    
    // Build the path to the prophet's localization file
    final prophetFolder = _getProphetFolderName(prophetType);
    final fileName = '${prophetFolder}_$locale.json';
    final path = 'lib/l10n/prophets/$prophetFolder/$fileName';
    
    debugPrint('Prophet Folder: $prophetFolder');
    debugPrint('File Name: $fileName');
    debugPrint('Full Path: $path');
    
    AppLogger.logInfo('ProphetLocalizationLoader', 'Prophet Folder: $prophetFolder');
    AppLogger.logInfo('ProphetLocalizationLoader', 'File Name: $fileName');
    AppLogger.logInfo('ProphetLocalizationLoader', 'Full Path: $path');
    
    try {
      // Debug print for APK troubleshooting
      debugPrint('Attempting to load prophet localization: $path');
      AppLogger.logInfo('ProphetLocalizationLoader', 'Attempting to load prophet localization: $path');
      
      // Load the JSON file
      final String jsonString = await rootBundle.loadString(path);
      debugPrint('Successfully read file content, length: ${jsonString.length} characters');
      AppLogger.logInfo('ProphetLocalizationLoader', 'Successfully read file content, length: ${jsonString.length} characters');
      
      final Map<String, dynamic> data = json.decode(jsonString);
      debugPrint('Successfully parsed JSON, keys: ${data.keys.toList()}');
      AppLogger.logInfo('ProphetLocalizationLoader', 'Successfully parsed JSON, keys: ${data.keys.toList()}');
      
      // Cache the data
      _cache[cacheKey] = data;
      
      debugPrint('Successfully loaded and cached prophet localization for $prophetType ($locale)');
      debugPrint('=== END PROPHET LOCALIZATION LOADING (SUCCESS) ===');
      
      AppLogger.logInfo('ProphetLocalizationLoader', 'Successfully loaded and cached prophet localization for $prophetType ($locale)');
      AppLogger.logInfo('ProphetLocalizationLoader', '=== END PROPHET LOCALIZATION LOADING (SUCCESS) ===');
      
      return data;
    } catch (e) {
      // Enhanced error logging for APK debugging
      debugPrint('=== ERROR IN PROPHET LOCALIZATION LOADING ===');
      debugPrint('Error loading prophet localization: $path - $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: ${StackTrace.current}');
      
      AppLogger.logError('ProphetLocalizationLoader', '=== ERROR IN PROPHET LOCALIZATION LOADING ===');
      AppLogger.logError('ProphetLocalizationLoader', 'Error loading prophet localization: $path', e);
      AppLogger.logError('ProphetLocalizationLoader', 'Error type: ${e.runtimeType}');
      AppLogger.logError('ProphetLocalizationLoader', 'Stack trace: ${StackTrace.current}');
      
      // If the current locale fails, try to fallback to English
      if (locale != 'en') {
        debugPrint('=== ATTEMPTING ENGLISH FALLBACK ===');
        debugPrint('Warning: Could not load prophet localization for $prophetType ($locale): $e');
        debugPrint('Falling back to English localization...');
        
        AppLogger.logError('ProphetLocalizationLoader', '=== ATTEMPTING ENGLISH FALLBACK ===');
        AppLogger.logError('ProphetLocalizationLoader', 'Warning: Could not load prophet localization for $prophetType ($locale)', e);
        AppLogger.logError('ProphetLocalizationLoader', 'Falling back to English localization...');
        
        try {
          final prophetFolder = _getProphetFolderName(prophetType);
          final englishFileName = '${prophetFolder}_en.json';
          final englishPath = 'lib/l10n/prophets/$prophetFolder/$englishFileName';
          
          debugPrint('English fallback path: $englishPath');
          debugPrint('Attempting to load English fallback: $englishPath');
          
          AppLogger.logInfo('ProphetLocalizationLoader', 'English fallback path: $englishPath');
          AppLogger.logInfo('ProphetLocalizationLoader', 'Attempting to load English fallback: $englishPath');
          
          final String englishJsonString = await rootBundle.loadString(englishPath);
          debugPrint('Successfully read English file content, length: ${englishJsonString.length} characters');
          AppLogger.logInfo('ProphetLocalizationLoader', 'Successfully read English file content, length: ${englishJsonString.length} characters');
          
          final Map<String, dynamic> englishData = json.decode(englishJsonString);
          debugPrint('Successfully parsed English JSON, keys: ${englishData.keys.toList()}');
          AppLogger.logInfo('ProphetLocalizationLoader', 'Successfully parsed English JSON, keys: ${englishData.keys.toList()}');
          
          // Cache the English fallback data with the original locale key
          _cache[cacheKey] = englishData;
          
          debugPrint('Successfully loaded English fallback for $prophetType');
          debugPrint('=== END PROPHET LOCALIZATION LOADING (ENGLISH FALLBACK) ===');
          
          AppLogger.logInfo('ProphetLocalizationLoader', 'Successfully loaded English fallback for $prophetType');
          AppLogger.logInfo('ProphetLocalizationLoader', '=== END PROPHET LOCALIZATION LOADING (ENGLISH FALLBACK) ===');
          
          return englishData;
        } catch (englishError) {
          debugPrint('=== ENGLISH FALLBACK FAILED ===');
          debugPrint('Error: Could not load English fallback for $prophetType: $englishError');
          debugPrint('English error type: ${englishError.runtimeType}');
          debugPrint('=== RETURNING EMPTY MAP ===');
          
          AppLogger.logError('ProphetLocalizationLoader', '=== ENGLISH FALLBACK FAILED ===');
          AppLogger.logError('ProphetLocalizationLoader', 'Error: Could not load English fallback for $prophetType', englishError);
          AppLogger.logError('ProphetLocalizationLoader', 'English error type: ${englishError.runtimeType}');
          AppLogger.logError('ProphetLocalizationLoader', '=== RETURNING EMPTY MAP ===');
          
          return {};
        }
      } else {
        // If English itself fails, return empty map
        debugPrint('=== ENGLISH LOCALE FAILED ===');
        debugPrint('Error: Could not load English localization for $prophetType: $e');
        debugPrint('=== RETURNING EMPTY MAP ===');
        
        AppLogger.logError('ProphetLocalizationLoader', '=== ENGLISH LOCALE FAILED ===');
        AppLogger.logError('ProphetLocalizationLoader', 'Error: Could not load English localization for $prophetType', e);
        AppLogger.logError('ProphetLocalizationLoader', '=== RETURNING EMPTY MAP ===');
        
        return {};
      }
    }
  }
  
  /// Get the AI system prompt for a prophet in the current locale
  static Future<String> getAISystemPrompt(BuildContext context, String prophetType) async {
    final locale = Localizations.localeOf(context).languageCode;
    
    debugPrint('=== AI SYSTEM PROMPT LOADING ===');
    debugPrint('Prophet Type: $prophetType');
    debugPrint('Detected Locale: $locale');
    debugPrint('Context Locale: ${Localizations.localeOf(context)}');
    
    AppLogger.logInfo('ProphetLocalizationLoader', '=== AI SYSTEM PROMPT LOADING ===');
    AppLogger.logInfo('ProphetLocalizationLoader', 'Prophet Type: $prophetType');
    AppLogger.logInfo('ProphetLocalizationLoader', 'Detected Locale: $locale');
    AppLogger.logInfo('ProphetLocalizationLoader', 'Context Locale: ${Localizations.localeOf(context)}');
    
    final data = await loadProphetLocalization(prophetType, locale);
    
    debugPrint('Loaded Data Keys: ${data.keys.toList()}');
    debugPrint('AI System Prompt exists: ${data.containsKey('aiSystemPrompt')}');
    
    AppLogger.logInfo('ProphetLocalizationLoader', 'Loaded Data Keys: ${data.keys.toList()}');
    AppLogger.logInfo('ProphetLocalizationLoader', 'AI System Prompt exists: ${data.containsKey('aiSystemPrompt')}');
    
    final prompt = data['aiSystemPrompt'] ?? 'You are a wise oracle providing guidance.';
    final isDefault = !data.containsKey('aiSystemPrompt');
    
    debugPrint('Using default prompt: $isDefault');
    debugPrint('Prompt length: ${prompt.length} characters');
    debugPrint('Prompt preview: ${prompt.substring(0, prompt.length > 100 ? 100 : prompt.length)}...');
    debugPrint('=== END AI SYSTEM PROMPT LOADING ===');
    
    AppLogger.logWarning('ProphetLocalizationLoader', 'Using default prompt: $isDefault');
    AppLogger.logInfo('ProphetLocalizationLoader', 'Prompt length: ${prompt.length} characters');
    AppLogger.logInfo('ProphetLocalizationLoader', 'Prompt preview: ${prompt.substring(0, prompt.length > 100 ? 100 : prompt.length)}...');
    AppLogger.logInfo('ProphetLocalizationLoader', '=== END AI SYSTEM PROMPT LOADING ===');
    
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
    
    debugPrint('Starting prophet localization asset verification...');
    AppLogger.logInfo('ProphetLocalizationLoader', 'Starting prophet localization asset verification...');
    
    for (final prophetType in prophetTypes) {
      for (final locale in locales) {
        try {
          final fileName = '${prophetType}_$locale.json';
          final path = 'lib/l10n/prophets/$prophetType/$fileName';
          
          await rootBundle.loadString(path);
          debugPrint('✓ Asset found: $path');
          AppLogger.logInfo('ProphetLocalizationLoader', '✓ Asset found: $path');
        } catch (e) {
          debugPrint('✗ Asset missing: lib/l10n/prophets/$prophetType/${prophetType}_$locale.json - Error: $e');
          AppLogger.logError('ProphetLocalizationLoader', '✗ Asset missing: lib/l10n/prophets/$prophetType/${prophetType}_$locale.json', e);
          allAssetsLoaded = false;
        }
      }
    }
    
    if (allAssetsLoaded) {
      debugPrint('All prophet localization assets are properly loaded!');
      AppLogger.logInfo('ProphetLocalizationLoader', 'All prophet localization assets are properly loaded!');
    } else {
      debugPrint('Some prophet localization assets are missing. Check pubspec.yaml assets section.');
      AppLogger.logError('ProphetLocalizationLoader', 'Some prophet localization assets are missing. Check pubspec.yaml assets section.');
    }
    
    return allAssetsLoaded;
  }
}
