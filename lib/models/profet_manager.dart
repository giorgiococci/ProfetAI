import 'profet.dart';
import 'oracolo_mistico.dart';
import 'oracolo_caotico.dart';
import 'oracolo_cinico.dart';

enum ProfetType { mistico, caotico, cinico }

class ProfetManager {
  static const Map<ProfetType, Profet> _profeti = {
    ProfetType.mistico: OracoloMistico(),
    ProfetType.caotico: OracoloCaotico(),
    ProfetType.cinico: OracoloCinico(),
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
