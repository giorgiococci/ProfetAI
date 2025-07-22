import 'package:flutter/material.dart';
import '../models/profet_manager.dart';
import '../models/profet.dart';

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

  @override
  Widget build(BuildContext context) {
    final profet = ProfetManager.getProfet(widget.selectedProfet);
    
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
              Text(
                profet.location,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: profet.primaryColor,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                profet.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[300],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
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
                    child: Icon(
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
                    hintText: profet.getHintText(),
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
                              content: const Text('📝 Inserisci una domanda prima di chiedere!'),
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
                      label: const Text(
                        'DOMANDA ALL\'ORACOLO',
                        style: TextStyle(
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
                      label: const Text(
                        'ASCOLTA L\'ORACOLO',
                        style: TextStyle(
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
    String content;
    IconData dialogIcon;
    bool isAIEnabled = Profet.isAIEnabled; // Check if AI is available
    
    if (hasQuestion && question != null && question.isNotEmpty) {
      title = '🔮 ${profet.name} Risponde';
      dialogIcon = Icons.psychology_alt;
      
      if (isAIEnabled) {
        // Show loading dialog first
        _showLoadingDialog(profet);
        
        try {
          content = await profet.getAIPersonalizedResponse(question);
          Navigator.of(context).pop(); // Close loading dialog
        } catch (e) {
          Navigator.of(context).pop(); // Close loading dialog
          content = profet.getPersonalizedResponse(question);
          isAIEnabled = false; // Fallback to regular response
        }
      } else {
        content = profet.getPersonalizedResponse(question);
      }
    } else {
      title = '✨ Visione di ${profet.name}';
      dialogIcon = Icons.auto_awesome;
      
      if (isAIEnabled) {
        // Show loading dialog first
        _showLoadingDialog(profet);
        
        try {
          content = await profet.getAIRandomVision();
          Navigator.of(context).pop(); // Close loading dialog
        } catch (e) {
          Navigator.of(context).pop(); // Close loading dialog
          final visions = profet.getRandomVisions();
          content = visions.isNotEmpty ? visions.first : "L'oracolo è in silenzio...";
          isAIEnabled = false; // Fallback to regular response
        }
      } else {
        final visions = profet.getRandomVisions();
        content = visions.isNotEmpty ? visions.first : "L'oracolo è in silenzio...";
      }
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.bookmark_add, color: profet.primaryColor, size: 20),
                  label: Text(
                    'Salva',
                    style: TextStyle(color: profet.primaryColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showSavedMessage();
                  },
                ),
                TextButton.icon(
                  icon: Icon(Icons.share, color: profet.secondaryColor, size: 20),
                  label: Text(
                    'Condividi',
                    style: TextStyle(color: profet.secondaryColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showShareMessage();
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  label: const Text(
                    'Chiudi',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (hasQuestion) _questionController.clear();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(profet) {
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
                'L\'${profet.name} sta consultando l\'intelligenza artificiale...',
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

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
