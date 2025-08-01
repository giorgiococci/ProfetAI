import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme_utils.dart';
import 'settings/user_profile_settings_screen.dart';
import 'settings/localization_settings_screen.dart';
import 'settings/delete_data_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onLanguageChanged;
  
  const SettingsScreen({
    super.key,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsPageTitle),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsCard(
            context: context,
            title: localizations.userProfileSettings,
            subtitle: localizations.userProfileSettingsDescription,
            icon: Icons.person,
            onTap: () => _navigateToUserProfile(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsCard(
            context: context,
            title: localizations.localizationSettings,
            subtitle: localizations.localizationSettingsDescription,
            icon: Icons.language,
            onTap: () => _navigateToLocalization(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsCard(
            context: context,
            title: localizations.deleteDataSettings,
            subtitle: localizations.deleteDataSettingsDescription,
            icon: Icons.delete_forever,
            iconColor: Colors.redAccent,
            onTap: () => _navigateToDeleteData(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final accentColor = iconColor ?? ThemeUtils.mysticPurple;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.1),
                accentColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white54,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserProfileSettingsScreen(),
      ),
    );
  }

  void _navigateToLocalization(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocalizationSettingsScreen(
          onLanguageChanged: onLanguageChanged,
        ),
      ),
    );
  }

  void _navigateToDeleteData(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DeleteDataSettingsScreen(),
      ),
    );
  }
}
