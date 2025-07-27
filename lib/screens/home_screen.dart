import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../models/profet.dart';
import '../models/vision_feedback.dart';
import '../services/feedback_service.dart';
import '../l10n/app_localizations.dart';
import '../models/oracolo_caotico.dart';
import '../models/oracolo_mistico.dart';
import '../models/oracolo_cinico.dart';
import '../prophet_localizations.dart';
import '../l10n/prophet_localization_loader.dart';

class HomeScreen extends StatefulWidget {
  final ProfetType selectedProfet;

  const HomeScreen({
    super.key,
    required this.selectedProfet,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _questionController = TextEditingController();
  String _prophetName = '';

  @override
  void initState() {
    super.initState();
    // Load prophet name after first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProphetName();
    });
  }

  Future<void> _loadProphetName() async {
    final name = await ProphetLocalizations.getName(context, _getProphetTypeString(widget.selectedProfet));
    if (mounted) {
      setState(() {
        _prophetName = name;
      });
    }
  }

  // Helper function to get prophet type string for localization
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

  @override
  Widget build(BuildContext context) {
    final profet = ProfetManager.getProfet(widget.selectedProfet);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        // Se c'è un'immagine di sfondo, usala come DecorationImage
        image: profet.backgroundImagePath != null
            ? DecorationImage(
                image: AssetImage(profet.backgroundImagePath!),
                fit: BoxFit.cover,
                opacity: 0.3, // Opacità per mantenere leggibile il testo
              )
            : null,
        // Il gradiente viene applicato sopra l'immagine (se presente) o da solo
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: profet.backgroundImagePath != null
              ? [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.7),
                ]
              : profet.backgroundGradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Titolo del tempio
              const SizedBox(height: 20),
              FutureBuilder<String>(
                future: ProphetLocalizations.getLocation(context, _getProphetTypeString(widget.selectedProfet)),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Temple of Wisdom',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: profet.primaryColor,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 10),
              FutureBuilder<String>(
                future: ProphetLocalizations.getDescription(context, _getProphetTypeString(widget.selectedProfet)),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'An ancient oracle with wisdom',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),

              const Spacer(flex: 1),

              // Immagine dell'Oracolo (placeholder dominante)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: profet.primaryColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: profet.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          profet.primaryColor.withValues(alpha: 0.1),
                          profet.secondaryColor.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: profet.profetImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              profet.profetImagePath!,
                              width: 194,
                              height: 194,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback all'icona se l'immagine non carica
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        profet.primaryColor.withValues(alpha: 0.1),
                                        profet.secondaryColor.withValues(alpha: 0.1),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    profet.icon,
                                    size: 80,
                                    color: profet.primaryColor,
                                  ),
                                );
                              },
                            ),
                          )
                        : Icon(
                            profet.icon,
                            size: 80,
                            color: profet.primaryColor,
                          ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Campo per la domanda
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: profet.primaryColor.withValues(alpha: 0.5),
                  ),
                ),
                child: TextField(
                  controller: _questionController,
                  style: TextStyle(color: Colors.grey[100], fontSize: 16),
                  decoration: InputDecoration(
                    hintText: _prophetName.isNotEmpty 
                        ? localizations.enterQuestionPlaceholder(_prophetName)
                        : localizations.enterQuestionPlaceholder('Oracle'),
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),

              const SizedBox(height: 30),

              // Due bottoni separati per le diverse modalità
              Column(
                children: [
                  // Pulsante "Domanda all'Oracolo"
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final question = _questionController.text.trim();
                        if (question.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.enterQuestionFirst),
                              backgroundColor: Colors.red[700],
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        _showVisionDialog(hasQuestion: true, question: question);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: profet.primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8,
                      ),
                      icon: const Icon(Icons.help_outline, size: 24),
                      label: Text(
                        localizations.askTheOracle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Pulsante "Ascolta l'Oracolo"
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showVisionDialog(hasQuestion: false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: profet.primaryColor,
                        side: BorderSide(color: profet.primaryColor, width: 2),
                        backgroundColor: profet.primaryColor.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.hearing, size: 24),
                      label: Text(
                        localizations.listenToOracle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  void _showVisionDialog({bool hasQuestion = false, String? question}) async {
    final profet = ProfetManager.getProfet(widget.selectedProfet);

    // Determina il titolo e il contenuto in base alla modalità
    String title;
    String content = ''; // Initialize to avoid null errors
    IconData dialogIcon;
    bool isAIEnabled = Profet.isAIEnabled; // Check if AI is available

    if (hasQuestion && question != null && question.isNotEmpty) {
      final prophetName = await ProphetLocalizations.getName(context, _getProphetTypeString(widget.selectedProfet));
      title = '🔮 $prophetName Risponde';
      dialogIcon = Icons.psychology_alt;

      if (isAIEnabled) {
        // Show loading dialog first
        await _showLoadingDialog(profet);

        try {
          if (mounted) {
            content = await profet.getAIPersonalizedResponse(question, context);
          }
          if (mounted) Navigator.of(context).pop(); // Close loading dialog - check mounted first
        } catch (e) {
          if (mounted) Navigator.of(context).pop(); // Close loading dialog - check mounted first
          // Use localized fallback response
          if (mounted) {
            content = await profet.getLocalizedPersonalizedResponse(context, question);
            isAIEnabled = false; // Fallback to regular response
          } else {
            return; // Widget is no longer mounted, exit early
          }
        }
      } else {
        // Use localized fallback response when AI is disabled
        if (mounted) {
          content = await profet.getLocalizedPersonalizedResponse(context, question);
        } else {
          return; // Widget is no longer mounted, exit early
        }
      }
    } else {
      final prophetName = await ProphetLocalizations.getName(context, _getProphetTypeString(widget.selectedProfet));
      title = '✨ Visione di $prophetName';
      dialogIcon = Icons.auto_awesome;

      if (isAIEnabled) {
        // Show loading dialog first
        await _showLoadingDialog(profet);

        try {
          if (mounted) {
            content = await profet.getAIRandomVision(context);
          }
          if (mounted) Navigator.of(context).pop(); // Close loading dialog - check mounted first
        } catch (e) {
          if (mounted) Navigator.of(context).pop(); // Close loading dialog - check mounted first
          // Use localized random visions as fallback
          if (mounted) {
            final visions = await profet.getLocalizedRandomVisions(context);
            final fallbackText = mounted ? AppLocalizations.of(context)!.oracleSilent : 'Silent...';
            content = visions.isNotEmpty ? visions.first : fallbackText;
            isAIEnabled = false; // Fallback to regular response
          } else {
            return; // Widget is no longer mounted, exit early
          }
        }
      } else {
        // Use localized random visions when AI is disabled
        if (mounted) {
          final visions = await profet.getLocalizedRandomVisions(context);
          final fallbackText = mounted ? AppLocalizations.of(context)!.oracleSilent : 'Silent...';
          content = visions.isNotEmpty ? visions.first : fallbackText;
        } else {
          return; // Widget is no longer mounted, exit early
        }
      }
    }

    // Check mounted one more time before showing dialog
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: profet.primaryColor.withValues(alpha: 0.3)),
          ),
          title: Row(
            children: [
              Icon(dialogIcon, color: profet.primaryColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: profet.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Show AI indicator
              if (isAIEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology, color: Colors.blue, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostra la domanda se presente
              if (hasQuestion && question != null && question.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: profet.secondaryColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: profet.secondaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '"$question"',
                          style: TextStyle(
                            color: profet.secondaryColor,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // Contenuto della risposta/visione
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      profet.primaryColor.withValues(alpha: 0.1),
                      profet.secondaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: profet.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Prima riga: pulsanti di feedback
            Column(
              children: [
                // Sezione feedback
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        'Come è stata questa visione?',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Feedback positivo
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildFeedbackButton(
                                context: context,
                                profet: profet,
                                feedbackType: FeedbackType.positive,
                                icon: '🌟',
                                onPressed: () => _handleFeedback(
                                  context,
                                  profet,
                                  FeedbackType.positive,
                                  content,
                                  question,
                                ),
                              ),
                            ),
                          ),
                          // Feedback negativo
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildFeedbackButton(
                                context: context,
                                profet: profet,
                                feedbackType: FeedbackType.negative,
                                icon: '🪨',
                                onPressed: () => _handleFeedback(
                                  context,
                                  profet,
                                  FeedbackType.negative,
                                  content,
                                  question,
                                ),
                              ),
                            ),
                          ),
                          // Feedback ironico/divertente
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildFeedbackButton(
                                context: context,
                                profet: profet,
                                feedbackType: FeedbackType.funny,
                                icon: '🐸',
                                onPressed: () => _handleFeedback(
                                  context,
                                  profet,
                                  FeedbackType.funny,
                                  content,
                                  question,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Divisore
                Container(
                  height: 1,
                  color: profet.primaryColor.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                const SizedBox(height: 8),
                // Seconda riga: pulsanti di azione originali
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildActionButton(
                          context: context,
                          profet: profet,
                          icon: Icons.bookmark_add,
                          label: 'Salva',
                          color: profet.primaryColor,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showSavedMessage();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildActionButton(
                          context: context,
                          profet: profet,
                          icon: Icons.share,
                          label: 'Condividi',
                          color: profet.secondaryColor,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showShareMessage();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildActionButton(
                          context: context,
                          profet: profet,
                          icon: Icons.close,
                          label: 'Chiudi',
                          color: Colors.grey,
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (hasQuestion) _questionController.clear();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLoadingDialog(profet) async {
    // Get localized loading message based on prophet type
    String loadingMessage;
    if (profet is OracoloCaotico) {
      loadingMessage = await ProphetLocalizationLoader.getAILoadingMessage(context, 'chaotic');
    } else if (profet is OracoloMistico) {
      loadingMessage = await ProphetLocalizationLoader.getAILoadingMessage(context, 'mystic');
    } else if (profet is OracoloCinico) {
      loadingMessage = await ProphetLocalizationLoader.getAILoadingMessage(context, 'cynical');
    } else {
      loadingMessage = 'Loading...'; // Fallback
    }

    // Check if widget is still mounted before showing dialog
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: profet.primaryColor.withValues(alpha: 0.3)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(profet.primaryColor),
              ),
              const SizedBox(height: 20),
              Text(
                loadingMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: profet.primaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSavedMessage() {
    final profet = ProfetManager.getProfet(widget.selectedProfet);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.bookmark_added, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Visione salvata nel Libro delle Visioni',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: profet.primaryColor.withValues(alpha: 0.9),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showShareMessage() {
    final profet = ProfetManager.getProfet(widget.selectedProfet);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.share, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Preparando la condivisione della visione...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: profet.secondaryColor.withValues(alpha: 0.9),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Build feedback button
  Widget _buildFeedbackButton({
    required BuildContext context,
    required profet,
    required FeedbackType feedbackType,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: profet.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: profet.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 2),
            Text(
              _getFeedbackActionText(feedbackType),
              style: TextStyle(
                color: profet.primaryColor,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Build action button (responsive)
  Widget _buildActionButton({
    required BuildContext context,
    required profet,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    // Get screen width to determine if we should show text
    final screenWidth = MediaQuery.of(context).size.width;
    final showText = screenWidth > 350; // Show text only on wider screens

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      child: showText
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Icon(icon, color: color, size: 22),
    );
  }

  // Get action text for feedback type
  String _getFeedbackActionText(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return AppLocalizations.of(context)!.feedbackPositiveAction;
      case FeedbackType.negative:
        return AppLocalizations.of(context)!.feedbackNegativeAction;
      case FeedbackType.funny:
        return AppLocalizations.of(context)!.feedbackFunnyAction;
    }
  }

  // Handle feedback selection
  void _handleFeedback(
    BuildContext context,
    profet,
    FeedbackType feedbackType,
    String visionContent,
    String? question,
  ) async {
    // Create feedback using the prophet's custom localized texts
    final feedback = await profet.createFeedback(
      context,
      type: feedbackType,
      visionContent: visionContent,
      question: question,
    );

    // Save feedback
    await FeedbackService().saveFeedback(feedback);

    // Check mounted before using context
    if (!mounted) return;

    // Close the current dialog
    Navigator.of(context).pop();

    // Show feedback confirmation
    _showFeedbackConfirmation(context, profet, feedback);

    // Clear question if it was a question-based vision
    if (question != null && question.isNotEmpty) {
      _questionController.clear();
    }
  }

  // Show feedback confirmation
  void _showFeedbackConfirmation(
    BuildContext context,
    profet,
    VisionFeedback feedback,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              feedback.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    feedback.action,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    feedback.thematicText,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: profet.primaryColor.withValues(alpha: 0.9),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
