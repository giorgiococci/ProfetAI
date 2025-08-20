import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_profile.dart';
import '../../../services/user_profile_service.dart';
import '../../../utils/utils.dart';

class InterestsAndTopicsScreen extends StatefulWidget {
  const InterestsAndTopicsScreen({super.key});

  @override
  State<InterestsAndTopicsScreen> createState() => _InterestsAndTopicsScreenState();
}

class _InterestsAndTopicsScreenState extends State<InterestsAndTopicsScreen> 
    with FormStateMixin, LoadingStateMixin {
  final UserProfileService _profileService = UserProfileService();

  UserProfile _currentProfile = const UserProfile();
  List<Interest> _selectedInterests = [];

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
        
        // Map string interests to Interest objects
        _selectedInterests = UserProfileService.getInterests()
            .where((interest) => _currentProfile.interests.contains(interest.key))
            .toList();
        
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.failedToLoadProfile(e.toString()))),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setLoading(true);
    
    try {
      final updatedProfile = _currentProfile.copyWith(
        interests: _selectedInterests.map((i) => i.key).toList(),
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
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.failedToSaveProfile(e.toString())),
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
          title: Text(localizations.interestsAndTopics),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.interestsAndTopics),
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
                  _buildInterestsField(localizations),
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

  Widget _buildInterestsField(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.interests),
            const SizedBox(width: 8),
            Text(
              localizations.interestsLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
            );
          }).toList(),
        ),
      ],
    );
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
