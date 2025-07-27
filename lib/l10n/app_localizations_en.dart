// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Profet AI';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationOracles => 'Oracles';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get navigationVisions => 'Visions';

  @override
  String get navigationAIStatus => 'AI Status';

  @override
  String get selectYourOracle => 'SELECT YOUR ORACLE';

  @override
  String get everyOracleUniquePersonality =>
      'Every oracle has its unique personality';

  @override
  String get askTheOracle => 'ASK THE ORACLE';

  @override
  String get listenToOracle => 'LISTEN TO THE ORACLE';

  @override
  String enterQuestionPlaceholder(String oracleName) {
    return 'Ask your question to $oracleName...';
  }

  @override
  String get enterQuestionFirst => '📝 Enter a question before asking!';

  @override
  String oracleResponds(String oracleName) {
    return '🔮 $oracleName Responds';
  }

  @override
  String get oracleSilent => 'The oracle is silent...';

  @override
  String get feedbackPositiveAction => 'Star to\nthe Oracle';

  @override
  String get feedbackNegativeAction => 'Stone in\nthe well';

  @override
  String get feedbackFunnyAction => 'Frog in the\nmultiverse';

  @override
  String visionOf(String oracleName) {
    return '✨ Vision of $oracleName';
  }

  @override
  String get positiveResponse => 'The vision has illuminated my path';

  @override
  String get negativeResponse => 'The vision was obscured';

  @override
  String get funnyResponse => 'I didn\'t understand, but it made me laugh';

  @override
  String get aiStatus => 'AI Status';

  @override
  String get aiServiceStatus => 'AI Service Status';

  @override
  String get aiServiceOperational =>
      'AI Service is operational and ready to provide responses';

  @override
  String get aiServiceNotAvailable =>
      'AI Service is not available. Check configuration.';

  @override
  String get configurationStatus => 'Configuration Status';

  @override
  String get buildConfig => 'Build Config';

  @override
  String get configured => 'Configured';

  @override
  String get notConfigured => 'Not Configured';

  @override
  String get aiAvailable => 'AI Available';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get endpoint => 'Endpoint';

  @override
  String get apiKey => 'API Key';

  @override
  String get deployment => 'Deployment';

  @override
  String get aiEnabled => 'AI Enabled';

  @override
  String get empty => 'Empty';

  @override
  String get refreshStatus => 'Refresh Status';

  @override
  String get copyDebugInfo => 'Copy Debug Info';

  @override
  String get clearRuntimeLogs => 'Clear Runtime Logs';

  @override
  String get runtimeLogsCleared => 'Runtime logs cleared';

  @override
  String get debugInfoCopied => 'Debug information copied to clipboard';

  @override
  String get visionBookComingSoon => 'Book of Visions\\n(Coming Soon)';

  @override
  String get aiActive => '🎯 AI Active!';

  @override
  String aiActiveMessage(String debugInfo) {
    return 'Artificial intelligence is configured correctly. Your oracles can provide personalized responses.\\n\\n$debugInfo';
  }

  @override
  String get aiNotAvailable => '⚠️ AI Not Available';

  @override
  String aiNotAvailableMessage(
    String isAIAvailable,
    String isBuildConfigValid,
    String debugInfo,
  ) {
    return 'AI configuration has problems:\\n\\n• AI Available: $isAIAvailable\\n• Build Config Valid: $isBuildConfigValid\\n\\n$debugInfo';
  }

  @override
  String get ok => 'OK';

  @override
  String get loadingProphetsFromUniverse =>
      'Loading prophets from the universe';

  @override
  String get initializationError => 'Initialization Error';

  @override
  String failedToInitializeApp(String error) {
    return 'Failed to initialize app: $error';
  }

  @override
  String get profilePageTitle => 'Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get preferencesAndLanguages => 'Preferences & Languages';

  @override
  String get interestsAndTopics => 'Interests & Topics';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameHint => 'Enter your name';

  @override
  String get countryLabel => 'Country';

  @override
  String get countryHint => 'Select your country';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderHint => 'Select your gender';

  @override
  String get languagesLabel => 'Languages';

  @override
  String get languagesHint => 'Select your preferred languages';

  @override
  String get interestsLabel => 'Interests';

  @override
  String get interestsHint => 'Select your interests';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get profileSaved => 'Profile saved successfully!';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get genderPreferNotToSay => 'Prefer not to say';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italian';

  @override
  String get interestSpirituality => 'Spirituality';

  @override
  String get interestMeditation => 'Meditation';

  @override
  String get interestPhilosophy => 'Philosophy';

  @override
  String get interestMysticism => 'Mysticism';

  @override
  String get interestDivination => 'Divination';

  @override
  String get interestWisdom => 'Ancient Wisdom';

  @override
  String get interestDreams => 'Dream Interpretation';

  @override
  String get interestTarot => 'Tarot';

  @override
  String get interestAstrology => 'Astrology';

  @override
  String get interestNumerology => 'Numerology';
}
