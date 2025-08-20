import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_profile.dart';
import '../../../services/user_profile_service.dart';
import '../../../utils/utils.dart';

class PersonalizationPreferencesScreen extends StatefulWidget {
  const PersonalizationPreferencesScreen({super.key});

  @override
  State<PersonalizationPreferencesScreen> createState() => _PersonalizationPreferencesScreenState();
}

class _PersonalizationPreferencesScreenState extends State<PersonalizationPreferencesScreen> 
    with FormStateMixin, LoadingStateMixin {
  final UserProfileService _profileService = UserProfileService();

  UserProfile _currentProfile = const UserProfile();
  List<String> _selectedLifeFocusAreas = [];
  String? _selectedLifeStage;

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
        
        _selectedLifeFocusAreas = List.from(_currentProfile.lifeFocusAreas);
        _selectedLifeStage = _currentProfile.lifeStage;
        
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
    setLoading(true);
    
    try {
      final updatedProfile = _currentProfile.copyWith(
        lifeFocusAreas: _selectedLifeFocusAreas,
        lifeStage: _selectedLifeStage,
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
          title: Text(localizations.personalizeYourExperience),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.personalizeYourExperience),
        elevation: 0,
      ),
      body: ListView(
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
                  _buildLifeFocusAreasField(localizations),
                  const SizedBox(height: 16),
                  _buildLifeStageField(localizations),
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
    );
  }

  Widget _buildLifeFocusAreasField(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.lifeFocusAreasLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.lifeFocusAreasHint,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getLifeFocusOptions(localizations).map((option) {
            final isSelected = _selectedLifeFocusAreas.contains(option['key']);
            return FilterChip(
              label: Text(option['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected && _selectedLifeFocusAreas.length < 3) {
                    _selectedLifeFocusAreas.add(option['key']!);
                  } else if (!selected) {
                    _selectedLifeFocusAreas.remove(option['key']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLifeStageField(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.lifeStageLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.lifeStageHint,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getLifeStageOptions(localizations).map((option) {
            final isSelected = _selectedLifeStage == option['key'];
            return FilterChip(
              label: Text(option['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedLifeStage = selected ? option['key'] : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Map<String, String>> _getLifeFocusOptions(AppLocalizations localizations) {
    return [
      {'key': 'loveRelationships', 'label': localizations.lifeFocusLoveRelationships},
      {'key': 'careerPurpose', 'label': localizations.lifeFocusCareerPurpose},
      {'key': 'familyHome', 'label': localizations.lifeFocusFamilyHome},
      {'key': 'healthWellness', 'label': localizations.lifeFocusHealthWellness},
      {'key': 'moneyAbundance', 'label': localizations.lifeFocusMoneyAbundance},
      {'key': 'spiritualGrowth', 'label': localizations.lifeFocusSpiritualGrowth},
      {'key': 'personalDevelopment', 'label': localizations.lifeFocusPersonalDevelopment},
      {'key': 'creativityPassion', 'label': localizations.lifeFocusCreativityPassion},
    ];
  }

  List<Map<String, String>> _getLifeStageOptions(AppLocalizations localizations) {
    return [
      {'key': 'startingNewChapter', 'label': localizations.lifeStageStartingNewChapter},
      {'key': 'seekingDirection', 'label': localizations.lifeStageSeekingDirection},
      {'key': 'facingChallenges', 'label': localizations.lifeStageFacingChallenges},
      {'key': 'periodOfGrowth', 'label': localizations.lifeStagePeriodOfGrowth},
      {'key': 'lookingForStability', 'label': localizations.lifeStageLookingForStability},
      {'key': 'embracingChange', 'label': localizations.lifeStageEmbracingChange},
    ];
  }
}
