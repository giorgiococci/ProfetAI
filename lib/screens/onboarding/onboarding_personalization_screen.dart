import 'package:flutter/material.dart';
import '../../models/profet_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/prophet_localization_loader.dart';

class OnboardingPersonalizationScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function({
    String? name, 
    String? favoriteProphet,
    List<String>? lifeFocusAreas,
    String? lifeStage,
  }) onSave;

  const OnboardingPersonalizationScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onSave,
  });

  @override
  State<OnboardingPersonalizationScreen> createState() => _OnboardingPersonalizationScreenState();
}

class _OnboardingPersonalizationScreenState extends State<OnboardingPersonalizationScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedOracle;
  
  // New personalization state
  final List<String> _selectedLifeFocusAreas = [];
  String? _selectedLifeStage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    widget.onSave(
      name: _nameController.text,
      favoriteProphet: _selectedOracle,
      lifeFocusAreas: _selectedLifeFocusAreas,
      lifeStage: _selectedLifeStage,
    );
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView( // Make the screen scrollable
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Skip button
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: widget.onSkip,
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
            l10n.personalizeYourExperience,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 10),
          
          // Subtitle
          Text(
            l10n.personalizeOptional,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 50),
          
          // Name input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.whatShouldOraclesCallYou,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n.enterYourNameOptional,
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1F1B24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Life Focus Areas
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.lifeFocusAreasLabel,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.lifeFocusAreasHint,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              
              ..._buildLifeFocusOptions(),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Life Stage
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.lifeStageLabel,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.lifeStageHint,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              
              ..._buildLifeStageOptions(),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Oracle preference
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.doYouHavePreferredOracle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              
              // Dynamic oracle selection cards (top 5)
              FutureBuilder<List<Widget>>(
                future: _buildOracleSelectionsAsync(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Loading state
                    return Column(
                      children: List.generate(5, (index) => 
                        Column(
                          children: [
                            _buildOracleSelectionLoading(),
                            if (index < 4) const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return Column(children: snapshot.data!);
                  } else {
                    // Fallback to original names if loading fails
                    return Column(children: _buildOracleSelections());
                  }
                },
              ),
            ],
          ),
          
          const SizedBox(height: 60), // Increased spacing before button
          
          // Continue button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _handleContinue,
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
                    l10n.enterTheMysticalRealm,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.auto_awesome),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40), // Bottom padding for scroll
        ],
      ),
    );
  }

  Future<List<Widget>> _buildOracleSelectionsAsync() async {
    final oracles = ProfetManager.getAllProfeti();
    final topOracles = oracles.take(5).toList();
    final allTypes = ProfetManager.getAllTypes();
    final widgets = <Widget>[];
    
    for (int i = 0; i < topOracles.length; i++) {
      final oracle = topOracles[i];
      final oracleType = allTypes[i];
      
      try {
        final localizedName = await ProphetLocalizationLoader.getProphetName(
          context, 
          oracle.type  // Use oracle.type instead of oracleType.name
        );
        final localizedDescription = await ProphetLocalizationLoader.getProphetDescription(
          context, 
          oracle.type  // Use oracle.type instead of oracleType.name
        );
        
        widgets.add(
          _buildOracleSelection(
            id: oracleType.name,
            name: localizedName,
            description: localizedDescription,
            imagePath: oracle.profetImagePath,
            icon: oracle.icon,
            color: oracle.primaryColor,
          ),
        );
      } catch (e) {
        // Fallback to original names if localization fails
        widgets.add(
          _buildOracleSelection(
            id: oracleType.name,
            name: oracle.name,
            description: oracle.description,
            imagePath: oracle.profetImagePath,
            icon: oracle.icon,
            color: oracle.primaryColor,
          ),
        );
      }
      
      // Add spacing between items (except for the last one)
      if (i < topOracles.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    
    return widgets;
  }

  Widget _buildOracleSelectionLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Loading circle for image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loading bar for name
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                // Loading bar for description
                Container(
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOracleSelections() {
    final oracles = ProfetManager.getAllProfeti();
    // Show only top 5 oracles
    final topOracles = oracles.take(5).toList();
    
    return topOracles.asMap().entries.map((entry) {
      final oracle = entry.value;
      final oracleType = ProfetManager.getAllTypes()[entry.key];
      
      return Column(
        children: [
          _buildOracleSelection(
            id: oracleType.name,
            name: oracle.name,
            description: oracle.description,
            imagePath: oracle.profetImagePath,
            icon: oracle.icon,
            color: oracle.primaryColor,
          ),
          if (entry.key < topOracles.length - 1) const SizedBox(height: 12),
        ],
      );
    }).toList();
  }

  Widget _buildOracleSelection({
    required String id,
    required String name,
    required String description,
    String? imagePath,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedOracle == id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOracle = _selectedOracle == id ? null : id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1F1B24),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipOval(
                child: imagePath != null 
                  ? Image.asset(
                      imagePath,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        return Icon(
                          icon,
                          size: 24,
                          color: Colors.white,
                        );
                      },
                    )
                  : Icon(
                      icon,
                      size: 24,
                      color: Colors.white,
                    ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // Build life focus area selection chips
  List<Widget> _buildLifeFocusOptions() {
    final l10n = AppLocalizations.of(context)!;
    
    final options = [
      {'key': 'loveRelationships', 'label': l10n.lifeFocusLoveRelationships},
      {'key': 'careerPurpose', 'label': l10n.lifeFocusCareerPurpose},
      {'key': 'familyHome', 'label': l10n.lifeFocusFamilyHome},
      {'key': 'healthWellness', 'label': l10n.lifeFocusHealthWellness},
      {'key': 'moneyAbundance', 'label': l10n.lifeFocusMoneyAbundance},
      {'key': 'spiritualGrowth', 'label': l10n.lifeFocusSpiritualGrowth},
      {'key': 'personalDevelopment', 'label': l10n.lifeFocusPersonalDevelopment},
      {'key': 'creativityPassion', 'label': l10n.lifeFocusCreativityPassion},
    ];

    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
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
            backgroundColor: const Color(0xFF1F1B24),
            selectedColor: Colors.deepPurpleAccent.withOpacity(0.3),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
            ),
            side: BorderSide(
              color: isSelected ? Colors.deepPurpleAccent : Colors.grey.withOpacity(0.3),
            ),
          );
        }).toList(),
      ),
    ];
  }

  // Build life stage selection
  List<Widget> _buildLifeStageOptions() {
    final l10n = AppLocalizations.of(context)!;
    
    final options = [
      {'key': 'startingNewChapter', 'label': l10n.lifeStageStartingNewChapter},
      {'key': 'seekingDirection', 'label': l10n.lifeStageSeekingDirection},
      {'key': 'facingChallenges', 'label': l10n.lifeStageFacingChallenges},
      {'key': 'periodOfGrowth', 'label': l10n.lifeStagePeriodOfGrowth},
      {'key': 'lookingForStability', 'label': l10n.lifeStageLookingForStability},
      {'key': 'embracingChange', 'label': l10n.lifeStageEmbracingChange},
    ];

    return options.map((option) {
      final isSelected = _selectedLifeStage == option['key'];
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedLifeStage = _selectedLifeStage == option['key'] ? null : option['key'];
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1F1B24),
                border: Border.all(
                  color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.deepPurpleAccent : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }
}
