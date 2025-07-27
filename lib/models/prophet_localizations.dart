import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'profet_manager.dart';

/// Helper class to get localized texts for prophets
/// This makes it easy to add new prophets without touching the localization logic
class ProphetLocalizations {
  final AppLocalizations _localizations;
  
  const ProphetLocalizations._(this._localizations);
  
  static ProphetLocalizations of(BuildContext context) {
    return ProphetLocalizations._(AppLocalizations.of(context)!);
  }
  
  /// Get the localized name for a prophet
  String getName(ProfetType type) {
    switch (type) {
      case ProfetType.mistico:
        return _localizations.prophetMysticName;
      case ProfetType.caotico:
        return _localizations.prophetChaoticName;
      case ProfetType.cinico:
        return _localizations.prophetCynicalName;
    }
  }
  
  /// Get the localized description for a prophet
  String getDescription(ProfetType type) {
    switch (type) {
      case ProfetType.mistico:
        return _localizations.prophetMysticDescription;
      case ProfetType.caotico:
        return _localizations.prophetChaoticDescription;
      case ProfetType.cinico:
        return _localizations.prophetCynicalDescription;
    }
  }
  
  /// Get the localized location for a prophet
  String getLocation(ProfetType type) {
    switch (type) {
      case ProfetType.mistico:
        return _localizations.prophetMysticLocation;
      case ProfetType.caotico:
        return _localizations.prophetChaoticLocation;
      case ProfetType.cinico:
        return _localizations.prophetCynicalLocation;
    }
  }
  
  /// Get the localized loading message for a prophet
  String getLoadingMessage(ProfetType type) {
    switch (type) {
      case ProfetType.mistico:
        return _localizations.prophetMysticLoadingMessage;
      case ProfetType.caotico:
        return _localizations.prophetChaoticLoadingMessage;
      case ProfetType.cinico:
        return _localizations.prophetCynicalLoadingMessage;
    }
  }
  
  /// Get the localized positive feedback for a prophet
  String getPositiveFeedback(ProfetType type) {
    switch (type) {
      case ProfetType.mistico:
        return _localizations.prophetMysticPositiveFeedback;
      case ProfetType.caotico:
        return _localizations.prophetChaoticPositiveFeedback;
      case ProfetType.cinico:
        return _localizations.prophetCynicalPositiveFeedback;
    }
  }
  
  /// Get the localized negative feedback for a prophet
  String getNegativeFeedback(ProfetType type) {
    switch (type) {
      case ProfetType.mistico:
        return _localizations.prophetMysticNegativeFeedback;
      case ProfetType.caotico:
        return _localizations.prophetChaoticNegativeFeedback;
      case ProfetType.cinico:
        return _localizations.prophetCynicalNegativeFeedback;
    }
  }
  
  /// Get the localized funny feedback for a prophet
  String getFunnyFeedback(ProfetType type) {
    switch (type) {
      case ProfetType.mistico:
        return _localizations.prophetMysticFunnyFeedback;
      case ProfetType.caotico:
        return _localizations.prophetChaoticFunnyFeedback;
      case ProfetType.cinico:
        return _localizations.prophetCynicalFunnyFeedback;
    }
  }
}
