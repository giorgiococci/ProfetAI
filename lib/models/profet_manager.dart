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
}
