import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/secure_config_service.dart';
import '../models/profet.dart';
import '../build_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
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
    try {
      // Initialize secure configuration (migration from .env if needed)
      await SecureConfigService.initialize();
      
      // CRITICAL: Load AI credentials from storage into the AzureOpenAI service
      // This is needed because SecureConfigService only manages storage,
      // but the Profet class needs to load them into its AI service
      await Profet.loadStoredAICredentials();
      
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
      
      // Check AI status and show appropriate alert
      await _checkAndShowAIStatus();
      
      // Navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      // Show error dialog if initialization fails
      if (mounted) {
        _showErrorDialog('Initialization Error', 'Failed to initialize app: $e');
      }
    }
  }

  Future<void> _checkAndShowAIStatus() async {
    if (!mounted) return;
    
    final isAIConfigured = SecureConfigService.isAIEnabled;
    final isProfetAIEnabled = Profet.isAIEnabled;
    final hasBuildConfig = BuildConfig.isConfigured;
    
    String title;
    String message;
    Color iconColor;
    IconData icon;
    
    // Always show detailed debug info for now
    final debugLog = SecureConfigService.initializationLog;
    final lastError = SecureConfigService.lastError;
    
    String debugInfo = 'Debug Log:\n';
    for (int i = math.max(0, debugLog.length - 10); i < debugLog.length; i++) {
      debugInfo += '${debugLog[i]}\n';
    }
    if (lastError.isNotEmpty) {
      debugInfo += '\nLast Error: $lastError';
    }
    
    if (isAIConfigured && isProfetAIEnabled) {
      title = '🎯 AI Attiva!';
      message = 'L\'intelligenza artificiale è configurata correttamente. I tuoi oracoli possono fornire risposte personalizzate.\n\n$debugInfo';
      iconColor = Colors.green;
      icon = Icons.check_circle;
    } else {
      title = '⚠️ AI Non Disponibile';
      message = 'Configurazione AI ha problemi:\n\n'
          '• SecureConfigService.isAIEnabled: $isAIConfigured\n'
          '• Profet.isAIEnabled: $isProfetAIEnabled\n'
          '• BuildConfig.isConfigured: $hasBuildConfig\n\n'
          '$debugInfo';
      iconColor = Colors.orange;
      icon = Icons.warning;
    }
    
    await _showStatusDialog(title, message, icon, iconColor);
  }

  Future<void> _showStatusDialog(String title, String message, IconData icon, Color iconColor) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D30),
          title: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'monospace'),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepPurpleAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D30),
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepPurpleAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A2E), // Dark blue mystic
                Color(0xFF16213E), // Darker blue
                Color(0xFF0F0F23), // Almost black with blue hint
                Color(0xFF121212), // App background
              ],
            ),
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
                    width: 200,
                    height: 200,
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
                  
                  const SizedBox(height: 60),
                  
                  // Loading text
                  const Text(
                    'Loading prophets from the universe',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 30),
                  
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
        'angle': 2 * math.pi / 3,
      },
      {
        'image': 'assets/images/prophets/cinic_prophet.png',
        'color': const Color(0xFF78909C), // Gray-blue - Cynic
        'angle': 4 * math.pi / 3,
      },
    ];

    return prophets.map((prophet) {
      final angle = prophet['angle'] as double;
      final radius = 75.0;
      
      return Transform.translate(
        offset: Offset(
          radius * math.cos(angle),
          radius * math.sin(angle),
        ),
        child: Container(
          width: 60,
          height: 60,
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
            child: Image.asset(
              prophet['image'] as String,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to icon if image fails to load
                return Container(
                  color: (prophet['color'] as Color).withOpacity(0.5),
                  child: Icon(
                    _getFallbackIcon(prophet['image'] as String),
                    color: Colors.white,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ),
      );
    }).toList();
  }

  IconData _getFallbackIcon(String imagePath) {
    if (imagePath.contains('mystic')) return Icons.visibility;
    if (imagePath.contains('chaotic')) return Icons.shuffle;
    if (imagePath.contains('cinic')) return Icons.sentiment_dissatisfied;
    return Icons.help;
  }
}
