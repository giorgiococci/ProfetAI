import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../l10n/app_localizations.dart';
import '../prophet_localizations.dart';
import '../services/user_profile_service.dart';
import '../utils/utils.dart';

class ProfetSelectionScreen extends StatefulWidget {
  final ProfetType selectedProfet;
  final Function(ProfetType) onProfetChange;

  const ProfetSelectionScreen({
    super.key,
    required this.selectedProfet,
    required this.onProfetChange,
  });

  @override
  State<ProfetSelectionScreen> createState() => _ProfetSelectionScreenState();
}

class _ProfetSelectionScreenState extends State<ProfetSelectionScreen> 
    with LoadingStateMixin {
  final UserProfileService _profileService = UserProfileService();
  late ProphetSelectionState _prophetState;
  String? _favoriteProphet;

  @override
  void initState() {
    super.initState();
    _prophetState = ProphetSelectionState();
    _prophetState.selectProphet(widget.selectedProfet);
    _loadFavoriteProphet();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload favorite prophet data when the screen becomes active again
    _loadFavoriteProphet();
  }

  Future<void> _loadFavoriteProphet() async {
    executeWithLoading(() async {
      await _profileService.loadProfile();
      if (mounted) {
        setState(() {
          _favoriteProphet = _profileService.getFavoriteProphet();
        });
      }
    });
  }

  Future<void> _toggleFavorite(ProfetType profetType) async {
    final prophetTypeString = _getProphetTypeString(profetType);
    
    if (_favoriteProphet == prophetTypeString) {
      // Remove from favorites
      await _profileService.setFavoriteProphet(null);
      setState(() {
        _favoriteProphet = null;
      });
    } else {
      // Set as favorite
      await _profileService.setFavoriteProphet(prophetTypeString);
      setState(() {
        _favoriteProphet = prophetTypeString;
      });
      
      // Show confirmation message
      if (mounted) {
        final profet = ProfetManager.getProfet(profetType);
        final prophetName = await _getProphetName(profetType);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.favoriteOracleSet(prophetName),
            ),
            backgroundColor: profet.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getProphetTypeString(ProfetType profetType) {
    switch (profetType) {
      case ProfetType.mistico:
        return 'mystic';
      case ProfetType.caotico:
        return 'chaotic';
      case ProfetType.cinico:
        return 'cynical';
    }
  }

  Future<String> _getProphetName(ProfetType profetType) async {
    final prophetTypeString = _getProphetTypeString(profetType);
    return await ProphetLocalizations.getName(context, prophetTypeString);
  }

  @override
  Widget build(BuildContext context) {
    final currentProfet = ProfetManager.getProfet(widget.selectedProfet);
    final localizations = AppLocalizations.of(context)!;;
    
    return Container(
      decoration: ThemeUtils.getProphetGradientDecoration(widget.selectedProfet),
      child: SafeArea(
        child: Padding(
          padding: ThemeUtils.paddingLG,
          child: Column(
            children: [
              ThemeUtils.spacerLG,
              Text(
                localizations.selectYourOracle,
                style: ThemeUtils.headlineStyle.copyWith(
                  color: currentProfet.primaryColor,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              ThemeUtils.spacerSM,
              Text(
                localizations.everyOracleUniquePersonality,
                style: ThemeUtils.subtitleStyle.copyWith(
                  color: Colors.grey[300],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              
              ThemeUtils.spacerXL,
              
              // Lista degli oracoli
              Expanded(
                child: ListView(
                  children: ProfetManager.getAllTypes().map((profetType) {
                    final profet = ProfetManager.getProfet(profetType);
                    final isSelected = profetType == widget.selectedProfet;
                    final prophetTypeString = _getProphetTypeString(profetType);
                    final isFavorite = _favoriteProphet == prophetTypeString;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            widget.onProfetChange(profetType);
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
                                      FutureBuilder<String>(
                                        future: ProphetLocalizations.getName(context, prophetTypeString),
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data ?? 'Oracle',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: profet.primaryColor,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 5),
                                      FutureBuilder<String>(
                                        future: ProphetLocalizations.getDescription(context, prophetTypeString),
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data ?? 'An ancient oracle',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[300],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      FutureBuilder<String>(
                                        future: ProphetLocalizations.getLocation(context, prophetTypeString),
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data ?? 'Temple of Wisdom',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                              letterSpacing: 1.0,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // Favorite Icon
                                GestureDetector(
                                  onTap: () => _toggleFavorite(profetType),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: isFavorite 
                                          ? Colors.red[400] 
                                          : Colors.grey[400],
                                      size: 24,
                                    ),
                                  ),
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
