import 'package:flutter/material.dart';
import '../../models/profet_manager.dart';
import '../../prophet_localizations.dart';

/// Utility class for prophet-related helper functions
/// Provides static methods for prophet type conversions and operations
class ProphetUtils {
  
  /// Converts ProfetType enum to string for localization
  static String prophetTypeToString(ProfetType profetType) {
    switch (profetType) {
      case ProfetType.mistico:
        return 'mystic';
      case ProfetType.caotico:
        return 'chaotic';
      case ProfetType.cinico:
        return 'cynical';
      case ProfetType.roaster:
        return 'roaster';
    }
  }

  /// Converts string to ProfetType enum (useful for profile storage)
  static ProfetType? stringToProphetType(String prophetString) {
    switch (prophetString.toLowerCase()) {
      case 'mystic':
        return ProfetType.mistico;
      case 'chaotic':
        return ProfetType.caotico;
      case 'cynical':
        return ProfetType.cinico;
      case 'roaster':
        return ProfetType.roaster;
      default:
        return null;
    }
  }

  /// Gets localized prophet name from ProfetType
  static Future<String> getProphetName(BuildContext context, ProfetType profetType) async {
    final prophetTypeString = prophetTypeToString(profetType);
    return await ProphetLocalizations.getName(context, prophetTypeString);
  }

  /// Validates prophet type selection
  static bool isValidProphetType(String? prophetString) {
    if (prophetString == null) return false;
    return stringToProphetType(prophetString) != null;
  }

  /// Gets all available prophet types as string list
  static List<String> getAllProphetTypeStrings() {
    return ProfetType.values.map((type) => prophetTypeToString(type)).toList();
  }

  /// Gets all available prophet types
  static List<ProfetType> getAllProphetTypes() {
    return ProfetType.values;
  }

  /// Checks if a prophet type is AI-compatible
  static bool supportsAI(ProfetType profetType) {
    // All current prophet types support AI
    return true;
  }

  /// Gets prophet emoji/symbol representation
  static String getProphetSymbol(ProfetType profetType) {
    switch (profetType) {
      case ProfetType.mistico:
        return '🔮';
      case ProfetType.caotico:
        return '⚡';
      case ProfetType.cinico:
        return '🎭';
      case ProfetType.roaster:
        return '🔥';
    }
  }

  /// Gets appropriate icon for prophet type
  static IconData getProphetIcon(ProfetType profetType) {
    switch (profetType) {
      case ProfetType.mistico:
        return Icons.auto_awesome;
      case ProfetType.caotico:
        return Icons.whatshot;
      case ProfetType.cinico:
        return Icons.psychology_alt;
      case ProfetType.roaster:
        return Icons.local_fire_department;
    }
  }
}
