import 'package:flutter/material.dart';
import 'l10n/prophet_localization_loader.dart';

/// Helper class for prophet-specific localizations
/// This provides a clean, scalable way to get localized text for any prophet
class ProphetLocalizations {
  
  /// Get the localized name for a prophet
  static Future<String> getName(BuildContext context, String prophetType) async {
    final data = await ProphetLocalizationLoader.loadProphetLocalization(
      prophetType, 
      Localizations.localeOf(context).languageCode
    );
    return data['name'] ?? prophetType; // Fallback to the original name
  }
  
  /// Get the localized description for a prophet
  static Future<String> getDescription(BuildContext context, String prophetType) async {
    final data = await ProphetLocalizationLoader.loadProphetLocalization(
      prophetType, 
      Localizations.localeOf(context).languageCode
    );
    return data['description'] ?? prophetType; // Fallback
  }
  
  /// Get the localized location for a prophet
  static Future<String> getLocation(BuildContext context, String prophetType) async {
    final data = await ProphetLocalizationLoader.loadProphetLocalization(
      prophetType, 
      Localizations.localeOf(context).languageCode
    );
    return data['location'] ?? prophetType; // Fallback
  }
  
  /// Get the localized loading message for a prophet
  static Future<String> getLoadingMessage(BuildContext context, String prophetType) async {
    return await ProphetLocalizationLoader.getAILoadingMessage(context, prophetType);
  }
  
  /// Get the localized feedback message for a prophet
  static Future<String> getFeedback(BuildContext context, String prophetType, String feedbackType) async {
    return await ProphetLocalizationLoader.getFeedbackText(context, prophetType, feedbackType);
  }
}
