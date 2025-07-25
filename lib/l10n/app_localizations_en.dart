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
  String get prophetMysticName => 'Mystic Oracle';

  @override
  String get prophetMysticDescription => 'The Mystic Oracle awaits you';

  @override
  String get prophetMysticLocation => 'TEMPLE OF VISIONS';

  @override
  String get prophetMysticLoadingMessage =>
      'The Mystic Oracle is consulting the cosmic energies...';

  @override
  String get prophetMysticPositiveFeedback => 'The stars have guided my soul';

  @override
  String get prophetMysticNegativeFeedback =>
      'The cosmic mists have veiled the truth';

  @override
  String get prophetMysticFunnyFeedback =>
      'The mystic winds have brought confusion, but also smiles';

  @override
  String get prophetChaoticName => 'Chaotic Oracle';

  @override
  String get prophetChaoticDescription => 'Chaos calls you... maybe';

  @override
  String get prophetChaoticLocation => 'DIMENSION OF CHAOS';

  @override
  String get prophetChaoticLoadingMessage =>
      'The Chaotic Oracle is... wait, what was I doing again?';

  @override
  String get prophetChaoticPositiveFeedback =>
      'Chaos has smiled upon me! Or maybe it was indigestion?';

  @override
  String get prophetChaoticNegativeFeedback =>
      'Even chaos is confused by this vision';

  @override
  String get prophetChaoticFunnyFeedback =>
      'I understood everything and nothing, perfectly chaotic!';

  @override
  String get prophetCynicalName => 'Cynical Oracle';

  @override
  String get prophetCynicalDescription => 'Reality is disappointing, as always';

  @override
  String get prophetCynicalLocation => 'TOWER OF DISILLUSION';

  @override
  String get prophetCynicalLoadingMessage =>
      'The Cynical Oracle is reluctantly thinking...';

  @override
  String get prophetCynicalPositiveFeedback =>
      'Well, that wasn\'t as terrible as expected';

  @override
  String get prophetCynicalNegativeFeedback =>
      'As I expected, another disappointment';

  @override
  String get prophetCynicalFunnyFeedback =>
      'At least the confusion was entertaining';
}
