import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/ai_service_manager.dart';
import '../services/database_service.dart';
import '../services/onboarding_service.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';
import '../widgets/dialogs/dialog_widgets.dart';
import '../utils/utils.dart';
import '../l10n/app_localizations.dart';
import 'onboarding/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin, LoadingStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _setupComplete = false;
  static const int _minDurationMs = 5000; // 5 seconds minimum
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    // Initialize animation controllers
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Start fade animation
    _fadeController.forward();
    
    // Start the setup process
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await executeWithLoading(() async {
      AppLogger.logInfo('SplashScreen', 'Starting app initialization...');
      
      // Initialize AI service (this handles config and setup)
      final aiInitialized = await AIServiceManager.initialize();
      AppLogger.logInfo('SplashScreen', 'AI initialization result: $aiInitialized');
      
      // Initialize database service with timeout protection
      try {
        AppLogger.logInfo('SplashScreen', 'Starting database initialization...');
        final databaseService = DatabaseService();
        await databaseService.database.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            AppLogger.logWarning('SplashScreen', 'Database initialization timed out after 10 seconds');
            throw Exception('Database initialization timeout');
          },
        );
        AppLogger.logInfo('SplashScreen', '✅ Database initialized successfully');
      } catch (e) {
        AppLogger.logError('SplashScreen', '❌ Failed to initialize database', e);
        AppLogger.logWarning('SplashScreen', '⚠️  App will continue with limited vision storage functionality');
        // Continue anyway - app should still work without storage
      }
      
      setState(() {
        _setupComplete = true;
      });
      
      // Check if minimum time has passed
      final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;
      final remainingTime = _minDurationMs - elapsed;
      
      if (remainingTime > 0) {
        // Wait for remaining time
        await Future.delayed(Duration(milliseconds: remainingTime));
      }
      
      // Check AI status and show appropriate alert (only if debug alerts enabled)
      if (AppConfig.showDebugAlerts) {
        await _checkAndShowAIStatus();
      }
      
      // Check onboarding status and navigate accordingly
      final onboardingService = OnboardingService();
      print('SplashScreen: Checking onboarding completion status...');
      final isOnboardingComplete = await onboardingService.isOnboardingComplete();
      print('SplashScreen: Onboarding complete status: $isOnboardingComplete');
      
      if (mounted) {
        if (isOnboardingComplete) {
          // Navigate to home screen
          print('SplashScreen: Navigating to home screen...');
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Navigate to onboarding
          print('SplashScreen: Navigating to onboarding flow...');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OnboardingFlow(
                onComplete: () {
                  print('SplashScreen: Onboarding completed, navigating to home...');
                  Navigator.of(context).pushReplacementNamed('/home');
                },
              ),
            ),
          );
        }
      }
    });
  }

  Future<void> _checkAndShowAIStatus() async {
    if (!mounted) return;
    
    final isAIAvailable = AIServiceManager.isAIAvailable;
    
    String title;
    String message;
    Color iconColor;
    IconData icon;
    
    // Always show detailed debug info for now
    final debugInfo = AIServiceManager.getDetailedStatus();
    
    if (isAIAvailable) {
      title = '🎯 AI Attiva!';
      message = 'L\'intelligenza artificiale è configurata correttamente. I tuoi oracoli possono fornire risposte personalizzate.\n\n$debugInfo';
      iconColor = Colors.green;
      icon = Icons.check_circle;
    } else {
      title = '⚠️ AI Non Disponibile';
      message = 'Configurazione AI ha problemi:\n\n'
          '• AI Available: $isAIAvailable\n'
          '• Build Config Valid: ${AppConfig.isAIConfigured}\n\n'
          '$debugInfo';
      iconColor = Colors.orange;
      icon = Icons.warning;
    }
    
    await StatusDialog.show(
      context: context,
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          decoration: ThemeUtils.getGradientDecoration(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F0F23), Color(0xFF121212)]
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  
                  // App title
                  const Text(
                    'Profet AI',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                      letterSpacing: 2.0,
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Rotating prophet images
                  SizedBox(
                    width: 240, // Increased from 200
                    height: 240, // Increased from 200
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: _buildProphetCircle(),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: ThemeUtils.spacingXL),
                  
                  // Loading text
                  Text(
                    AppLocalizations.of(context)!.loadingProphetsFromUniverse,
                    style: ThemeUtils.titleStyle.copyWith(
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: ThemeUtils.spacingLG),
                  
                  // Progress indicator
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.deepPurpleAccent,
                      ),
                      value: _setupComplete ? 1.0 : null,
                    ),
                  ),
                  
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProphetCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Central mystical symbol
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Colors.deepPurpleAccent,
                Color(0xFFD4AF37), // Gold
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurpleAccent.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 40,
          ),
        ),
        
        // Prophet icons positioned in a circle
        ..._buildProphetIcons(),
      ],
    );
  }

  List<Widget> _buildProphetIcons() {
    final prophets = [
      {
        'image': 'assets/images/prophets/mystic_prophet.png',
        'color': const Color(0xFFD4AF37), // Gold - Mystic
        'angle': 0.0,
      },
      {
        'image': 'assets/images/prophets/chaotic_prophet.png',
        'color': const Color(0xFFFF6B35), // Orange - Chaotic
        'angle': 2 * math.pi / 4,
      },
      {
        'image': 'assets/images/prophets/cynical_prophet.png',
        'color': const Color(0xFF78909C), // Gray-blue - Cynic
        'angle': 4 * math.pi / 4,
      },
      {
        'image': 'assets/images/prophets/roaster_prophet.png',
        'color': const Color(0xFFFF3D00), // Burning red-orange - Roaster
        'angle': 6 * math.pi / 4,
      },
    ];

    return prophets.map((prophet) {
      try {
        final angle = prophet['angle'] as double;
        final radius = 90.0; // Increased from 75.0
        
        return Transform.translate(
          offset: Offset(
            radius * math.cos(angle),
            radius * math.sin(angle),
          ),
          child: Container(
            width: 80, // Increased from 60
            height: 80, // Increased from 60
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (prophet['color'] as Color).withOpacity(0.2),
              border: Border.all(
                color: (prophet['color'] as Color),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (prophet['color'] as Color).withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: _buildProphetImage(prophet),
            ),
          ),
        );
      } catch (e) {
        AppLogger.logError('SplashScreen', 'Error building prophet icon', e);
        // Return a fallback container in case of any error
        return Container(
          width: 80, // Increased from 60
          height: 80, // Increased from 60
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
          child: const Icon(Icons.help, color: Colors.white),
        );
      }
    }).toList();
  }

  Widget _buildProphetImage(Map<String, dynamic> prophet) {
    try {
      return Image.asset(
        prophet['image'] as String,
        width: 74, // Increased from 54
        height: 74, // Increased from 54
        fit: BoxFit.cover,
        cacheWidth: 148, // Increased from 54 (2x for high DPI)
        cacheHeight: 148, // Increased from 54 (2x for high DPI)
        errorBuilder: (context, error, stackTrace) {
          AppLogger.logWarning('SplashScreen', 'Failed to load image: ${prophet['image']}, error: $error');
          // Fallback to icon if image fails to load
          return Container(
            color: (prophet['color'] as Color).withOpacity(0.5),
            child: Icon(
              _getFallbackIcon(prophet['image'] as String),
              color: Colors.white,
              size: 32, // Increased from 24
            ),
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
      );
    } catch (e) {
      AppLogger.logError('SplashScreen', 'Error creating prophet image widget', e);
      // Ultimate fallback
      return Container(
        color: (prophet['color'] as Color).withOpacity(0.5),
        child: Icon(
          _getFallbackIcon(prophet['image'] as String),
          color: Colors.white,
          size: 32, // Increased from 24
        ),
      );
    }
  }

  IconData _getFallbackIcon(String imagePath) {
    if (imagePath.contains('mystic')) return Icons.visibility;
    if (imagePath.contains('chaotic')) return Icons.shuffle;
    if (imagePath.contains('cinic')) return Icons.sentiment_dissatisfied;
    if (imagePath.contains('roaster')) return Icons.local_fire_department;
    return Icons.help;
  }
}
