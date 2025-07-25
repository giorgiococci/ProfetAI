import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Profet AI'**
  String get appTitle;

  /// Title for oracle selection screen
  ///
  /// In en, this message translates to:
  /// **'SELECT YOUR ORACLE'**
  String get selectYourOracle;

  /// Subtitle for oracle selection screen
  ///
  /// In en, this message translates to:
  /// **'Every oracle has its unique personality'**
  String get everyOracleUniquePersonality;

  /// Button text to ask the oracle a question
  ///
  /// In en, this message translates to:
  /// **'ASK THE ORACLE'**
  String get askTheOracle;

  /// Button text to listen to oracle's vision without a question
  ///
  /// In en, this message translates to:
  /// **'LISTEN TO THE ORACLE'**
  String get listenToOracle;

  /// Placeholder text for question input field
  ///
  /// In en, this message translates to:
  /// **'Ask your question to {oracleName}...'**
  String enterQuestionPlaceholder(String oracleName);

  /// Snackbar message when user tries to ask without entering a question
  ///
  /// In en, this message translates to:
  /// **'📝 Enter a question before asking!'**
  String get enterQuestionFirst;

  /// Dialog title when oracle responds to a question
  ///
  /// In en, this message translates to:
  /// **'🔮 {oracleName} Responds'**
  String oracleResponds(String oracleName);

  /// Dialog title for oracle's vision
  ///
  /// In en, this message translates to:
  /// **'✨ Vision of {oracleName}'**
  String visionOf(String oracleName);

  /// Positive feedback text
  ///
  /// In en, this message translates to:
  /// **'The vision has illuminated my path'**
  String get positiveResponse;

  /// Negative feedback text
  ///
  /// In en, this message translates to:
  /// **'The vision was obscured'**
  String get negativeResponse;

  /// Funny feedback text
  ///
  /// In en, this message translates to:
  /// **'I didn\'t understand, but it made me laugh'**
  String get funnyResponse;

  /// AI status screen title
  ///
  /// In en, this message translates to:
  /// **'AI Status'**
  String get aiStatus;

  /// AI service status section title
  ///
  /// In en, this message translates to:
  /// **'AI Service Status'**
  String get aiServiceStatus;

  /// Message when AI service is working
  ///
  /// In en, this message translates to:
  /// **'AI Service is operational and ready to provide responses'**
  String get aiServiceOperational;

  /// Message when AI service is not available
  ///
  /// In en, this message translates to:
  /// **'AI Service is not available. Check configuration.'**
  String get aiServiceNotAvailable;

  /// Configuration status section title
  ///
  /// In en, this message translates to:
  /// **'Configuration Status'**
  String get configurationStatus;

  /// Build configuration label
  ///
  /// In en, this message translates to:
  /// **'Build Config'**
  String get buildConfig;

  /// Status when something is configured
  ///
  /// In en, this message translates to:
  /// **'Configured'**
  String get configured;

  /// Status when something is not configured
  ///
  /// In en, this message translates to:
  /// **'Not Configured'**
  String get notConfigured;

  /// AI availability label
  ///
  /// In en, this message translates to:
  /// **'AI Available'**
  String get aiAvailable;

  /// Yes answer
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No answer
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// API endpoint label
  ///
  /// In en, this message translates to:
  /// **'Endpoint'**
  String get endpoint;

  /// API key label
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// Deployment label
  ///
  /// In en, this message translates to:
  /// **'Deployment'**
  String get deployment;

  /// AI enabled status label
  ///
  /// In en, this message translates to:
  /// **'AI Enabled'**
  String get aiEnabled;

  /// Status when a field is empty
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// Button to refresh status
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get refreshStatus;

  /// Button to copy debug information
  ///
  /// In en, this message translates to:
  /// **'Copy Debug Info'**
  String get copyDebugInfo;

  /// Button to clear runtime logs
  ///
  /// In en, this message translates to:
  /// **'Clear Runtime Logs'**
  String get clearRuntimeLogs;

  /// Message when runtime logs are cleared
  ///
  /// In en, this message translates to:
  /// **'Runtime logs cleared'**
  String get runtimeLogsCleared;

  /// Message when debug info is copied
  ///
  /// In en, this message translates to:
  /// **'Debug information copied to clipboard'**
  String get debugInfoCopied;

  /// Coming soon message for vision book
  ///
  /// In en, this message translates to:
  /// **'Book of Visions\\n(Coming Soon)'**
  String get visionBookComingSoon;

  /// Title when AI is active
  ///
  /// In en, this message translates to:
  /// **'🎯 AI Active!'**
  String get aiActive;

  /// Message when AI is active and working
  ///
  /// In en, this message translates to:
  /// **'Artificial intelligence is configured correctly. Your oracles can provide personalized responses.\\n\\n{debugInfo}'**
  String aiActiveMessage(String debugInfo);

  /// Title when AI is not available
  ///
  /// In en, this message translates to:
  /// **'⚠️ AI Not Available'**
  String get aiNotAvailable;

  /// Message when AI is not available with details
  ///
  /// In en, this message translates to:
  /// **'AI configuration has problems:\\n\\n• AI Available: {isAIAvailable}\\n• Build Config Valid: {isBuildConfigValid}\\n\\n{debugInfo}'**
  String aiNotAvailableMessage(
    String isAIAvailable,
    String isBuildConfigValid,
    String debugInfo,
  );

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Loading message on splash screen
  ///
  /// In en, this message translates to:
  /// **'Loading prophets from the universe'**
  String get loadingProphetsFromUniverse;

  /// Title for initialization error dialog
  ///
  /// In en, this message translates to:
  /// **'Initialization Error'**
  String get initializationError;

  /// Error message when app fails to initialize
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize app: {error}'**
  String failedToInitializeApp(String error);

  /// Name of the Mystic Oracle prophet
  ///
  /// In en, this message translates to:
  /// **'Mystic Oracle'**
  String get prophetMysticName;

  /// Description of the Mystic Oracle
  ///
  /// In en, this message translates to:
  /// **'The Mystic Oracle awaits you'**
  String get prophetMysticDescription;

  /// Location title for Mystic Oracle
  ///
  /// In en, this message translates to:
  /// **'TEMPLE OF VISIONS'**
  String get prophetMysticLocation;

  /// Loading message when Mystic Oracle is thinking
  ///
  /// In en, this message translates to:
  /// **'The Mystic Oracle is consulting the cosmic energies...'**
  String get prophetMysticLoadingMessage;

  /// Positive feedback for Mystic Oracle
  ///
  /// In en, this message translates to:
  /// **'The stars have guided my soul'**
  String get prophetMysticPositiveFeedback;

  /// Negative feedback for Mystic Oracle
  ///
  /// In en, this message translates to:
  /// **'The cosmic mists have veiled the truth'**
  String get prophetMysticNegativeFeedback;

  /// Funny feedback for Mystic Oracle
  ///
  /// In en, this message translates to:
  /// **'The mystic winds have brought confusion, but also smiles'**
  String get prophetMysticFunnyFeedback;

  /// Name of the Chaotic Oracle prophet
  ///
  /// In en, this message translates to:
  /// **'Chaotic Oracle'**
  String get prophetChaoticName;

  /// Description of the Chaotic Oracle
  ///
  /// In en, this message translates to:
  /// **'Chaos calls you... maybe'**
  String get prophetChaoticDescription;

  /// Location title for Chaotic Oracle
  ///
  /// In en, this message translates to:
  /// **'DIMENSION OF CHAOS'**
  String get prophetChaoticLocation;

  /// Loading message when Chaotic Oracle is thinking
  ///
  /// In en, this message translates to:
  /// **'The Chaotic Oracle is... wait, what was I doing again?'**
  String get prophetChaoticLoadingMessage;

  /// Positive feedback for Chaotic Oracle
  ///
  /// In en, this message translates to:
  /// **'Chaos has smiled upon me! Or maybe it was indigestion?'**
  String get prophetChaoticPositiveFeedback;

  /// Negative feedback for Chaotic Oracle
  ///
  /// In en, this message translates to:
  /// **'Even chaos is confused by this vision'**
  String get prophetChaoticNegativeFeedback;

  /// Funny feedback for Chaotic Oracle
  ///
  /// In en, this message translates to:
  /// **'I understood everything and nothing, perfectly chaotic!'**
  String get prophetChaoticFunnyFeedback;

  /// Name of the Cynical Oracle prophet
  ///
  /// In en, this message translates to:
  /// **'Cynical Oracle'**
  String get prophetCynicalName;

  /// Description of the Cynical Oracle
  ///
  /// In en, this message translates to:
  /// **'Reality is disappointing, as always'**
  String get prophetCynicalDescription;

  /// Location title for Cynical Oracle
  ///
  /// In en, this message translates to:
  /// **'TOWER OF DISILLUSION'**
  String get prophetCynicalLocation;

  /// Loading message when Cynical Oracle is thinking
  ///
  /// In en, this message translates to:
  /// **'The Cynical Oracle is reluctantly thinking...'**
  String get prophetCynicalLoadingMessage;

  /// Positive feedback for Cynical Oracle
  ///
  /// In en, this message translates to:
  /// **'Well, that wasn\'t as terrible as expected'**
  String get prophetCynicalPositiveFeedback;

  /// Negative feedback for Cynical Oracle
  ///
  /// In en, this message translates to:
  /// **'As I expected, another disappointment'**
  String get prophetCynicalNegativeFeedback;

  /// Funny feedback for Cynical Oracle
  ///
  /// In en, this message translates to:
  /// **'At least the confusion was entertaining'**
  String get prophetCynicalFunnyFeedback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
