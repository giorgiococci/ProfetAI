import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../services/user_profile_service.dart';
import '../../utils/utils.dart';

class UserProfileSettingsScreen extends StatefulWidget {
  const UserProfileSettingsScreen({super.key});

  @override
  State<UserProfileSettingsScreen> createState() => _UserProfileSettingsScreenState();
}

class _UserProfileSettingsScreenState extends State<UserProfileSettingsScreen> 
    with FormStateMixin, LoadingStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final UserProfileService _profileService = UserProfileService();

  UserProfile _currentProfile = const UserProfile();
  Country? _selectedCountry;
  Gender? _selectedGender;
  List<Interest> _selectedInterests = [];

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
          // Loading handled by LoadingStateMixin
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
        languages: _currentProfile.languages, // Keep existing language settings
        interests: _selectedInterests.map((interest) => interest.key).toList(),
      );

      await _profileService.saveProfile(updatedProfile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileSaved),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Go back to settings screen
        Navigator.of(context).pop();
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
        title: Text(localizations.userProfilePageTitle),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
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
            
            const SizedBox(height: 12),
            
            // Interests & Topics Section
            _buildSectionCard(
              title: localizations.interestsAndTopics,
              children: [
                _buildInterestsField(localizations),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            _buildSaveButton(localizations),
            
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
        onPressed: _saveProfile,
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

  Widget _buildNameField(AppLocalizations localizations) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: localizations.nameLabel,
        hintText: localizations.nameHint,
        prefixIcon: Icon(Icons.person, color: ThemeUtils.mysticPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ThemeUtils.mysticPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white54),
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
        prefixIcon: Icon(Icons.public, color: ThemeUtils.mysticPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ThemeUtils.mysticPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white54),
      ),
      dropdownColor: Color(0xFF1E1E1E),
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
        prefixIcon: Icon(Icons.people, color: ThemeUtils.mysticPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ThemeUtils.mysticPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white54),
      ),
      dropdownColor: Color(0xFF1E1E1E),
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

  Widget _buildInterestsField(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.interests, color: ThemeUtils.mysticPurple),
            const SizedBox(width: 8),
            Text(
              localizations.interestsLabel,
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
