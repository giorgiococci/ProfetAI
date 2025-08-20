import 'profet.dart';
import 'oracolo_mistico.dart';
import 'oracolo_caotico.dart';
import 'oracolo_cinico.dart';
import 'oracolo_roaster.dart';

enum ProfetType { mistico, caotico, cinico, roaster }

class ProfetManager {
  static const Map<ProfetType, Profet> _profeti = {
    ProfetType.mistico: OracoloMistico(),
    ProfetType.caotico: OracoloCaotico(),
    ProfetType.cinico: OracoloCinico(),
    ProfetType.roaster: OracoloRoaster(),
  };

  static Profet getProfet(ProfetType type) {
    return _profeti[type]!;
  }

  static List<ProfetType> getAllTypes() {
    return ProfetType.values;
  }

  static List<Profet> getAllProfeti() {
    return _profeti.values.toList();
  }

  /// Convert prophet type string to enum
  /// This handles the conversion from database storage format to enum
  static ProfetType getProfetTypeFromString(String prophetTypeString) {
    switch (prophetTypeString.toLowerCase()) {
      case 'mystic_prophet':
      case 'mystic':
      case 'mistico':
        return ProfetType.mistico;
      case 'chaotic_prophet':
      case 'chaotic':
      case 'caotico':
        return ProfetType.caotico;
      case 'cynical_prophet':
      case 'cynical':
      case 'cinico':
        return ProfetType.cinico;
      case 'roaster_prophet':
      case 'roaster':
        return ProfetType.roaster;
      default:
        return ProfetType.mistico; // Default fallback
    }
  }

  /// Convert enum to string for database storage
  /// This ensures consistent string representation for storage
  static String getProfetTypeString(ProfetType type) {
    switch (type) {
      case ProfetType.mistico:
        return 'mistico';
      case ProfetType.caotico:
        return 'caotico';
      case ProfetType.cinico:
        return 'cinico';
      case ProfetType.roaster:
        return 'roaster';
    }
  }

  /// Get Profet instance from string (convenience method)
  static Profet getProfetFromString(String prophetTypeString) {
    final type = getProfetTypeFromString(prophetTypeString);
    return getProfet(type);
  }
}
