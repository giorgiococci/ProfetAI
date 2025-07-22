import 'package:flutter/material.dart';
import '../services/ai_config_service.dart';
import '../models/profet.dart';

class AIStatusScreen extends StatefulWidget {
  const AIStatusScreen({super.key});

  @override
  State<AIStatusScreen> createState() => _AIStatusScreenState();
}

class _AIStatusScreenState extends State<AIStatusScreen> {
  bool _isAIEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkAIStatus();
  }

  void _checkAIStatus() {
    setState(() {
      _isAIEnabled = AIConfigService.isAIEnabled && Profet.isAIEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stato Intelligenza Artificiale'),
        backgroundColor: const Color(0xFF1F1B24),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121212),
              Color(0xFF1F1B24),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Card(
                color: const Color(0xFF2D2D30),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        _isAIEnabled ? Icons.psychology : Icons.psychology_outlined,
                        size: 64,
                        color: _isAIEnabled ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isAIEnabled ? 'AI Attivata' : 'AI Non Configurata',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isAIEnabled ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AIConfigService.getStatus(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Card(
                color: const Color(0xFF2D2D30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Come funziona',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.auto_awesome,
                        'AI Attivata',
                        'I tuoi oracoli generano risposte uniche usando Azure OpenAI',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.library_books,
                        'AI Non Configurata',
                        'I tuoi oracoli usano le loro saggezze predefinite',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.security,
                        'Fallback Automatico',
                        'Se l\'AI non risponde, si torna alle risposte originali',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Card(
                color: const Color(0xFF2D2D30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.face, color: Colors.purple),
                          SizedBox(width: 8),
                          Text(
                            'Personalità degli Oracoli',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildOracleRow(
                        Icons.visibility,
                        'Oracolo Mistico',
                        'Saggezza antica e poetica',
                        const Color(0xFFD4AF37),
                      ),
                      const SizedBox(height: 8),
                      _buildOracleRow(
                        Icons.shuffle,
                        'Oracolo Caotico',
                        'Risposte imprevedibili e divertenti',
                        const Color(0xFFFF6B35),
                      ),
                      const SizedBox(height: 8),
                      _buildOracleRow(
                        Icons.sentiment_dissatisfied,
                        'Oracolo Cinico',
                        'Verità realistiche e sarcastiche',
                        const Color(0xFF78909C),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              ElevatedButton.icon(
                onPressed: () {
                  _checkAIStatus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Stato aggiornato: ${AIConfigService.getStatus()}'),
                      backgroundColor: _isAIEnabled ? Colors.green : Colors.orange,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Aggiorna Stato'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOracleRow(IconData icon, String name, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
