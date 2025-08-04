import 'package:flutter/material.dart';
import '../../models/profet_manager.dart';
import '../../l10n/app_localizations.dart';

class OnboardingPersonalizationScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function({String? name, String? favoriteProphet}) onSave;

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    widget.onSave(
      name: _nameController.text,
      favoriteProphet: _selectedOracle,
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
              ..._buildOracleSelections(),
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
}
