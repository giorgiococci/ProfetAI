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
  String get listenToOracle => 'LASCIA PARLARE L\'ORACOLO';

  @override
  String enterQuestionPlaceholder(String oracleName) {
    return 'Poni la tua domanda all\'$oracleName...';
  }

  @override
  String get enterQuestionFirst =>
      '📝 Inserisci una domanda prima di chiedere!';

  @override
  String get markAsFavoriteOracle => 'Segna come oracolo preferito';

  @override
  String get removeFromFavoriteOracle => 'Rimuovi dagli oracoli preferiti';

  @override
  String favoriteOracleSet(String oracleName) {
    return '✨ $oracleName è ora il tuo oracolo preferito!';
  }

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

  @override
  String get criticalActions => 'Azioni Critiche';

  @override
  String get deleteAllVisions => 'Elimina Tutte le Visioni';

  @override
  String get deleteAllVisionsWarning =>
      '⚠️ Questa azione eliminerà permanentemente tutte le tue visioni memorizzate e non può essere annullata. Sei sicuro di voler continuare?';

  @override
  String get deleteAllVisionsConfirmTitle => 'Eliminare Tutte le Visioni?';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get allVisionsDeleted =>
      'Tutte le visioni sono state eliminate con successo';

  @override
  String get failedToDeleteVisions =>
      'Impossibile eliminare le visioni. Riprova.';

  @override
  String get visionBookTitle => 'Libro delle Visioni';

  @override
  String get searchVisions => 'Cerca visioni';

  @override
  String get refreshVisions => 'Aggiorna';

  @override
  String visionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visioni',
      one: '1 visione',
      zero: 'Nessuna visione',
    );
    return '$_temp0';
  }

  @override
  String visionsFiltered(int count, int total) {
    return '$count di $total visioni';
  }

  @override
  String get filtered => 'Filtrate';

  @override
  String get deleteVision => 'Elimina Visione';

  @override
  String deleteVisionConfirm(String title) {
    return 'Sei sicuro di voler eliminare \"$title\"?';
  }

  @override
  String get errorLoadingVisions => 'Errore nel caricamento delle visioni';

  @override
  String get visionDeletedSuccessfully => 'Visione eliminata con successo';

  @override
  String get errorDeletingVision => 'Errore nell\'eliminazione della visione';

  @override
  String get feedbackUpdatedSuccessfully => 'Feedback aggiornato con successo';

  @override
  String get errorUpdatingFeedback => 'Errore nell\'aggiornamento del feedback';

  @override
  String get noVisionsMatchFilters => 'Nessuna visione corrisponde ai filtri';

  @override
  String get noVisionsStoredYet => 'Nessuna visione memorizzata';

  @override
  String get tryAdjustingFilters =>
      'Prova a modificare i criteri di ricerca o cancella i filtri per vedere tutte le visioni.';

  @override
  String get startMysticalJourney =>
      'Inizia il tuo viaggio mistico chiedendo agli oracoli una guida.';

  @override
  String get clearFilters => 'Rimuovi Filtri';

  @override
  String get allOracles => 'Tutti gli Oracoli';

  @override
  String oraclesSelected(int count) {
    return '$count Selezionati';
  }

  @override
  String get newestFirst => 'Più Recenti';

  @override
  String get oldestFirst => 'Più Vecchi';

  @override
  String get titleAZ => 'Titolo A-Z';

  @override
  String get titleZA => 'Titolo Z-A';

  @override
  String get byOracle => 'Per Oracolo';

  @override
  String sortFilter(String sortType) {
    return 'Ordina: $sortType';
  }

  @override
  String get clear => 'Cancella';

  @override
  String timeAgo(String time) {
    return '$time fa';
  }

  @override
  String daysShort(int count) {
    return '${count}g';
  }

  @override
  String hoursShort(int count) {
    return '${count}h';
  }

  @override
  String minutesShort(int count) {
    return '${count}m';
  }

  @override
  String get justNow => 'Adesso';

  @override
  String get settingsPageTitle => 'Impostazioni';

  @override
  String get userProfileSettings => 'Profilo Utente';

  @override
  String get userProfileSettingsDescription =>
      'Gestisci le tue informazioni personali';

  @override
  String get localizationSettings => 'Localizzazione';

  @override
  String get localizationSettingsDescription =>
      'Cambia lingua e regione dell\'app';

  @override
  String get deleteDataSettings => 'Elimina Dati';

  @override
  String get deleteDataSettingsDescription =>
      'Gestisci dati memorizzati e visioni';

  @override
  String get userProfilePageTitle => 'Profilo Utente';

  @override
  String get localizationPageTitle => 'Localizzazione';

  @override
  String get deleteDataPageTitle => 'Elimina Dati';

  @override
  String get skip => 'Salta';

  @override
  String get welcomeToProfetAI => 'Benvenuto in Profet AI';

  @override
  String get discoverMysticalInsights =>
      'Scopri intuizioni mistiche attraverso oracoli unici';

  @override
  String get beginJourney => 'Inizia il Viaggio';

  @override
  String get unlockMysticalPowers => 'Sblocca Poteri Mistici';

  @override
  String get personalizedPredictions => 'Predizioni Personalizzate';

  @override
  String get personalizedPredictionsDesc =>
      'Fai domande e ricevi intuizioni su misura dal tuo oracolo scelto';

  @override
  String get randomVisions => 'Visioni Casuali';

  @override
  String get randomVisionsDesc =>
      'Ottieni saggezza spontanea quando hai più bisogno di guida';

  @override
  String get visionBook => 'Libro delle Visioni';

  @override
  String get visionBookDesc =>
      'Salva e rivedi le tue predizioni e intuizioni preferite';

  @override
  String get uniqueThemes => 'Temi Unici';

  @override
  String get uniqueThemesDesc =>
      'Ogni oracolo ha la propria identità visiva mistica';

  @override
  String get continueButton => 'Continua';

  @override
  String get personalizeYourExperience => 'Personalizza la Tua Esperienza';

  @override
  String get personalizeOptional => 'Opzionale - Puoi sempre cambiarlo dopo';

  @override
  String get whatShouldOraclesCallYou =>
      'Come dovrebbero chiamarti gli oracoli?';

  @override
  String get enterYourNameOptional => 'Inserisci il tuo nome (opzionale)';

  @override
  String get doYouHavePreferredOracle => 'Hai un oracolo preferito?';

  @override
  String get enterTheMysticalRealm => 'Entra nel Regno Mistico';

  @override
  String get lifeFocusAreasLabel => 'In quali aree della vita cerchi guida?';

  @override
  String get lifeFocusAreasHint => 'Seleziona fino a 3 aree (opzionale)';

  @override
  String get lifeStageLabel =>
      'Cosa descrive meglio la tua fase di vita attuale?';

  @override
  String get lifeStageHint => 'Seleziona la tua fase attuale (opzionale)';

  @override
  String get lifeFocusLoveRelationships => 'Amore e Relazioni';

  @override
  String get lifeFocusCareerPurpose => 'Carriera e Scopo';

  @override
  String get lifeFocusFamilyHome => 'Famiglia e Casa';

  @override
  String get lifeFocusHealthWellness => 'Salute e Benessere';

  @override
  String get lifeFocusMoneyAbundance => 'Denaro e Abbondanza';

  @override
  String get lifeFocusSpiritualGrowth => 'Crescita Spirituale';

  @override
  String get lifeFocusPersonalDevelopment => 'Sviluppo Personale';

  @override
  String get lifeFocusCreativityPassion => 'Creatività e Passione';

  @override
  String get lifeStageStartingNewChapter => 'Sto iniziando un nuovo capitolo';

  @override
  String get lifeStageSeekingDirection => 'Sto cercando una direzione';

  @override
  String get lifeStageFacingChallenges => 'Sto affrontando delle sfide';

  @override
  String get lifeStagePeriodOfGrowth => 'Sono in un periodo di crescita';

  @override
  String get lifeStageLookingForStability => 'Sto cercando stabilità';

  @override
  String get lifeStageEmbracingChange => 'Sto abbracciando il cambiamento';
}
