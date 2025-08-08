import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class OnboardingFeaturesScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingFeaturesScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Skip button
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                l10n.skip,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            l10n.unlockMysticalPowers,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Features list
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeature(
                  icon: Icons.psychology,
                  title: l10n.personalizedPredictions,
                  description: l10n.personalizedPredictionsDesc,
                  color: Colors.deepPurpleAccent,
                ),
                
                const SizedBox(height: 30),
                
                _buildFeature(
                  icon: Icons.auto_awesome,
                  title: l10n.randomVisions,
                  description: l10n.randomVisionsDesc,
                  color: Colors.orangeAccent,
                ),
                
                const SizedBox(height: 30),
                
                _buildFeature(
                  icon: Icons.book,
                  title: l10n.visionBook,
                  description: l10n.visionBookDesc,
                  color: Colors.redAccent,
                ),
                
                const SizedBox(height: 30),
                
                _buildFeature(
                  icon: Icons.palette,
                  title: l10n.uniqueThemes,
                  description: l10n.uniqueThemesDesc,
                  color: Colors.tealAccent,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 60), // Increased spacing before button
          
          // Continue button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 8,
                shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.continueButton,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20), // Reduced bottom spacing
        ],
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        // Icon container
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 28,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
