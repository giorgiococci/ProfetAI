// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Orakl';

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
  String get listenToOracle => 'LET THE ORACLE SPEAK';

  @override
  String enterQuestionPlaceholder(String oracleName) {
    return 'Ask your question to $oracleName...';
  }

  @override
  String get enterQuestionFirst => '📝 Enter a question before asking!';

  @override
  String get markAsFavoriteOracle => 'Mark as favorite oracle';

  @override
  String get removeFromFavoriteOracle => 'Remove from favorite oracles';

  @override
  String favoriteOracleSet(String oracleName) {
    return '✨ $oracleName is now your favorite oracle!';
  }

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
  String get languagesHint => 'Select your preferred language';

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

  @override
  String languageUpdated(String language) {
    return 'App language updated to $language';
  }

  @override
  String get criticalActions => 'Critical Actions';

  @override
  String get deleteAllVisions => 'Delete All Visions';

  @override
  String get deleteAllVisionsWarning =>
      '⚠️ This action will permanently delete all your stored visions and cannot be undone. Are you sure you want to continue?';

  @override
  String get deleteAllVisionsConfirmTitle => 'Delete All Visions?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get allVisionsDeleted => 'All visions have been deleted successfully';

  @override
  String get failedToDeleteVisions =>
      'Failed to delete visions. Please try again.';

  @override
  String get visionBookTitle => 'Vision Book';

  @override
  String get searchVisions => 'Search visions';

  @override
  String get refreshVisions => 'Refresh';

  @override
  String visionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visions',
      one: '1 vision',
      zero: 'No visions',
    );
    return '$_temp0';
  }

  @override
  String visionsFiltered(int count, int total) {
    return '$count of $total visions';
  }

  @override
  String get filtered => 'Filtered';

  @override
  String get deleteVision => 'Delete Vision';

  @override
  String deleteVisionConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get errorLoadingVisions => 'Error loading visions';

  @override
  String get visionDeletedSuccessfully => 'Vision deleted successfully';

  @override
  String get errorDeletingVision => 'Error deleting vision';

  @override
  String get feedbackUpdatedSuccessfully => 'Feedback updated successfully';

  @override
  String get errorUpdatingFeedback => 'Error updating feedback';

  @override
  String get noVisionsMatchFilters => 'No visions match your filters';

  @override
  String get noVisionsStoredYet => 'No visions stored yet';

  @override
  String get tryAdjustingFilters =>
      'Try adjusting your search criteria or clear filters to see all visions.';

  @override
  String get startMysticalJourney =>
      'Start your mystical journey by asking the oracles for guidance.';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get allOracles => 'All Oracles';

  @override
  String oraclesSelected(int count) {
    return '$count Selected';
  }

  @override
  String get newestFirst => 'Newest First';

  @override
  String get oldestFirst => 'Oldest First';

  @override
  String get titleAZ => 'Title A-Z';

  @override
  String get titleZA => 'Title Z-A';

  @override
  String get byOracle => 'By Oracle';

  @override
  String sortFilter(String sortType) {
    return 'Sort: $sortType';
  }

  @override
  String get clear => 'Clear';

  @override
  String timeAgo(String time) {
    return '$time ago';
  }

  @override
  String daysShort(int count) {
    return '${count}d';
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
  String get justNow => 'Just now';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get userProfileSettings => 'User Profile';

  @override
  String get userProfileSettingsDescription =>
      'Manage your personal information';

  @override
  String get localizationSettings => 'Localization';

  @override
  String get localizationSettingsDescription =>
      'Change app language and region';

  @override
  String get deleteDataSettings => 'Delete Data';

  @override
  String get deleteDataSettingsDescription => 'Manage stored data and visions';

  @override
  String get userProfilePageTitle => 'User Profile';

  @override
  String get localizationPageTitle => 'Localization';

  @override
  String get deleteDataPageTitle => 'Delete Data';

  @override
  String get skip => 'Skip';

  @override
  String get welcomeToOrakl => 'Welcome to Orakl';

  @override
  String get discoverMysticalInsights =>
      'Discover mystical insights through unique oracles';

  @override
  String get beginJourney => 'Begin Journey';

  @override
  String get unlockMysticalPowers => 'Unlock Mystical Powers';

  @override
  String get personalizedPredictions => 'Personalized Predictions';

  @override
  String get personalizedPredictionsDesc =>
      'Ask questions and receive tailored insights from your chosen oracle';

  @override
  String get randomVisions => 'Random Visions';

  @override
  String get randomVisionsDesc =>
      'Get spontaneous wisdom when you need guidance most';

  @override
  String get visionBook => 'Vision Book';

  @override
  String get visionBookDesc =>
      'Save and revisit your favorite predictions and insights';

  @override
  String get uniqueThemes => 'Unique Themes';

  @override
  String get uniqueThemesDesc =>
      'Each oracle has its own mystical visual identity';

  @override
  String get continueButton => 'Continue';

  @override
  String get personalizeYourExperience => 'Personalize Your Experience';

  @override
  String get personalizeOptional =>
      'Optional - You can always change this later';

  @override
  String get whatShouldOraclesCallYou => 'What should the oracles call you?';

  @override
  String get enterYourNameOptional => 'Enter your name (optional)';

  @override
  String get doYouHavePreferredOracle => 'Do you have a preferred oracle?';

  @override
  String get enterTheMysticalRealm => 'Enter the Mystical Realm';

  @override
  String get lifeFocusAreasLabel =>
      'What areas of life are you seeking guidance on?';

  @override
  String get lifeFocusAreasHint => 'Select up to 3 areas (optional)';

  @override
  String get lifeStageLabel => 'What best describes your current life phase?';

  @override
  String get lifeStageHint => 'Select your current phase (optional)';

  @override
  String get lifeFocusLoveRelationships => 'Love & Relationships';

  @override
  String get lifeFocusCareerPurpose => 'Career & Purpose';

  @override
  String get lifeFocusFamilyHome => 'Family & Home';

  @override
  String get lifeFocusHealthWellness => 'Health & Wellness';

  @override
  String get lifeFocusMoneyAbundance => 'Money & Abundance';

  @override
  String get lifeFocusSpiritualGrowth => 'Spiritual Growth';

  @override
  String get lifeFocusPersonalDevelopment => 'Personal Development';

  @override
  String get lifeFocusCreativityPassion => 'Creativity & Passion';

  @override
  String get lifeStageStartingNewChapter => 'Starting a new chapter';

  @override
  String get lifeStageSeekingDirection => 'Seeking direction';

  @override
  String get lifeStageFacingChallenges => 'Facing challenges';

  @override
  String get lifeStagePeriodOfGrowth => 'In a period of growth';

  @override
  String get lifeStageLookingForStability => 'Looking for stability';

  @override
  String get lifeStageEmbracingChange => 'Embracing change';

  @override
  String get visionManagement => 'Vision Management';

  @override
  String get visionManagementDescription =>
      'Manage your conversation history and preferences';

  @override
  String get debugTools => 'Debug Tools';

  @override
  String get admobDebugTest => 'AdMob Debug & Test';

  @override
  String get admobDebugTestDescription => 'Test ad functionality and callbacks';

  @override
  String get resetOnboarding => 'Reset Onboarding';

  @override
  String get resetOnboardingDescription =>
      'Force onboarding to show again on app restart';

  @override
  String get resetOnboardingTitle => 'Reset Onboarding';

  @override
  String get resetOnboardingContent =>
      'This will reset the onboarding status. The onboarding flow will be shown again when you restart the app.\n\nAre you sure?';

  @override
  String get reset => 'Reset';

  @override
  String get onboardingResetSuccess =>
      'Onboarding reset successfully. Restart the app to see the onboarding flow.';

  @override
  String onboardingResetFailed(String error) {
    return 'Failed to reset onboarding: $error';
  }

  @override
  String get conversationStatistics => 'Visions Statistics';

  @override
  String get totalConversations => 'Total Visions';

  @override
  String get totalMessages => 'Total Messages';

  @override
  String get averageMessagesPerConversation => 'Average Messages per Vision';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get clearAllConversations => 'Clear All Visions';

  @override
  String get clearAllConversationsTitle => 'Clear All Visions';

  @override
  String get clearAllConversationsContent =>
      '⚠️ This action will permanently delete ALL your vision history and cannot be undone.\n\nAre you sure you want to continue?';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get deletingAllConversations => 'Deleting all visions...';

  @override
  String get conversationsDeletedSuccess => 'All visions deleted successfully';

  @override
  String conversationsDeleteFailed(String error) {
    return 'Failed to delete visions: $error';
  }

  @override
  String get noConversationsYet => 'No visions yet';

  @override
  String get noConversationsDescription =>
      'Start chatting with a prophet to see your vision statistics here.';

  @override
  String failedToLoadConversationData(String error) {
    return 'Failed to load vision data: $error';
  }

  @override
  String get personalInformationDescription =>
      'Manage your basic profile information';

  @override
  String get interestsAndTopicsDescription => 'Select your areas of interest';

  @override
  String get personalizeYourExperienceDescription =>
      'Customize your guidance preferences';

  @override
  String get yourAiProfile => 'Your AI Profile';

  @override
  String get yourAiProfileDescription =>
      'View your generated biographical profile and privacy settings';

  @override
  String failedToLoadProfile(String error) {
    return 'Failed to load profile: $error';
  }

  @override
  String failedToSaveProfile(String error) {
    return 'Failed to save profile: $error';
  }

  @override
  String get yourProfile => 'Your Profile';

  @override
  String get biographicalDataDeletedSuccess =>
      'All biographical data deleted successfully';

  @override
  String failedToDeleteData(String error) {
    return 'Failed to delete data: $error';
  }

  @override
  String get deleteBiographicalData => 'Delete Biographical Data';

  @override
  String get deleteBiographicalDataContent =>
      'This will permanently delete all your biographical information. This action cannot be undone.\n\nAre you sure you want to continue?';

  @override
  String get deleteAllData => 'Delete All Data';

  @override
  String failedToLoadBiographicalProfile(String error) {
    return 'Failed to load biographical profile: $error';
  }

  @override
  String get loadingYourProfile => 'Loading your profile...';

  @override
  String get retry => 'Retry';

  @override
  String get noBioAvailable =>
      'No bio still available. The prophets need more information.';

  @override
  String get askTheProphets => 'Ask the Prophets';

  @override
  String get yourProfileHeader => 'Your Profile';

  @override
  String get generatedFromProphetInteractions =>
      'Generated from your prophet interactions';

  @override
  String get noBiographicalContentAvailable =>
      'No biographical content available';

  @override
  String get deleteAllDataTooltip => 'Delete All Data';

  @override
  String get privacyConsentTitle => 'Data Privacy & Personalization';

  @override
  String get privacyConsentMessage =>
      'To provide you with personalized responses, Orakl can store and analyze your interactions with the prophets.\n\nThis data is used exclusively to improve your experience and will never be shared with external partners.\n\nWould you like to enable personalized responses?';

  @override
  String get enablePersonalization => 'Enable Personalization';

  @override
  String get disablePersonalization => 'Disable Personalization';

  @override
  String get reviewPrivacyPolicy => 'Review Privacy Policy';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get privacySettingsDescription =>
      'Manage your data personalization preferences';

  @override
  String get personalizationStatus => 'Personalization Status';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get howItWorks => 'How It Works';

  @override
  String get personalizationEnabledDescription =>
      'Your interactions with prophets are being analyzed to provide personalized responses.';

  @override
  String get personalizationDisabledDescription =>
      'Personalization is disabled. No data is being collected from your interactions.';

  @override
  String get personalizationEnabledFeature1 =>
      'Insights from your questions and conversations are collected';

  @override
  String get personalizationEnabledFeature2 =>
      'This data helps prophets give more relevant responses';

  @override
  String get personalizationEnabledFeature3 =>
      'Your data is never shared with external partners';

  @override
  String get personalizationDisabledFeature1 =>
      'No personal insights are collected or stored';

  @override
  String get personalizationDisabledFeature2 =>
      'Prophets provide generic responses';

  @override
  String get personalizationDisabledFeature3 =>
      'You can enable personalization at any time';

  @override
  String get settings => 'Settings';

  @override
  String get updating => 'Updating...';

  @override
  String get disablePersonalizationWarning =>
      'Warning: Disabling personalization will permanently delete all collected data.';

  @override
  String get enablePersonalizationNote =>
      'Note: Enabling personalization will start collecting data from future interactions.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get confirmDisablePersonalization => 'Confirm Disable Personalization';

  @override
  String get disablePersonalizationConfirmMessage =>
      'Are you sure you want to disable personalization? This action will permanently delete all your collected data and cannot be undone.';

  @override
  String get disable => 'Disable';

  @override
  String get personalizationEnabledSuccess =>
      'Personalization enabled successfully';

  @override
  String get personalizationDisabledSuccess =>
      'Personalization disabled and data deleted successfully';

  @override
  String get feedbackUpdated => 'Feedback updated!';

  @override
  String failedToUpdateFeedback(String error) {
    return 'Failed to update feedback: $error';
  }

  @override
  String get waitTimeActive => 'Wait Time Active';

  @override
  String get watchAdTitle => 'Watch Ad?';

  @override
  String get youSkippedAdEarlier => 'You skipped an ad earlier';

  @override
  String get youAskedOneQuestion => 'You\'ve asked 1 question!';

  @override
  String youAskedMultipleQuestions(int count) {
    return 'You\'ve asked $count questions!';
  }

  @override
  String waitOrWatchAdMessage(String timeString) {
    return 'Please wait $timeString or watch an ad to continue asking the oracle.';
  }

  @override
  String get unlimitedOracleWisdomMessage =>
      'To continue receiving unlimited oracle wisdom, watch a quick ad or skip and wait 4 hours.';

  @override
  String get aboutThirtySeconds => '~30 seconds';

  @override
  String get freeToUse => 'Free to use';

  @override
  String get waitButton => 'Wait';

  @override
  String get skipButton => 'Skip';

  @override
  String get watchAdButton => 'Watch Ad';

  @override
  String get preparingAd => 'Preparing ad...';

  @override
  String get retryButton => 'Retry';

  @override
  String get feedbackGreat => 'Great';

  @override
  String get feedbackPoor => 'Poor';

  @override
  String get feedbackFunny => 'Funny';

  @override
  String get saveVision => 'Save';

  @override
  String get shareVision => 'Share';

  @override
  String get closeVision => 'Close';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get aiGenerated => 'AI Generated';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }
}
