import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_profile.dart';
import '../../../services/user_profile_service.dart';
import '../../../utils/utils.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> 
    with FormStateMixin, LoadingStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final UserProfileService _profileService = UserProfileService();

  UserProfile _currentProfile = const UserProfile();
  Country? _selectedCountry;
  Gender? _selectedGender;

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
              .firstWhere((c) => c.name == _currentProfile.country);
        }
        
        // Set selected gender
        _selectedGender = _currentProfile.gender;
        
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setLoading(true);
    
    try {
      final updatedProfile = _currentProfile.copyWith(
        name: _nameController.text.isEmpty ? null : _nameController.text,
        country: _selectedCountry?.name,
        gender: _selectedGender,
      );
      
      await _profileService.saveProfile(updatedProfile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.personalInformation),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.personalInformation),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameField(localizations),
                    const SizedBox(height: 16),
                    _buildCountryField(localizations),
                    const SizedBox(height: 16),
                    _buildGenderField(localizations),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  localizations.saveProfile,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.person),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildCountryField(AppLocalizations localizations) {
    return DropdownButtonFormField<Country>(
      value: _selectedCountry,
      decoration: InputDecoration(
        labelText: localizations.countryLabel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.public),
      ),
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
      validator: (value) => null, // Optional field
    );
  }

  Widget _buildGenderField(AppLocalizations localizations) {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: localizations.genderLabel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.person_outline),
      ),
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
      validator: (value) => null, // Optional field
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
}
