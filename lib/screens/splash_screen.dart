import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/ai_config_service.dart';

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
    // Wait for AI configuration to complete
    await AIConfigService.initialize();
    
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
    
    // Navigate to home screen
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
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
        'icon': Icons.visibility,
        'color': const Color(0xFFD4AF37), // Gold - Mystic
        'angle': 0.0,
      },
      {
        'icon': Icons.shuffle,
        'color': const Color(0xFFFF6B35), // Orange - Chaotic
        'angle': 2 * math.pi / 3,
      },
      {
        'icon': Icons.sentiment_dissatisfied,
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (prophet['color'] as Color).withOpacity(0.9),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (prophet['color'] as Color).withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            prophet['icon'] as IconData,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }).toList();
  }
}
