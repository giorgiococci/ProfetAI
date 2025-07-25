import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

/// Helper class for prophet-specific localizations
/// This provides a clean, scalable way to get localized text for any prophet
class ProphetLocalizations {
  
  /// Get the localized name for a prophet
  static String getName(BuildContext context, String prophetType) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (prophetType.toLowerCase()) {
      case 'oracolo_mistico':
      case 'mystic':
        return l10n.prophetMysticName;
      case 'oracolo_caotico':
      case 'chaotic':
        return l10n.prophetChaoticName;
      case 'oracolo_cinico':
      case 'cynical':
        return l10n.prophetCynicalName;
      default:
        return prophetType; // Fallback to the original name
    }
  }
  
  /// Get the localized description for a prophet
  static String getDescription(BuildContext context, String prophetType) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (prophetType.toLowerCase()) {
      case 'oracolo_mistico':
      case 'mystic':
        return l10n.prophetMysticDescription;
      case 'oracolo_caotico':
      case 'chaotic':
        return l10n.prophetChaoticDescription;
      case 'oracolo_cinico':
      case 'cynical':
        return l10n.prophetCynicalDescription;
      default:
        return prophetType; // Fallback
    }
  }
  
  /// Get the localized location for a prophet
  static String getLocation(BuildContext context, String prophetType) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (prophetType.toLowerCase()) {
      case 'oracolo_mistico':
      case 'mystic':
        return l10n.prophetMysticLocation;
      case 'oracolo_caotico':
      case 'chaotic':
        return l10n.prophetChaoticLocation;
      case 'oracolo_cinico':
      case 'cynical':
        return l10n.prophetCynicalLocation;
      default:
        return prophetType; // Fallback
    }
  }
  
  /// Get the localized loading message for a prophet
  static String getLoadingMessage(BuildContext context, String prophetType) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (prophetType.toLowerCase()) {
      case 'oracolo_mistico':
      case 'mystic':
        return l10n.prophetMysticLoadingMessage;
      case 'oracolo_caotico':
      case 'chaotic':
        return l10n.prophetChaoticLoadingMessage;
      case 'oracolo_cinico':
      case 'cynical':
        return l10n.prophetCynicalLoadingMessage;
      default:
        return 'Loading...'; // Fallback
    }
  }
  
  /// Get the localized feedback message for a prophet
  static String getFeedback(BuildContext context, String prophetType, String feedbackType) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (prophetType.toLowerCase()) {
      case 'oracolo_mistico':
      case 'mystic':
        switch (feedbackType.toLowerCase()) {
          case 'positive':
            return l10n.prophetMysticPositiveFeedback;
          case 'negative':
            return l10n.prophetMysticNegativeFeedback;
          case 'funny':
            return l10n.prophetMysticFunnyFeedback;
          default:
            return l10n.prophetMysticPositiveFeedback;
        }
      case 'oracolo_caotico':
      case 'chaotic':
        switch (feedbackType.toLowerCase()) {
          case 'positive':
            return l10n.prophetChaoticPositiveFeedback;
          case 'negative':
            return l10n.prophetChaoticNegativeFeedback;
          case 'funny':
            return l10n.prophetChaoticFunnyFeedback;
          default:
            return l10n.prophetChaoticPositiveFeedback;
        }
      case 'oracolo_cinico':
      case 'cynical':
        switch (feedbackType.toLowerCase()) {
          case 'positive':
            return l10n.prophetCynicalPositiveFeedback;
          case 'negative':
            return l10n.prophetCynicalNegativeFeedback;
          case 'funny':
            return l10n.prophetCynicalFunnyFeedback;
          default:
            return l10n.prophetCynicalPositiveFeedback;
        }
      default:
        return 'Thank you for your feedback'; // Fallback
    }
  }
}
