import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_profile.dart';
import 'onboarding_welcome_screen.dart';
import 'onboarding_features_screen.dart';
import 'onboarding_personalization_screen.dart';

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingFlow({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();
  final UserProfileService _userProfileService = UserProfileService();
  
  int _currentPage = 0;
  static const int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    try {
      print('OnboardingFlow: Starting onboarding completion process...');
      await _onboardingService.completeOnboarding();
      
      // Small delay to ensure storage operations are fully completed
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('OnboardingFlow: Onboarding completion successful, calling onComplete callback');
      widget.onComplete();
    } catch (e) {
      print('OnboardingFlow: Error completing onboarding: $e');
      // Show error to user and allow retry
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to save onboarding progress. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _savePersonalization({
    String? name,
    String? favoriteProphet,
    List<String>? lifeFocusAreas,
    String? lifeStage,
  }) async {
    print('OnboardingFlow: Saving personalization data...');
    try {
      await _userProfileService.loadProfile();
      final currentProfile = _userProfileService.currentProfile ?? const UserProfile();
      
      final updatedProfile = currentProfile.copyWith(
        name: name?.isNotEmpty == true ? name : null,
        favoriteProphet: favoriteProphet,
        lifeFocusAreas: lifeFocusAreas ?? [],
        lifeStage: lifeStage,
      );
      
      await _userProfileService.saveProfile(updatedProfile);
      print('OnboardingFlow: ✅ Personalization data saved successfully');
    } catch (e) {
      print('OnboardingFlow: ❌ Error saving personalization data: $e');
      rethrow; // Re-throw so the UI can handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1F1B24),
                  Color(0xFF121212),
                  Color(0xFF0A0A0A),
                ],
              ),
            ),
          ),
          
          // Page view with onboarding screens
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              OnboardingWelcomeScreen(
                onNext: _nextPage,
                onSkip: _skipOnboarding,
              ),
              OnboardingFeaturesScreen(
                onNext: _nextPage,
                onSkip: _skipOnboarding,
              ),
              OnboardingPersonalizationScreen(
                onNext: () async {
                  print('OnboardingFlow: Personalization screen called onNext, completing onboarding...');
                  await _completeOnboarding();
                },
                onSkip: _skipOnboarding,
                onSave: _savePersonalization,
              ),
            ],
          ),
          
          // Progress indicator
          Positioned(
            bottom: 30, // Moved higher from the bottom
            left: 0,
            right: 0,
            child: _buildProgressIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _totalPages,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.deepPurpleAccent
                : Colors.grey.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
