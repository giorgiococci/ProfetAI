import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../l10n/app_localizations.dart';
import '../prophet_localizations.dart';

class ProfetSelectionScreen extends StatelessWidget {
  final ProfetType selectedProfet;
  final Function(ProfetType) onProfetChange;

  const ProfetSelectionScreen({
    super.key,
    required this.selectedProfet,
    required this.onProfetChange,
  });

  @override
  Widget build(BuildContext context) {
    final currentProfet = ProfetManager.getProfet(selectedProfet);
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: currentProfet.backgroundGradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                localizations.selectYourOracle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: currentProfet.primaryColor,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                localizations.everyOracleUniquePersonality,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[300],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Lista degli oracoli
              Expanded(
                child: ListView(
                  children: ProfetManager.getAllTypes().map((profetType) {
                    final profet = ProfetManager.getProfet(profetType);
                    final isSelected = profetType == selectedProfet;
                    
                    // Get the prophet type string for localization
                    String prophetTypeString;
                    switch (profetType) {
                      case ProfetType.mistico:
                        prophetTypeString = 'mystic';
                        break;
                      case ProfetType.caotico:
                        prophetTypeString = 'chaotic';
                        break;
                      case ProfetType.cinico:
                        prophetTypeString = 'cynical';
                        break;
                    }
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onProfetChange(profetType);
                            // Navigazione rimossa - gestiamo tutto dal main.dart
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? profet.primaryColor.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected 
                                    ? profet.primaryColor
                                    : Colors.white.withValues(alpha: 0.3),
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: profet.primaryColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: profet.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: profet.profetImagePath != null
                                      ? ClipOval(
                                          child: Image.asset(
                                            profet.profetImagePath!,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              // Fallback all'icona se l'immagine non carica
                                              return Icon(
                                                profet.icon,
                                                color: profet.primaryColor,
                                                size: 30,
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          profet.icon,
                                          color: profet.primaryColor,
                                          size: 30,
                                        ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ProphetLocalizations.getName(context, prophetTypeString),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: profet.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        ProphetLocalizations.getDescription(context, prophetTypeString),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[300],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        ProphetLocalizations.getLocation(context, prophetTypeString),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[400],
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: profet.primaryColor,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
