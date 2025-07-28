import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLanguageChanged;
  
  const ProfileScreen({
    super.key,
    this.onLanguageChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final UserProfileService _profileService = UserProfileService();

  UserProfile _currentProfile = const UserProfile();
  Country? _selectedCountry;
  Gender? _selectedGender;
  AppLanguage? _selectedLanguage; // Changed from List to single selection
  List<Interest> _selectedInterests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      await _profileService.loadProfile();
      if (_profileService.currentProfile != null) {
        _currentProfile = _profileService.currentProfile!;
        _nameController.text = _currentProfile.name ?? '';
        
        // Find selected country
        if (_currentProfile.country != null) {
          _selectedCountry = UserProfileService.getCountries()
              .where((c) => c.code == _currentProfile.country)
              .firstOrNull;
        }
        
        _selectedGender = _currentProfile.gender;
        
        // Find selected language (single selection)
        if (_currentProfile.languages.isNotEmpty) {
          _selectedLanguage = UserProfileService.getAppLanguages()
              .where((lang) => lang.code == _currentProfile.languages.first)
              .firstOrNull;
        }
            
        // Find selected interests
        _selectedInterests = UserProfileService.getInterests()
            .where((interest) => _currentProfile.interests.contains(interest.key))
            .toList();
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
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final updatedProfile = UserProfile(
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        country: _selectedCountry?.code,
        gender: _selectedGender,
        languages: _selectedLanguage != null ? [_selectedLanguage!.code] : [],
        interests: _selectedInterests.map((interest) => interest.key).toList(),
      );

      await _profileService.saveProfile(updatedProfile);
      
      // Check if language changed and trigger immediate refresh
      bool languageChanged = _selectedLanguage != null && 
          (_currentProfile.languages.isEmpty || 
           _currentProfile.languages.first != _selectedLanguage!.code);
      
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
        
        // Show language change notification if language was changed
        if (languageChanged && _selectedLanguage != null) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
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
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profilePageTitle),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Personal Information Section
            _buildSectionCard(
              title: localizations.personalInformation,
              children: [
                _buildNameField(localizations),
                const SizedBox(height: 16),
                _buildCountryField(localizations),
                const SizedBox(height: 16),
                _buildGenderField(localizations),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Preferences & Languages Section
            _buildSectionCard(
              title: localizations.preferencesAndLanguages,
              children: [
                _buildLanguagesField(localizations),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Interests & Topics Section
            _buildSectionCard(
              title: localizations.interestsAndTopics,
              children: [
                _buildInterestsField(localizations),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                localizations.saveProfile,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      color: const Color(0xFF1F1B24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(AppLocalizations localizations) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: localizations.nameLabel,
        hintText: localizations.nameHint,
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2D3A),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildCountryField(AppLocalizations localizations) {
    return DropdownButtonFormField<Country>(
      value: _selectedCountry,
      decoration: InputDecoration(
        labelText: localizations.countryLabel,
        hintText: localizations.countryHint,
        prefixIcon: const Icon(Icons.public),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2D3A),
      ),
      dropdownColor: const Color(0xFF2A2D3A),
      style: const TextStyle(color: Colors.white),
      items: UserProfileService.getCountries().map((country) {
        return DropdownMenuItem<Country>(
          value: country,
          child: Text(country.name),
        );
      }).toList(),
      onChanged: (Country? value) {
        setState(() {
          _selectedCountry = value;
        });
      },
    );
  }

  Widget _buildGenderField(AppLocalizations localizations) {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: localizations.genderLabel,
        hintText: localizations.genderHint,
        prefixIcon: const Icon(Icons.people),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2D3A),
      ),
      dropdownColor: const Color(0xFF2A2D3A),
      style: const TextStyle(color: Colors.white),
      items: Gender.values.map((gender) {
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(_getGenderDisplayName(gender, localizations)),
        );
      }).toList(),
      onChanged: (Gender? value) {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  Widget _buildLanguagesField(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.language, color: Colors.deepPurpleAccent),
            const SizedBox(width: 8),
            Text(
              localizations.languagesLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: UserProfileService.getAppLanguages().map((language) {
            return RadioListTile<AppLanguage>(
              title: Text(
                _getLanguageDisplayName(language, localizations),
                style: const TextStyle(color: Colors.white),
              ),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (AppLanguage? value) {
                setState(() {
                  _selectedLanguage = value;
                });
              },
              activeColor: Colors.deepPurpleAccent,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsField(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.interests, color: Colors.deepPurpleAccent),
            const SizedBox(width: 8),
            Text(
              localizations.interestsLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: UserProfileService.getInterests().map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return FilterChip(
              label: Text(_getInterestDisplayName(interest, localizations)),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedInterests.add(interest);
                  } else {
                    _selectedInterests.remove(interest);
                  }
                });
              },
              selectedColor: Colors.deepPurpleAccent.withValues(alpha: 0.3),
              backgroundColor: const Color(0xFF2A2D3A),
              labelStyle: TextStyle(
                color: isSelected ? Colors.deepPurpleAccent : Colors.white,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getGenderDisplayName(Gender gender, AppLocalizations localizations) {
    switch (gender) {
      case Gender.male:
        return localizations.genderMale;
      case Gender.female:
        return localizations.genderFemale;
      case Gender.nonBinary:
        return localizations.genderNonBinary;
      case Gender.preferNotToSay:
        return localizations.genderPreferNotToSay;
    }
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

  String _getInterestDisplayName(Interest interest, AppLocalizations localizations) {
    switch (interest.key) {
      case 'spirituality':
        return localizations.interestSpirituality;
      case 'meditation':
        return localizations.interestMeditation;
      case 'philosophy':
        return localizations.interestPhilosophy;
      case 'mysticism':
        return localizations.interestMysticism;
      case 'divination':
        return localizations.interestDivination;
      case 'wisdom':
        return localizations.interestWisdom;
      case 'dreams':
        return localizations.interestDreams;
      case 'tarot':
        return localizations.interestTarot;
      case 'astrology':
        return localizations.interestAstrology;
      case 'numerology':
        return localizations.interestNumerology;
      default:
        return interest.key;
    }
  }
}
