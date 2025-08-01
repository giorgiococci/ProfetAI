import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../services/user_profile_service.dart';
import '../../utils/utils.dart';

class LocalizationSettingsScreen extends StatefulWidget {
  final VoidCallback? onLanguageChanged;
  
  const LocalizationSettingsScreen({
    super.key,
    this.onLanguageChanged,
  });

  @override
  State<LocalizationSettingsScreen> createState() => _LocalizationSettingsScreenState();
}

class _LocalizationSettingsScreenState extends State<LocalizationSettingsScreen> 
    with LoadingStateMixin {
  final UserProfileService _profileService = UserProfileService();

  UserProfile _currentProfile = const UserProfile();
  AppLanguage? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      await _profileService.loadProfile();
      if (_profileService.currentProfile != null) {
        _currentProfile = _profileService.currentProfile!;
        
        // Find selected language (single selection)
        if (_currentProfile.languages.isNotEmpty) {
          _selectedLanguage = UserProfileService.getAppLanguages()
              .where((lang) => lang.code == _currentProfile.languages.first)
              .firstOrNull;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          // Loading handled by LoadingStateMixin
        });
      }
    }
  }

  Future<void> _saveLanguage() async {
    try {
      final updatedProfile = UserProfile(
        name: _currentProfile.name,
        country: _currentProfile.country,
        gender: _currentProfile.gender,
        languages: _selectedLanguage != null ? [_selectedLanguage!.code] : [],
        interests: _currentProfile.interests,
      );

      await _profileService.saveProfile(updatedProfile);
      
      // Check if language actually changed from the previous profile
      String? previousLanguage = _currentProfile.languages.isNotEmpty ? _currentProfile.languages.first : null;
      String? newLanguage = _selectedLanguage?.code;
      bool languageChanged = previousLanguage != newLanguage;
      
      if (languageChanged) {
        // Trigger immediate app refresh BEFORE showing messages
        _triggerAppRefresh();
        
        // Small delay to allow the rebuild to complete
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileSaved),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        
        // Show language change notification ONLY if language actually changed
        if (languageChanged && newLanguage != null) {
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.languageUpdated(
                      _getLanguageDisplayName(_selectedLanguage!, AppLocalizations.of(context)!)
                    ),
                  ),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          });
        }
        
        // Go back to settings screen after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving language: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Triggers a complete app refresh to apply language changes
  void _triggerAppRefresh() {
    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.localizationPageTitle),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Languages Section
          _buildSectionCard(
            title: localizations.preferencesAndLanguages,
            children: [
              _buildLanguagesField(localizations),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Save Button
          _buildSaveButton(localizations),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ThemeUtils.mysticPurple.withValues(alpha: 0.1),
              ThemeUtils.mysticPurple.withValues(alpha: 0.05),
            ],
          ),
        ),
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
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveLanguage,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeUtils.mysticPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          localizations.saveProfile,
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguagesField(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.language, color: ThemeUtils.mysticPurple),
            const SizedBox(width: 8),
            Text(
              localizations.languagesLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: UserProfileService.getAppLanguages().map((language) {
            final isSelected = _selectedLanguage == language;
            return FilterChip(
              label: Text(_getLanguageDisplayName(language, localizations)),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    // Single selection: set this language as the only selected one
                    _selectedLanguage = language;
                  } else {
                    // If deselecting, clear selection
                    _selectedLanguage = null;
                  }
                });
              },
              selectedColor: ThemeUtils.mysticPurple.withValues(alpha: 0.3),
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              side: BorderSide(
                color: isSelected ? ThemeUtils.mysticPurple : Colors.white24,
                width: 1,
              ),
              labelStyle: TextStyle(
                color: isSelected ? ThemeUtils.mysticPurple : Colors.white70,
                fontSize: 13,
              ),
              showCheckmark: true,
              checkmarkColor: ThemeUtils.mysticPurple,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getLanguageDisplayName(AppLanguage language, AppLocalizations localizations) {
    switch (language.code) {
      case 'en':
        return localizations.languageEnglish;
      case 'it':
        return localizations.languageItalian;
      default:
        return language.name;
    }
  }
}
