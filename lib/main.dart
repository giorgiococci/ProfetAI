import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'models/profet_manager.dart';
import 'screens/home_screen.dart';
import 'screens/profet_selection_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/vision_book_screen.dart';
import 'screens/ai_status_screen.dart';
import 'screens/splash_screen.dart';
import 'services/locale_service.dart';
import 'services/user_profile_service.dart';
import 'utils/app_logger.dart';
import 'config/app_config.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Skip database initialization at startup to avoid blocking the UI
  // Database will be initialized on-demand when needed with timeout protection
  AppLogger.logInfo('Main', 'Skipping database initialization at startup for better web compatibility');
  
  // Don't initialize other services here - let splash screen handle it
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocaleService _localeService = LocaleService();
  Locale _currentLocale = const Locale('it'); // Default locale

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await _localeService.loadSavedLocale();
    
    // Check for user profile language preference
    try {
      final userProfileService = UserProfileService();
      await userProfileService.loadProfile();
      final profile = userProfileService.currentProfile;
      
      if (profile != null && profile.languages.isNotEmpty) {
        final preferredLanguage = profile.languages.first;
        final preferredLocale = Locale(preferredLanguage);
        
        if (LocaleService.supportedLocales.contains(preferredLocale) &&
            _localeService.currentLocale != preferredLocale) {
          await _localeService.setLocale(preferredLocale);
        }
      }
    } catch (e) {
      // Silently handle profile loading errors during app initialization
    }
    
    setState(() {
      _currentLocale = _localeService.currentLocale;
    });
    
    _localeService.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _localeService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        _currentLocale = _localeService.currentLocale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profet AI',
      locale: _currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleService.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1B24),
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1F1B24),
          selectedItemColor: Colors.deepPurpleAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => MyHomePage(localeService: _localeService),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final LocaleService localeService;
  
  const MyHomePage({
    super.key,
    required this.localeService,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  ProfetType _currentProfetType = ProfetType.mistico;
  final UserProfileService _profileService = UserProfileService();
  
  @override
  void initState() {
    super.initState();
    _loadFavoriteProphet();
  }
  
  /// Load the favorite prophet from user profile and set it as default
  Future<void> _loadFavoriteProphet() async {
    try {
      await _profileService.loadProfile();
      final favoriteProphet = _profileService.getFavoriteProphet();
      
      if (favoriteProphet != null) {
        final prophetType = _stringToProfetType(favoriteProphet);
        if (prophetType != null && mounted) {
          setState(() {
            _currentProfetType = prophetType;
          });
        }
      }
    } catch (e) {
      // If there's an error loading favorites, keep the default (mystic)
    }
  }
  
  /// Convert prophet string to ProfetType enum
  ProfetType? _stringToProfetType(String prophetString) {
    switch (prophetString) {
      case 'mystic':
        return ProfetType.mistico;
      case 'chaotic':
        return ProfetType.caotico;
      case 'cynical':
        return ProfetType.cinico;
      default:
        return null;
    }
  }
  
  void _onItemTapped(int index) {
    setState(() {
      // If trying to access AI Status screen (index 4) without debug mode, redirect to Settings
      if (index == 4 && !(kDebugMode || AppConfig.isDebugMode)) {
        _selectedIndex = 3; // Redirect to Settings screen
      } else {
        _selectedIndex = index;
      }
    });
  }

  void _changeProfetType(ProfetType type) {
    setState(() {
      _currentProfetType = type;
      _selectedIndex = 0; // Torna automaticamente alla Home dopo aver cambiato oracolo
    });
  }

  /// Callback to refresh the entire app when language changes
  void _refreshApp() {
    // Force reload the locale from LocaleService to pick up any changes
    widget.localeService.loadSavedLocale().then((_) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild of the entire widget tree with new locale
        });
      }
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(
          selectedProfet: _currentProfetType,
        );
      case 1:
        return ProfetSelectionScreen(
          selectedProfet: _currentProfetType,
          onProfetChange: _changeProfetType,
        );
      case 2:
        return const VisionBookScreen();
      case 3:
        return SettingsScreen(onLanguageChanged: _refreshApp);
      case 4:
        // Only show AI Status screen in debug mode
        return (kDebugMode || AppConfig.isDebugMode) 
            ? const AIStatusScreen()
            : SettingsScreen(onLanguageChanged: _refreshApp); // Fallback to settings
      default:
        return HomeScreen(
          selectedProfet: _currentProfetType,
        );
    }
  }

  List<BottomNavigationBarItem> _getNavigationItems(BuildContext context) {
    final baseItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: AppLocalizations.of(context)!.navigationHome,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: AppLocalizations.of(context)!.navigationOracles,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.menu_book),
        label: AppLocalizations.of(context)!.navigationVisions,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: AppLocalizations.of(context)!.settingsPageTitle,
      ),
    ];

    // Only add AI Status tab in debug mode
    if (kDebugMode || AppConfig.isDebugMode) {
      baseItems.add(
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: AppLocalizations.of(context)!.navigationAIStatus,
        ),
      );
    }

    return baseItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: _getNavigationItems(context),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
