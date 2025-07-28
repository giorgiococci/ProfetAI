import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'models/profet_manager.dart';
import 'screens/home_screen.dart';
import 'screens/profet_selection_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/vision_book_screen.dart';
import 'screens/ai_status_screen.dart';
import 'screens/splash_screen.dart';
import 'services/locale_service.dart';
import 'services/user_profile_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Don't initialize services here - let splash screen handle it
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
        print('DEBUG: Locale changed to: ${_currentLocale.languageCode}'); // Debug print
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
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
        return ProfileScreen(onLanguageChanged: _refreshApp);
      case 3:
        return const VisionBookScreen();
      case 4:
        return const AIStatusScreen();
      default:
        return HomeScreen(
          selectedProfet: _currentProfetType,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context)!.navigationHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: AppLocalizations.of(context)!.navigationOracles,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppLocalizations.of(context)!.navigationProfile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: AppLocalizations.of(context)!.navigationVisions,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: AppLocalizations.of(context)!.navigationAIStatus,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
