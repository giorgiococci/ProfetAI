import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'user_profile/personal_information_screen.dart';
import 'user_profile/interests_and_topics_screen.dart';
import 'user_profile/personalization_preferences_screen.dart';
import 'bio_profile_screen.dart';

class UserProfileSettingsScreen extends StatelessWidget {
  const UserProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.userProfilePageTitle),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNavigationCard(
            context: context,
            title: localizations.personalInformation,
            subtitle: 'Manage your basic profile information',
            icon: Icons.person,
            onTap: () => _navigateToPersonalInformation(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildNavigationCard(
            context: context,
            title: localizations.interestsAndTopics,
            subtitle: 'Select your areas of interest',
            icon: Icons.interests,
            onTap: () => _navigateToInterests(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildNavigationCard(
            context: context,
            title: localizations.personalizeYourExperience,
            subtitle: 'Customize your guidance preferences',
            icon: Icons.tune,
            onTap: () => _navigateToPersonalization(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildNavigationCard(
            context: context,
            title: 'Your AI Profile',
            subtitle: 'View your generated biographical profile and privacy settings',
            icon: Icons.psychology,
            iconColor: Colors.blueAccent,
            onTap: () => _navigateToBioProfile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).primaryColor,
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _navigateToPersonalInformation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonalInformationScreen(),
      ),
    );
  }

  void _navigateToInterests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InterestsAndTopicsScreen(),
      ),
    );
  }

  void _navigateToPersonalization(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonalizationPreferencesScreen(),
      ),
    );
  }

  void _navigateToBioProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BioProfileScreen(),
      ),
    );
  }
}
