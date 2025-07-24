import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/secure_config_service.dart';
import '../models/profet.dart';
import '../build_config.dart';

class AIStatusScreen extends StatefulWidget {
  const AIStatusScreen({super.key});

  @override
  State<AIStatusScreen> createState() => _AIStatusScreenState();
}

class _AIStatusScreenState extends State<AIStatusScreen> {
  bool _isAIEnabled = false;
  Map<String, String?> _configStatus = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAIStatus();
  }

  Future<void> _checkAIStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final configStatus = await SecureConfigService.getConfigurationStatus();
      setState(() {
        _isAIEnabled = SecureConfigService.isAIEnabled && Profet.isAIEnabled;
        _configStatus = configStatus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, String?>> _getDebugValues() async {
    try {
      // For debugging, read the actual stored values
      final storage = FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
      
      final endpoint = await storage.read(key: 'azure_openai_endpoint');
      final apiKey = await storage.read(key: 'azure_openai_api_key');
      final deploymentName = await storage.read(key: 'azure_openai_deployment_name');
      final enableAI = await storage.read(key: 'enable_ai');
      final version = await storage.read(key: 'config_version');
      
      return {
        'endpoint': endpoint ?? 'NULL',
        'apiKey': apiKey ?? 'NULL',
        'deploymentName': deploymentName ?? 'NULL',
        'enableAI': enableAI ?? 'NULL',
        'version': version ?? 'NULL',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stato Intelligenza Artificiale'),
        backgroundColor: const Color(0xFF1F1B24),
        actions: [
          IconButton(
            icon: _isLoading ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ) : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _checkAIStatus,
            tooltip: 'Aggiorna stato',
          ),
        ],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // AI Status Card
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
                        SecureConfigService.getStatus(),
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
              
              const SizedBox(height: 16),
              
              // Debug Configuration Card
              Card(
                color: const Color(0xFF2D2D30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bug_report, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Debug - Configurazione',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () => _copyDebugInfo(),
                            tooltip: 'Copia info debug',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDebugRow('Build Config', BuildConfig.isConfigured ? 'Configurato' : 'Non configurato'),
                      _buildDebugRow('Secure Storage', SecureConfigService.isAIEnabled ? 'Abilitato' : 'Disabilitato'),
                      _buildDebugRow('Profet AI', Profet.isAIEnabled ? 'Attivo' : 'Non attivo'),
                      const SizedBox(height: 8),
                      const Text(
                        'Valori BuildConfig:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      _buildDebugRow('BC Endpoint', BuildConfig.azureOpenAIEndpoint.isEmpty ? 'EMPTY' : BuildConfig.azureOpenAIEndpoint),
                      _buildDebugRow('BC API Key', BuildConfig.azureOpenAIApiKey.isEmpty ? 'EMPTY' : BuildConfig.azureOpenAIApiKey),
                      _buildDebugRow('BC Deployment', BuildConfig.azureOpenAIDeploymentName.isEmpty ? 'EMPTY' : BuildConfig.azureOpenAIDeploymentName),
                      const SizedBox(height: 8),
                      const Text(
                        'Valori Secure Storage:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      FutureBuilder<Map<String, String?>>(
                        future: _getDebugValues(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final values = snapshot.data!;
                            return Column(
                              children: [
                                _buildDebugRow('SS Endpoint', values['endpoint'] ?? 'ERROR'),
                                _buildDebugRow('SS API Key', values['apiKey'] ?? 'ERROR'),
                                _buildDebugRow('SS Deployment', values['deploymentName'] ?? 'ERROR'),
                                _buildDebugRow('SS EnableAI', values['enableAI'] ?? 'ERROR'),
                                _buildDebugRow('SS Version', values['version'] ?? 'ERROR'),
                              ],
                            );
                          } else {
                            return const Text('Loading...');
                          }
                        },
                      ),
                      const Divider(color: Colors.white24),
                      _buildDebugRow('Endpoint', _configStatus['endpoint'] ?? 'Non impostato'),
                      _buildDebugRow('API Key', _configStatus['apiKey'] ?? 'Non impostato'),
                      _buildDebugRow('Deployment', _configStatus['deploymentName'] ?? 'Non impostato'),
                      _buildDebugRow('AI Abilitato', _configStatus['enableAI'] ?? 'false'),
                      _buildDebugRow('Versione Config', _configStatus['configVersion'] ?? 'Sconosciuta'),
                      const Divider(color: Colors.white24),
                      if (BuildConfig.isConfigured) ...[
                        _buildDebugRow('Build Endpoint', BuildConfig.azureOpenAIEndpoint.isNotEmpty ? 'Presente' : 'Vuoto'),
                        _buildDebugRow('Build API Key', BuildConfig.azureOpenAIApiKey.isNotEmpty ? 'Presente' : 'Vuoto'),
                        _buildDebugRow('Build Deployment', BuildConfig.azureOpenAIDeploymentName.isNotEmpty ? 'Presente' : 'Vuoto'),
                        _buildDebugRow('Build AI Enable', BuildConfig.enableAI.toString()),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
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
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () async {
                  await _checkAIStatus();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Stato aggiornato: ${SecureConfigService.getStatus()}'),
                        backgroundColor: _isAIEnabled ? Colors.green : Colors.orange,
                      ),
                    );
                  }
                },
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
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
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    final isError = value.contains('Non') || value.contains('Vuoto') || value == 'false';
    final isSuccess = value.contains('Configurato') || value.contains('Presente') || value.contains('Abilitato') || value.contains('Attivo') || value == 'true';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                color: isError 
                    ? Colors.red[300] 
                    : isSuccess 
                        ? Colors.green[300] 
                        : Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyDebugInfo() {
    final debugInfo = '''
=== DEBUG INFO ===
Build Config: ${BuildConfig.isConfigured ? 'Configurato' : 'Non configurato'}
Secure Storage: ${SecureConfigService.isAIEnabled ? 'Abilitato' : 'Disabilitato'}
Profet AI: ${Profet.isAIEnabled ? 'Attivo' : 'Non attivo'}
Endpoint: ${_configStatus['endpoint'] ?? 'Non impostato'}
API Key: ${_configStatus['apiKey'] ?? 'Non impostato'}
Deployment: ${_configStatus['deploymentName'] ?? 'Non impostato'}
AI Abilitato: ${_configStatus['enableAI'] ?? 'false'}
Versione Config: ${_configStatus['configVersion'] ?? 'Sconosciuta'}
${BuildConfig.isConfigured ? '''
Build Endpoint: ${BuildConfig.azureOpenAIEndpoint.isNotEmpty ? 'Presente' : 'Vuoto'}
Build API Key: ${BuildConfig.azureOpenAIApiKey.isNotEmpty ? 'Presente' : 'Vuoto'}
Build Deployment: ${BuildConfig.azureOpenAIDeploymentName.isNotEmpty ? 'Presente' : 'Vuoto'}
Build AI Enable: ${BuildConfig.enableAI}''' : ''}
==================
''';

    Clipboard.setData(ClipboardData(text: debugInfo));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Info debug copiate negli appunti'),
        backgroundColor: Colors.blue,
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
