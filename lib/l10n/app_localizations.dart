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
  /// **'Orakl'**
  String get appTitle;

  /// Navigation menu item for Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// Navigation menu item for Oracles
  ///
  /// In en, this message translates to:
  /// **'Oracles'**
  String get navigationOracles;

  /// Navigation menu item for Profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// Navigation menu item for Visions
  ///
  /// In en, this message translates to:
  /// **'Visions'**
  String get navigationVisions;

  /// Navigation menu item for AI Status
  ///
  /// In en, this message translates to:
  /// **'AI Status'**
  String get navigationAIStatus;

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
  /// **'LET THE ORACLE SPEAK'**
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

  /// Tooltip for marking an oracle as favorite
  ///
  /// In en, this message translates to:
  /// **'Mark as favorite oracle'**
  String get markAsFavoriteOracle;

  /// Tooltip for removing an oracle from favorites
  ///
  /// In en, this message translates to:
  /// **'Remove from favorite oracles'**
  String get removeFromFavoriteOracle;

  /// Snackbar message when an oracle is set as favorite
  ///
  /// In en, this message translates to:
  /// **'✨ {oracleName} is now your favorite oracle!'**
  String favoriteOracleSet(String oracleName);

  /// Dialog title when oracle responds to a question
  ///
  /// In en, this message translates to:
  /// **'🔮 {oracleName} Responds'**
  String oracleResponds(String oracleName);

  /// Message when oracle has no response available
  ///
  /// In en, this message translates to:
  /// **'The oracle is silent...'**
  String get oracleSilent;

  /// Action text for positive feedback
  ///
  /// In en, this message translates to:
  /// **'Star to\nthe Oracle'**
  String get feedbackPositiveAction;

  /// Action text for negative feedback
  ///
  /// In en, this message translates to:
  /// **'Stone in\nthe well'**
  String get feedbackNegativeAction;

  /// Action text for funny feedback
  ///
  /// In en, this message translates to:
  /// **'Frog in the\nmultiverse'**
  String get feedbackFunnyAction;

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

  /// Title for the profile page
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profilePageTitle;

  /// Section title for personal information
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Section title for preferences and languages
  ///
  /// In en, this message translates to:
  /// **'Preferences & Languages'**
  String get preferencesAndLanguages;

  /// Section title for interests and topics
  ///
  /// In en, this message translates to:
  /// **'Interests & Topics'**
  String get interestsAndTopics;

  /// Label for name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Hint text for name field
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameHint;

  /// Label for country field
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// Hint text for country field
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get countryHint;

  /// Label for gender field
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// Hint text for gender field
  ///
  /// In en, this message translates to:
  /// **'Select your gender'**
  String get genderHint;

  /// Label for languages field
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languagesLabel;

  /// Hint text for languages field
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get languagesHint;

  /// Label for interests field
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interestsLabel;

  /// Hint text for interests field
  ///
  /// In en, this message translates to:
  /// **'Select your interests'**
  String get interestsHint;

  /// Button text for saving profile
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// Success message when profile is saved
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSaved;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// Non-binary gender option
  ///
  /// In en, this message translates to:
  /// **'Non-binary'**
  String get genderNonBinary;

  /// Prefer not to say gender option
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNotToSay;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Italian language option
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// Spirituality interest option
  ///
  /// In en, this message translates to:
  /// **'Spirituality'**
  String get interestSpirituality;

  /// Meditation interest option
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get interestMeditation;

  /// Philosophy interest option
  ///
  /// In en, this message translates to:
  /// **'Philosophy'**
  String get interestPhilosophy;

  /// Mysticism interest option
  ///
  /// In en, this message translates to:
  /// **'Mysticism'**
  String get interestMysticism;

  /// Divination interest option
  ///
  /// In en, this message translates to:
  /// **'Divination'**
  String get interestDivination;

  /// Ancient Wisdom interest option
  ///
  /// In en, this message translates to:
  /// **'Ancient Wisdom'**
  String get interestWisdom;

  /// Dream Interpretation interest option
  ///
  /// In en, this message translates to:
  /// **'Dream Interpretation'**
  String get interestDreams;

  /// Tarot interest option
  ///
  /// In en, this message translates to:
  /// **'Tarot'**
  String get interestTarot;

  /// Astrology interest option
  ///
  /// In en, this message translates to:
  /// **'Astrology'**
  String get interestAstrology;

  /// Numerology interest option
  ///
  /// In en, this message translates to:
  /// **'Numerology'**
  String get interestNumerology;

  /// Message shown when app language is updated
  ///
  /// In en, this message translates to:
  /// **'App language updated to {language}'**
  String languageUpdated(String language);

  /// Section title for critical/warning actions in profile
  ///
  /// In en, this message translates to:
  /// **'Critical Actions'**
  String get criticalActions;

  /// Button text to delete all stored visions
  ///
  /// In en, this message translates to:
  /// **'Delete All Visions'**
  String get deleteAllVisions;

  /// Warning message when user tries to delete all visions
  ///
  /// In en, this message translates to:
  /// **'⚠️ This action will permanently delete all your stored visions and cannot be undone. Are you sure you want to continue?'**
  String get deleteAllVisionsWarning;

  /// Title for delete all visions confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete All Visions?'**
  String get deleteAllVisionsConfirmTitle;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Success message when all visions are deleted
  ///
  /// In en, this message translates to:
  /// **'All visions have been deleted successfully'**
  String get allVisionsDeleted;

  /// Error message when deleting all visions fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete visions. Please try again.'**
  String get failedToDeleteVisions;

  /// Title for the vision book screen
  ///
  /// In en, this message translates to:
  /// **'Vision Book'**
  String get visionBookTitle;

  /// Tooltip text for search visions button
  ///
  /// In en, this message translates to:
  /// **'Search visions'**
  String get searchVisions;

  /// Tooltip text for refresh visions button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshVisions;

  /// Text showing number of visions
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No visions} =1{1 vision} other{{count} visions}}'**
  String visionsCount(int count);

  /// Text showing filtered visions count
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} visions'**
  String visionsFiltered(int count, int total);

  /// Badge text indicating filtered results
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String get filtered;

  /// Title for delete vision dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Vision'**
  String get deleteVision;

  /// Confirmation message for deleting a vision
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteVisionConfirm(String title);

  /// Error message when visions fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading visions'**
  String get errorLoadingVisions;

  /// Success message when vision is deleted
  ///
  /// In en, this message translates to:
  /// **'Vision deleted successfully'**
  String get visionDeletedSuccessfully;

  /// Error message when vision deletion fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting vision'**
  String get errorDeletingVision;

  /// Success message when feedback is updated
  ///
  /// In en, this message translates to:
  /// **'Feedback updated successfully'**
  String get feedbackUpdatedSuccessfully;

  /// Error message when feedback update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating feedback'**
  String get errorUpdatingFeedback;

  /// Message when no visions match the current filters
  ///
  /// In en, this message translates to:
  /// **'No visions match your filters'**
  String get noVisionsMatchFilters;

  /// Message when no visions have been stored
  ///
  /// In en, this message translates to:
  /// **'No visions stored yet'**
  String get noVisionsStoredYet;

  /// Suggestion text when no visions match filters
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search criteria or clear filters to see all visions.'**
  String get tryAdjustingFilters;

  /// Encouraging text when no visions exist
  ///
  /// In en, this message translates to:
  /// **'Start your mystical journey by asking the oracles for guidance.'**
  String get startMysticalJourney;

  /// Button text to clear all filters
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// Text for showing all oracles filter option
  ///
  /// In en, this message translates to:
  /// **'All Oracles'**
  String get allOracles;

  /// Text showing number of selected oracles
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String oraclesSelected(int count);

  /// Sort option for newest first
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// Sort option for oldest first
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// Sort option for title A to Z
  ///
  /// In en, this message translates to:
  /// **'Title A-Z'**
  String get titleAZ;

  /// Sort option for title Z to A
  ///
  /// In en, this message translates to:
  /// **'Title Z-A'**
  String get titleZA;

  /// Sort option by oracle type
  ///
  /// In en, this message translates to:
  /// **'By Oracle'**
  String get byOracle;

  /// Active sort filter label
  ///
  /// In en, this message translates to:
  /// **'Sort: {sortType}'**
  String sortFilter(String sortType);

  /// Clear button text for filters
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Time ago format
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String timeAgo(String time);

  /// Short format for days
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String daysShort(int count);

  /// Short format for hours
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String hoursShort(int count);

  /// Short format for minutes
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String minutesShort(int count);

  /// Text for very recent time
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Title for the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// Settings menu item for user profile settings
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfileSettings;

  /// Description for user profile settings menu item
  ///
  /// In en, this message translates to:
  /// **'Manage your personal information'**
  String get userProfileSettingsDescription;

  /// Settings menu item for localization settings
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get localizationSettings;

  /// Description for localization settings menu item
  ///
  /// In en, this message translates to:
  /// **'Change app language and region'**
  String get localizationSettingsDescription;

  /// Settings menu item for delete data settings
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get deleteDataSettings;

  /// Description for delete data settings menu item
  ///
  /// In en, this message translates to:
  /// **'Manage stored data and visions'**
  String get deleteDataSettingsDescription;

  /// Title for the user profile settings page
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfilePageTitle;

  /// Title for the localization settings page
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get localizationPageTitle;

  /// Title for the delete data settings page
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get deleteDataPageTitle;

  /// Skip button text for onboarding screens
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Main welcome title for onboarding
  ///
  /// In en, this message translates to:
  /// **'Welcome to Orakl'**
  String get welcomeToOrakl;

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Discover mystical insights through unique oracles'**
  String get discoverMysticalInsights;

  /// Button text to start the onboarding journey
  ///
  /// In en, this message translates to:
  /// **'Begin Journey'**
  String get beginJourney;

  /// Features screen title
  ///
  /// In en, this message translates to:
  /// **'Unlock Mystical Powers'**
  String get unlockMysticalPowers;

  /// Feature title for personalized predictions
  ///
  /// In en, this message translates to:
  /// **'Personalized Predictions'**
  String get personalizedPredictions;

  /// Feature description for personalized predictions
  ///
  /// In en, this message translates to:
  /// **'Ask questions and receive tailored insights from your chosen oracle'**
  String get personalizedPredictionsDesc;

  /// Feature title for random visions
  ///
  /// In en, this message translates to:
  /// **'Random Visions'**
  String get randomVisions;

  /// Feature description for random visions
  ///
  /// In en, this message translates to:
  /// **'Get spontaneous wisdom when you need guidance most'**
  String get randomVisionsDesc;

  /// Feature title for vision book
  ///
  /// In en, this message translates to:
  /// **'Vision Book'**
  String get visionBook;

  /// Feature description for vision book
  ///
  /// In en, this message translates to:
  /// **'Save and revisit your favorite predictions and insights'**
  String get visionBookDesc;

  /// Feature title for unique themes
  ///
  /// In en, this message translates to:
  /// **'Unique Themes'**
  String get uniqueThemes;

  /// Feature description for unique themes
  ///
  /// In en, this message translates to:
  /// **'Each oracle has its own mystical visual identity'**
  String get uniqueThemesDesc;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Personalization screen title
  ///
  /// In en, this message translates to:
  /// **'Personalize Your Experience'**
  String get personalizeYourExperience;

  /// Subtitle indicating personalization is optional
  ///
  /// In en, this message translates to:
  /// **'Optional - You can always change this later'**
  String get personalizeOptional;

  /// Label for name input field
  ///
  /// In en, this message translates to:
  /// **'What should the oracles call you?'**
  String get whatShouldOraclesCallYou;

  /// Placeholder text for name input
  ///
  /// In en, this message translates to:
  /// **'Enter your name (optional)'**
  String get enterYourNameOptional;

  /// Label for oracle preference selection
  ///
  /// In en, this message translates to:
  /// **'Do you have a preferred oracle?'**
  String get doYouHavePreferredOracle;

  /// Final onboarding button text
  ///
  /// In en, this message translates to:
  /// **'Enter the Mystical Realm'**
  String get enterTheMysticalRealm;

  /// Label for life focus areas selection
  ///
  /// In en, this message translates to:
  /// **'What areas of life are you seeking guidance on?'**
  String get lifeFocusAreasLabel;

  /// Hint for life focus areas selection
  ///
  /// In en, this message translates to:
  /// **'Select up to 3 areas (optional)'**
  String get lifeFocusAreasHint;

  /// Label for life stage selection
  ///
  /// In en, this message translates to:
  /// **'What best describes your current life phase?'**
  String get lifeStageLabel;

  /// Hint for life stage selection
  ///
  /// In en, this message translates to:
  /// **'Select your current phase (optional)'**
  String get lifeStageHint;

  /// No description provided for @lifeFocusLoveRelationships.
  ///
  /// In en, this message translates to:
  /// **'Love & Relationships'**
  String get lifeFocusLoveRelationships;

  /// No description provided for @lifeFocusCareerPurpose.
  ///
  /// In en, this message translates to:
  /// **'Career & Purpose'**
  String get lifeFocusCareerPurpose;

  /// No description provided for @lifeFocusFamilyHome.
  ///
  /// In en, this message translates to:
  /// **'Family & Home'**
  String get lifeFocusFamilyHome;

  /// No description provided for @lifeFocusHealthWellness.
  ///
  /// In en, this message translates to:
  /// **'Health & Wellness'**
  String get lifeFocusHealthWellness;

  /// No description provided for @lifeFocusMoneyAbundance.
  ///
  /// In en, this message translates to:
  /// **'Money & Abundance'**
  String get lifeFocusMoneyAbundance;

  /// No description provided for @lifeFocusSpiritualGrowth.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Growth'**
  String get lifeFocusSpiritualGrowth;

  /// No description provided for @lifeFocusPersonalDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Personal Development'**
  String get lifeFocusPersonalDevelopment;

  /// No description provided for @lifeFocusCreativityPassion.
  ///
  /// In en, this message translates to:
  /// **'Creativity & Passion'**
  String get lifeFocusCreativityPassion;

  /// No description provided for @lifeStageStartingNewChapter.
  ///
  /// In en, this message translates to:
  /// **'Starting a new chapter'**
  String get lifeStageStartingNewChapter;

  /// No description provided for @lifeStageSeekingDirection.
  ///
  /// In en, this message translates to:
  /// **'Seeking direction'**
  String get lifeStageSeekingDirection;

  /// No description provided for @lifeStageFacingChallenges.
  ///
  /// In en, this message translates to:
  /// **'Facing challenges'**
  String get lifeStageFacingChallenges;

  /// No description provided for @lifeStagePeriodOfGrowth.
  ///
  /// In en, this message translates to:
  /// **'In a period of growth'**
  String get lifeStagePeriodOfGrowth;

  /// No description provided for @lifeStageLookingForStability.
  ///
  /// In en, this message translates to:
  /// **'Looking for stability'**
  String get lifeStageLookingForStability;

  /// No description provided for @lifeStageEmbracingChange.
  ///
  /// In en, this message translates to:
  /// **'Embracing change'**
  String get lifeStageEmbracingChange;

  /// Title for vision/conversation management
  ///
  /// In en, this message translates to:
  /// **'Vision Management'**
  String get visionManagement;

  /// Description for vision management settings
  ///
  /// In en, this message translates to:
  /// **'Manage your conversation history and preferences'**
  String get visionManagementDescription;

  /// Tooltip for debug tools button
  ///
  /// In en, this message translates to:
  /// **'Debug Tools'**
  String get debugTools;

  /// Debug tool for AdMob testing
  ///
  /// In en, this message translates to:
  /// **'AdMob Debug & Test'**
  String get admobDebugTest;

  /// Description for AdMob debug tool
  ///
  /// In en, this message translates to:
  /// **'Test ad functionality and callbacks'**
  String get admobDebugTestDescription;

  /// Option to reset onboarding
  ///
  /// In en, this message translates to:
  /// **'Reset Onboarding'**
  String get resetOnboarding;

  /// Description for reset onboarding option
  ///
  /// In en, this message translates to:
  /// **'Force onboarding to show again on app restart'**
  String get resetOnboardingDescription;

  /// Dialog title for reset onboarding
  ///
  /// In en, this message translates to:
  /// **'Reset Onboarding'**
  String get resetOnboardingTitle;

  /// Dialog content for reset onboarding confirmation
  ///
  /// In en, this message translates to:
  /// **'This will reset the onboarding status. The onboarding flow will be shown again when you restart the app.\n\nAre you sure?'**
  String get resetOnboardingContent;

  /// Button text for reset action
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Success message for onboarding reset
  ///
  /// In en, this message translates to:
  /// **'Onboarding reset successfully. Restart the app to see the onboarding flow.'**
  String get onboardingResetSuccess;

  /// Error message for onboarding reset failure
  ///
  /// In en, this message translates to:
  /// **'Failed to reset onboarding: {error}'**
  String onboardingResetFailed(String error);

  /// Title for vision statistics section
  ///
  /// In en, this message translates to:
  /// **'Visions Statistics'**
  String get conversationStatistics;

  /// Label for total vision count
  ///
  /// In en, this message translates to:
  /// **'Total Visions'**
  String get totalConversations;

  /// Label for total message count
  ///
  /// In en, this message translates to:
  /// **'Total Messages'**
  String get totalMessages;

  /// Label for average messages per vision
  ///
  /// In en, this message translates to:
  /// **'Average Messages per Vision'**
  String get averageMessagesPerConversation;

  /// Title for data management section
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Button text to clear all visions
  ///
  /// In en, this message translates to:
  /// **'Clear All Visions'**
  String get clearAllConversations;

  /// Dialog title for clear visions confirmation
  ///
  /// In en, this message translates to:
  /// **'Clear All Visions'**
  String get clearAllConversationsTitle;

  /// Dialog content for clear visions confirmation
  ///
  /// In en, this message translates to:
  /// **'⚠️ This action will permanently delete ALL your vision history and cannot be undone.\n\nAre you sure you want to continue?'**
  String get clearAllConversationsContent;

  /// Button text for delete all action
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// Progress message while deleting visions
  ///
  /// In en, this message translates to:
  /// **'Deleting all visions...'**
  String get deletingAllConversations;

  /// Success message after deleting all visions
  ///
  /// In en, this message translates to:
  /// **'All visions deleted successfully'**
  String get conversationsDeletedSuccess;

  /// Error message for vision deletion failure
  ///
  /// In en, this message translates to:
  /// **'Failed to delete visions: {error}'**
  String conversationsDeleteFailed(String error);

  /// Message when no visions exist
  ///
  /// In en, this message translates to:
  /// **'No visions yet'**
  String get noConversationsYet;

  /// Description message when no visions exist
  ///
  /// In en, this message translates to:
  /// **'Start chatting with a prophet to see your vision statistics here.'**
  String get noConversationsDescription;

  /// Error message when loading vision data fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load vision data: {error}'**
  String failedToLoadConversationData(String error);

  /// Description for personal information settings
  ///
  /// In en, this message translates to:
  /// **'Manage your basic profile information'**
  String get personalInformationDescription;

  /// Description for interests and topics settings
  ///
  /// In en, this message translates to:
  /// **'Select your areas of interest'**
  String get interestsAndTopicsDescription;

  /// Description for personalization preferences
  ///
  /// In en, this message translates to:
  /// **'Customize your guidance preferences'**
  String get personalizeYourExperienceDescription;

  /// Title for AI profile section
  ///
  /// In en, this message translates to:
  /// **'Your AI Profile'**
  String get yourAiProfile;

  /// Description for AI profile section
  ///
  /// In en, this message translates to:
  /// **'View your generated biographical profile and privacy settings'**
  String get yourAiProfileDescription;

  /// Error message when profile loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String failedToLoadProfile(String error);

  /// Error message when profile saving fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile: {error}'**
  String failedToSaveProfile(String error);

  /// Title for user profile page
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// Success message after deleting biographical data
  ///
  /// In en, this message translates to:
  /// **'All biographical data deleted successfully'**
  String get biographicalDataDeletedSuccess;

  /// Error message when data deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete data: {error}'**
  String failedToDeleteData(String error);

  /// Title for delete biographical data dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Biographical Data'**
  String get deleteBiographicalData;

  /// Content for delete biographical data confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your biographical information. This action cannot be undone.\n\nAre you sure you want to continue?'**
  String get deleteBiographicalDataContent;

  /// Button text for deleting all data
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllData;

  /// Error message when loading biographical profile fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load biographical profile: {error}'**
  String failedToLoadBiographicalProfile(String error);

  /// Loading message for profile
  ///
  /// In en, this message translates to:
  /// **'Loading your profile...'**
  String get loadingYourProfile;

  /// Button text for retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Message when no biographical information is available
  ///
  /// In en, this message translates to:
  /// **'No bio still available. The prophets need more information.'**
  String get noBioAvailable;

  /// Button text to navigate to prophets
  ///
  /// In en, this message translates to:
  /// **'Ask the Prophets'**
  String get askTheProphets;

  /// Header title in profile section
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfileHeader;

  /// Subtitle explaining how profile is generated
  ///
  /// In en, this message translates to:
  /// **'Generated from your prophet interactions'**
  String get generatedFromProphetInteractions;

  /// Message when no biographical content is available
  ///
  /// In en, this message translates to:
  /// **'No biographical content available'**
  String get noBiographicalContentAvailable;

  /// Tooltip for delete all data button
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllDataTooltip;

  /// Title for privacy consent dialog
  ///
  /// In en, this message translates to:
  /// **'Data Privacy & Personalization'**
  String get privacyConsentTitle;

  /// Privacy consent dialog message
  ///
  /// In en, this message translates to:
  /// **'To provide you with personalized responses, Orakl can store and analyze your interactions with the prophets.\n\nThis data is used exclusively to improve your experience and will never be shared with external partners.\n\nWould you like to enable personalized responses?'**
  String get privacyConsentMessage;

  /// Button to accept personalization
  ///
  /// In en, this message translates to:
  /// **'Enable Personalization'**
  String get enablePersonalization;

  /// Button to decline personalization
  ///
  /// In en, this message translates to:
  /// **'Disable Personalization'**
  String get disablePersonalization;

  /// Button to review privacy policy
  ///
  /// In en, this message translates to:
  /// **'Review Privacy Policy'**
  String get reviewPrivacyPolicy;

  /// Title for privacy settings option
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// Description for privacy settings option
  ///
  /// In en, this message translates to:
  /// **'Manage your data personalization preferences'**
  String get privacySettingsDescription;

  /// Title for personalization status card
  ///
  /// In en, this message translates to:
  /// **'Personalization Status'**
  String get personalizationStatus;

  /// Status text when feature is enabled
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Status text when feature is disabled
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Section title explaining how personalization works
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorks;

  /// Description when personalization is enabled
  ///
  /// In en, this message translates to:
  /// **'Your interactions with prophets are being analyzed to provide personalized responses.'**
  String get personalizationEnabledDescription;

  /// Description when personalization is disabled
  ///
  /// In en, this message translates to:
  /// **'Personalization is disabled. No data is being collected from your interactions.'**
  String get personalizationDisabledDescription;

  /// Feature description when personalization is enabled
  ///
  /// In en, this message translates to:
  /// **'Insights from your questions and conversations are collected'**
  String get personalizationEnabledFeature1;

  /// Feature description when personalization is enabled
  ///
  /// In en, this message translates to:
  /// **'This data helps prophets give more relevant responses'**
  String get personalizationEnabledFeature2;

  /// Feature description when personalization is enabled
  ///
  /// In en, this message translates to:
  /// **'Your data is never shared with external partners'**
  String get personalizationEnabledFeature3;

  /// Feature description when personalization is disabled
  ///
  /// In en, this message translates to:
  /// **'No personal insights are collected or stored'**
  String get personalizationDisabledFeature1;

  /// Feature description when personalization is disabled
  ///
  /// In en, this message translates to:
  /// **'Prophets provide generic responses'**
  String get personalizationDisabledFeature2;

  /// Feature description when personalization is disabled
  ///
  /// In en, this message translates to:
  /// **'You can enable personalization at any time'**
  String get personalizationDisabledFeature3;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Text shown when updating settings
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// Warning message when disabling personalization
  ///
  /// In en, this message translates to:
  /// **'Warning: Disabling personalization will permanently delete all collected data.'**
  String get disablePersonalizationWarning;

  /// Note when enabling personalization
  ///
  /// In en, this message translates to:
  /// **'Note: Enabling personalization will start collecting data from future interactions.'**
  String get enablePersonalizationNote;

  /// Privacy policy section title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Title for disable personalization confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Disable Personalization'**
  String get confirmDisablePersonalization;

  /// Confirmation message for disabling personalization
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disable personalization? This action will permanently delete all your collected data and cannot be undone.'**
  String get disablePersonalizationConfirmMessage;

  /// Disable button text
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// Success message when personalization is enabled
  ///
  /// In en, this message translates to:
  /// **'Personalization enabled successfully'**
  String get personalizationEnabledSuccess;

  /// Success message when personalization is disabled
  ///
  /// In en, this message translates to:
  /// **'Personalization disabled and data deleted successfully'**
  String get personalizationDisabledSuccess;

  /// Success message when feedback is updated
  ///
  /// In en, this message translates to:
  /// **'Feedback updated!'**
  String get feedbackUpdated;

  /// Error message when feedback update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update feedback: {error}'**
  String failedToUpdateFeedback(String error);

  /// Title for wait time dialog
  ///
  /// In en, this message translates to:
  /// **'Wait Time Active'**
  String get waitTimeActive;

  /// Title for watch ad dialog
  ///
  /// In en, this message translates to:
  /// **'Watch Ad?'**
  String get watchAdTitle;

  /// Message when user is in cooldown period
  ///
  /// In en, this message translates to:
  /// **'You skipped an ad earlier'**
  String get youSkippedAdEarlier;

  /// Message when user has asked one question
  ///
  /// In en, this message translates to:
  /// **'You\'ve asked 1 question!'**
  String get youAskedOneQuestion;

  /// Message when user has asked multiple questions
  ///
  /// In en, this message translates to:
  /// **'You\'ve asked {count} questions!'**
  String youAskedMultipleQuestions(int count);

  /// Message asking user to wait or watch ad
  ///
  /// In en, this message translates to:
  /// **'Please wait {timeString} or watch an ad to continue asking the oracle.'**
  String waitOrWatchAdMessage(String timeString);

  /// Message explaining unlimited access with ad
  ///
  /// In en, this message translates to:
  /// **'To continue receiving unlimited oracle wisdom, watch a quick ad or skip and wait 4 hours.'**
  String get unlimitedOracleWisdomMessage;

  /// Approximate ad duration
  ///
  /// In en, this message translates to:
  /// **'~30 seconds'**
  String get aboutThirtySeconds;

  /// Indicates the app is free
  ///
  /// In en, this message translates to:
  /// **'Free to use'**
  String get freeToUse;

  /// Button to wait instead of watching ad
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get waitButton;

  /// Button to skip ad
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// Button to watch advertisement
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAdButton;

  /// Loading message while preparing ad
  ///
  /// In en, this message translates to:
  /// **'Preparing ad...'**
  String get preparingAd;

  /// Button to retry an action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Label for positive feedback button
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get feedbackGreat;

  /// Label for negative feedback button
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get feedbackPoor;

  /// Label for funny feedback button
  ///
  /// In en, this message translates to:
  /// **'Funny'**
  String get feedbackFunny;

  /// Button to save vision
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveVision;

  /// Button to share vision
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareVision;

  /// Button to close vision dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeVision;

  /// Hint text for message input field
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// Label indicating content is AI generated
  ///
  /// In en, this message translates to:
  /// **'AI Generated'**
  String get aiGenerated;

  /// Time format for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// Time format for hours ago
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// Time format for days ago
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);
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
