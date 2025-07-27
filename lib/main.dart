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

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Don't initialize AI here anymore - let splash screen handle it
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profet AI',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('it', ''), // Italian
      ],
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
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
        return const ProfileScreen();
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
