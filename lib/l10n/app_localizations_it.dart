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
  String get navigationHome => 'Home';

  @override
  String get navigationOracles => 'Oracoli';

  @override
  String get navigationProfile => 'Profilo';

  @override
  String get navigationVisions => 'Visioni';

  @override
  String get navigationAIStatus => 'Stato AI';

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
  String get oracleSilent => 'L\'oracolo è in silenzio...';

  @override
  String get feedbackPositiveAction => 'Stella\nall\'Oracolo';

  @override
  String get feedbackNegativeAction => 'Sasso\nnel pozzo';

  @override
  String get feedbackFunnyAction => 'Rana nel\nmultiverso';

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
  String get profilePageTitle => 'Profilo';

  @override
  String get personalInformation => 'Informazioni Personali';

  @override
  String get preferencesAndLanguages => 'Preferenze e Lingue';

  @override
  String get interestsAndTopics => 'Interessi e Argomenti';

  @override
  String get nameLabel => 'Nome';

  @override
  String get nameHint => 'Inserisci il tuo nome';

  @override
  String get countryLabel => 'Paese';

  @override
  String get countryHint => 'Seleziona il tuo paese';

  @override
  String get genderLabel => 'Genere';

  @override
  String get genderHint => 'Seleziona il tuo genere';

  @override
  String get languagesLabel => 'Lingue';

  @override
  String get languagesHint => 'Seleziona la tua lingua preferita';

  @override
  String get interestsLabel => 'Interessi';

  @override
  String get interestsHint => 'Seleziona i tuoi interessi';

  @override
  String get saveProfile => 'Salva Profilo';

  @override
  String get profileSaved => 'Profilo salvato con successo!';

  @override
  String get genderMale => 'Maschile';

  @override
  String get genderFemale => 'Femminile';

  @override
  String get genderNonBinary => 'Non-binario';

  @override
  String get genderPreferNotToSay => 'Preferisco non dirlo';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get interestSpirituality => 'Spiritualità';

  @override
  String get interestMeditation => 'Meditazione';

  @override
  String get interestPhilosophy => 'Filosofia';

  @override
  String get interestMysticism => 'Misticismo';

  @override
  String get interestDivination => 'Divinazione';

  @override
  String get interestWisdom => 'Saggezza Antica';

  @override
  String get interestDreams => 'Interpretazione dei Sogni';

  @override
  String get interestTarot => 'Tarocchi';

  @override
  String get interestAstrology => 'Astrologia';

  @override
  String get interestNumerology => 'Numerologia';

  @override
  String languageUpdated(String language) {
    return 'Lingua dell\'app aggiornata a $language';
  }
}
