// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Profet AI';

  @override
  String get selectYourOracle => 'SELEZIONA IL TUO ORACOLO';

  @override
  String get everyOracleUniquePersonality =>
      'Ogni oracolo ha la sua personalità unica';

  @override
  String get askTheOracle => 'DOMANDA ALL\'ORACOLO';

  @override
  String get listenToOracle => 'ASCOLTA L\'ORACOLO';

  @override
  String enterQuestionPlaceholder(String oracleName) {
    return 'Poni la tua domanda all\'$oracleName...';
  }

  @override
  String get enterQuestionFirst =>
      '📝 Inserisci una domanda prima di chiedere!';

  @override
  String oracleResponds(String oracleName) {
    return '🔮 $oracleName Risponde';
  }

  @override
  String visionOf(String oracleName) {
    return '✨ Visione di $oracleName';
  }

  @override
  String get positiveResponse => 'La visione ha illuminato il mio cammino';

  @override
  String get negativeResponse => 'La visione era offuscata';

  @override
  String get funnyResponse => 'Non ho capito, ma mi ha fatto ridere';

  @override
  String get aiStatus => 'Stato AI';

  @override
  String get aiServiceStatus => 'Stato Servizio AI';

  @override
  String get aiServiceOperational =>
      'Il servizio AI è operativo e pronto a fornire risposte';

  @override
  String get aiServiceNotAvailable =>
      'Il servizio AI non è disponibile. Controllare la configurazione.';

  @override
  String get configurationStatus => 'Stato Configurazione';

  @override
  String get buildConfig => 'Configurazione Build';

  @override
  String get configured => 'Configurato';

  @override
  String get notConfigured => 'Non Configurato';

  @override
  String get aiAvailable => 'AI Disponibile';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get endpoint => 'Endpoint';

  @override
  String get apiKey => 'Chiave API';

  @override
  String get deployment => 'Deployment';

  @override
  String get aiEnabled => 'AI Abilitata';

  @override
  String get empty => 'Vuoto';

  @override
  String get refreshStatus => 'Aggiorna Stato';

  @override
  String get copyDebugInfo => 'Copia Info Debug';

  @override
  String get clearRuntimeLogs => 'Cancella Log Runtime';

  @override
  String get runtimeLogsCleared => 'Log runtime cancellati';

  @override
  String get debugInfoCopied => 'Informazioni debug copiate negli appunti';

  @override
  String get visionBookComingSoon => 'Libro delle Visioni\\n(Coming Soon)';

  @override
  String get aiActive => '🎯 AI Attiva!';

  @override
  String aiActiveMessage(String debugInfo) {
    return 'L\'intelligenza artificiale è configurata correttamente. I tuoi oracoli possono fornire risposte personalizzate.\\n\\n$debugInfo';
  }

  @override
  String get aiNotAvailable => '⚠️ AI Non Disponibile';

  @override
  String aiNotAvailableMessage(
    String isAIAvailable,
    String isBuildConfigValid,
    String debugInfo,
  ) {
    return 'Configurazione AI ha problemi:\\n\\n• AI Available: $isAIAvailable\\n• Build Config Valid: $isBuildConfigValid\\n\\n$debugInfo';
  }

  @override
  String get ok => 'OK';

  @override
  String get loadingProphetsFromUniverse =>
      'Caricamento profeti dall\'universo';

  @override
  String get initializationError => 'Errore di Inizializzazione';

  @override
  String failedToInitializeApp(String error) {
    return 'Impossibile inizializzare l\'app: $error';
  }

  @override
  String get prophetMysticName => 'Oracolo Mistico';

  @override
  String get prophetMysticDescription => 'L\'Oracolo Mistico ti aspetta';

  @override
  String get prophetMysticLocation => 'TEMPIO DELLE VISIONI';

  @override
  String get prophetMysticLoadingMessage =>
      'L\'Oracolo Mistico sta consultando le energie cosmiche...';

  @override
  String get prophetMysticPositiveFeedback =>
      'Le stelle hanno guidato la mia anima';

  @override
  String get prophetMysticNegativeFeedback =>
      'Le nebbie cosmiche hanno velato la verità';

  @override
  String get prophetMysticFunnyFeedback =>
      'I venti mistici hanno portato confusione, ma anche sorrisi';

  @override
  String get prophetChaoticName => 'Oracolo Caotico';

  @override
  String get prophetChaoticDescription => 'Il Caos ti chiama... forse';

  @override
  String get prophetChaoticLocation => 'DIMENSIONE DEL CAOS';

  @override
  String get prophetChaoticLoadingMessage =>
      'L\'Oracolo Caotico sta... aspetta, cosa stavo facendo?';

  @override
  String get prophetChaoticPositiveFeedback =>
      'Il caos mi ha sorriso! O forse era indigestione?';

  @override
  String get prophetChaoticNegativeFeedback =>
      'Persino il caos è confuso da questa visione';

  @override
  String get prophetChaoticFunnyFeedback =>
      'Ho capito tutto e niente, perfettamente caotico!';

  @override
  String get prophetCynicalName => 'Oracolo Cinico';

  @override
  String get prophetCynicalDescription => 'La realtà è deludente, come sempre';

  @override
  String get prophetCynicalLocation => 'TORRE DELLA DISILLUSIONE';

  @override
  String get prophetCynicalLoadingMessage =>
      'L\'Oracolo Cinico sta pensando controvoglia...';

  @override
  String get prophetCynicalPositiveFeedback =>
      'Beh, non è stato terribile come mi aspettavo';

  @override
  String get prophetCynicalNegativeFeedback =>
      'Come immaginavo, un\'altra delusione';

  @override
  String get prophetCynicalFunnyFeedback =>
      'Almeno la confusione è stata divertente';
}
