// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Orakl';

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
  String get welcomeToOrakl => 'Benvenuto in Orakl';

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

  @override
  String get visionManagement => 'Gestione Visioni';

  @override
  String get visionManagementDescription =>
      'Gestisci la cronologia delle conversazioni e le preferenze';

  @override
  String get debugTools => 'Strumenti Debug';

  @override
  String get admobDebugTest => 'Debug AdMob & Test';

  @override
  String get admobDebugTestDescription =>
      'Testa la funzionalità e i callback degli annunci';

  @override
  String get resetOnboarding => 'Reimposta Onboarding';

  @override
  String get resetOnboardingDescription =>
      'Forza la visualizzazione dell\'onboarding al riavvio dell\'app';

  @override
  String get resetOnboardingTitle => 'Reimposta Onboarding';

  @override
  String get resetOnboardingContent =>
      'Questo reimposterà lo stato dell\'onboarding. Il flusso di onboarding verrà mostrato di nuovo quando riavvii l\'app.\n\nSei sicuro?';

  @override
  String get reset => 'Reimposta';

  @override
  String get onboardingResetSuccess =>
      'Onboarding reimpostato con successo. Riavvia l\'app per vedere il flusso di onboarding.';

  @override
  String onboardingResetFailed(String error) {
    return 'Impossibile reimpostare l\'onboarding: $error';
  }

  @override
  String get conversationStatistics => 'Statistiche Conversazioni';

  @override
  String get totalConversations => 'Conversazioni Totali';

  @override
  String get totalMessages => 'Messaggi Totali';

  @override
  String get averageMessagesPerConversation =>
      'Media Messaggi per Conversazione';

  @override
  String get dataManagement => 'Gestione Dati';

  @override
  String get clearAllConversations => 'Cancella Tutte le Conversazioni';

  @override
  String get clearAllConversationsTitle => 'Cancella Tutte le Conversazioni';

  @override
  String get clearAllConversationsContent =>
      '⚠️ Questa azione eliminerà permanentemente TUTTA la cronologia delle conversazioni e non può essere annullata.\n\nSei sicuro di voler continuare?';

  @override
  String get deleteAll => 'Elimina Tutto';

  @override
  String get deletingAllConversations =>
      'Eliminazione di tutte le conversazioni...';

  @override
  String get conversationsDeletedSuccess =>
      'Tutte le conversazioni eliminate con successo';

  @override
  String conversationsDeleteFailed(String error) {
    return 'Impossibile eliminare le conversazioni: $error';
  }

  @override
  String get noConversationsYet => 'Nessuna conversazione ancora';

  @override
  String get noConversationsDescription =>
      'Inizia a chattare con un profeta per vedere le statistiche delle tue conversazioni qui.';

  @override
  String failedToLoadConversationData(String error) {
    return 'Impossibile caricare i dati delle conversazioni: $error';
  }

  @override
  String get personalInformationDescription =>
      'Gestisci le tue informazioni personali di base';

  @override
  String get interestsAndTopicsDescription =>
      'Seleziona le tue aree di interesse';

  @override
  String get personalizeYourExperienceDescription =>
      'Personalizza le tue preferenze di guida';

  @override
  String get yourAiProfile => 'Il Tuo Profilo AI';

  @override
  String get yourAiProfileDescription =>
      'Visualizza il tuo profilo biografico generato e le impostazioni sulla privacy';

  @override
  String failedToLoadProfile(String error) {
    return 'Impossibile caricare il profilo: $error';
  }

  @override
  String failedToSaveProfile(String error) {
    return 'Impossibile salvare il profilo: $error';
  }

  @override
  String get yourProfile => 'Il Tuo Profilo';

  @override
  String get biographicalDataDeletedSuccess =>
      'Tutti i dati biografici eliminati con successo';

  @override
  String failedToDeleteData(String error) {
    return 'Impossibile eliminare i dati: $error';
  }

  @override
  String get deleteBiographicalData => 'Elimina Dati Biografici';

  @override
  String get deleteBiographicalDataContent =>
      'Questo eliminerà permanentemente tutte le tue informazioni biografiche. Questa azione non può essere annullata.\n\nSei sicuro di voler continuare?';

  @override
  String get deleteAllData => 'Elimina Tutti i Dati';

  @override
  String failedToLoadBiographicalProfile(String error) {
    return 'Impossibile caricare il profilo biografico: $error';
  }

  @override
  String get loadingYourProfile => 'Caricamento del tuo profilo...';

  @override
  String get retry => 'Riprova';

  @override
  String get noBioAvailable =>
      'Nessuna biografia ancora disponibile. I profeti hanno bisogno di più informazioni.';

  @override
  String get askTheProphets => 'Chiedi ai Profeti';

  @override
  String get yourProfileHeader => 'Il Tuo Profilo';

  @override
  String get generatedFromProphetInteractions =>
      'Generato dalle tue interazioni con i profeti';

  @override
  String get noBiographicalContentAvailable =>
      'Nessun contenuto biografico disponibile';

  @override
  String get deleteAllDataTooltip => 'Elimina Tutti i Dati';

  @override
  String get privacyConsentTitle => 'Privacy dei Dati e Personalizzazione';

  @override
  String get privacyConsentMessage =>
      'Per fornirti risposte personalizzate, Orakl può memorizzare e analizzare le tue interazioni con i profeti.\n\nQuesti dati sono utilizzati esclusivamente per migliorare la tua esperienza e non saranno mai condivisi con partner esterni.\n\nVuoi abilitare le risposte personalizzate?';

  @override
  String get enablePersonalization => 'Abilita Personalizzazione';

  @override
  String get disablePersonalization => 'Disabilita Personalizzazione';

  @override
  String get reviewPrivacyPolicy => 'Consulta Privacy Policy';

  @override
  String get privacySettings => 'Impostazioni Privacy';

  @override
  String get privacySettingsDescription =>
      'Gestisci le tue preferenze di personalizzazione dati';

  @override
  String get personalizationStatus => 'Stato Personalizzazione';

  @override
  String get enabled => 'Abilitata';

  @override
  String get disabled => 'Disabilitata';

  @override
  String get howItWorks => 'Come Funziona';

  @override
  String get personalizationEnabledDescription =>
      'Le tue interazioni con i profeti vengono analizzate per fornire risposte personalizzate.';

  @override
  String get personalizationDisabledDescription =>
      'La personalizzazione è disabilitata. Nessun dato viene raccolto dalle tue interazioni.';

  @override
  String get personalizationEnabledFeature1 =>
      'Vengono raccolte informazioni dalle tue domande e conversazioni';

  @override
  String get personalizationEnabledFeature2 =>
      'Questi dati aiutano i profeti a dare risposte più pertinenti';

  @override
  String get personalizationEnabledFeature3 =>
      'I tuoi dati non vengono mai condivisi con partner esterni';

  @override
  String get personalizationDisabledFeature1 =>
      'Nessuna informazione personale viene raccolta o memorizzata';

  @override
  String get personalizationDisabledFeature2 =>
      'I profeti forniscono risposte generiche';

  @override
  String get personalizationDisabledFeature3 =>
      'Puoi abilitare la personalizzazione in qualsiasi momento';

  @override
  String get settings => 'Impostazioni';

  @override
  String get updating => 'Aggiornamento...';

  @override
  String get disablePersonalizationWarning =>
      'Attenzione: Disabilitare la personalizzazione eliminerà permanentemente tutti i dati raccolti.';

  @override
  String get enablePersonalizationNote =>
      'Nota: Abilitare la personalizzazione inizierà a raccogliere dati dalle future interazioni.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get confirmDisablePersonalization =>
      'Conferma Disabilitazione Personalizzazione';

  @override
  String get disablePersonalizationConfirmMessage =>
      'Sei sicuro di voler disabilitare la personalizzazione? Questa azione eliminerà permanentemente tutti i tuoi dati raccolti e non può essere annullata.';

  @override
  String get disable => 'Disabilita';

  @override
  String get personalizationEnabledSuccess =>
      'Personalizzazione abilitata con successo';

  @override
  String get personalizationDisabledSuccess =>
      'Personalizzazione disabilitata e dati eliminati con successo';
}
