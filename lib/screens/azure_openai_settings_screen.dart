import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/profet.dart';
import '../models/oracolo_mistico.dart';

class AzureOpenAISettingsScreen extends StatefulWidget {
  const AzureOpenAISettingsScreen({super.key});

  @override
  State<AzureOpenAISettingsScreen> createState() => _AzureOpenAISettingsScreenState();
}

class _AzureOpenAISettingsScreenState extends State<AzureOpenAISettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _endpointController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _deploymentController = TextEditingController();
  
  bool _isLoading = false;
  bool _isConfigured = false;
  String? _statusMessage;
  
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  void initState() {
    super.initState();
    _loadExistingConfig();
  }

  Future<void> _loadExistingConfig() async {
    try {
      final endpoint = await _secureStorage.read(key: 'azure_openai_endpoint');
      final deploymentName = await _secureStorage.read(key: 'azure_openai_deployment');
      
      if (endpoint != null) {
        _endpointController.text = endpoint;
      }
      
      if (deploymentName != null) {
        _deploymentController.text = deploymentName;
      }
      
      // Check if AI is already configured
      final aiConfigured = await Profet.loadStoredAICredentials();
      setState(() {
        _isConfigured = aiConfigured;
      });
    } catch (e) {
      print('Error loading config: $e');
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // Initialize AI service
      await Profet.initializeAI(
        endpoint: _endpointController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        deploymentName: _deploymentController.text.trim(),
      );

      // Store deployment name separately for UI
      await _secureStorage.write(
        key: 'azure_openai_deployment', 
        value: _deploymentController.text.trim()
      );

      setState(() {
        _isConfigured = true;
        _statusMessage = 'Configurazione salvata con successo! ✅\n\nOra i tuoi oracoli useranno l\'AI per le profezie.';
      });

      // Clear API key field for security
      _apiKeyController.clear();
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Errore nella configurazione: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearConfiguration() async {
    await Profet.clearAICredentials();
    await _secureStorage.deleteAll();
    setState(() {
      _isConfigured = false;
      _statusMessage = 'Configurazione cancellata. Gli oracoli useranno le risposte predefinite.';
      _endpointController.clear();
      _apiKeyController.clear();
      _deploymentController.clear();
    });
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      // First initialize the AI service
      await Profet.initializeAI(
        endpoint: _endpointController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        deploymentName: _deploymentController.text.trim(),
      );

      // Test with a simple AI call using OracoloMistico
      const testProfet = OracoloMistico();
      final response = await testProfet.getAIPersonalizedResponse("Test di connessione");
      
      setState(() {
        _statusMessage = 'Test connessione riuscito! ✅\nRisposta: ${response.substring(0, response.length > 100 ? 100 : response.length)}...';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Test fallito: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurazione Azure OpenAI'),
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
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: const Color(0xFF2D2D30),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stato Configurazione',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _isConfigured ? Icons.check_circle : Icons.warning,
                              color: _isConfigured ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isConfigured 
                                ? 'Azure OpenAI configurato' 
                                : 'Azure OpenAI non configurato',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _endpointController,
                  decoration: const InputDecoration(
                    labelText: 'Endpoint Azure OpenAI',
                    hintText: 'https://your-resource.openai.azure.com',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci l\'endpoint Azure OpenAI';
                    }
                    if (!value.startsWith('https://')) {
                      return 'L\'endpoint deve iniziare con https://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    hintText: 'La tua chiave API Azure OpenAI',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci la API Key';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _deploymentController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Deployment',
                    hintText: 'gpt-4o, gpt-35-turbo, etc.',
                    prefixIcon: Icon(Icons.rocket_launch),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci il nome del deployment';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testConnection,
                        icon: const Icon(Icons.wifi_protected_setup),
                        label: const Text('Test Connessione'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveConfiguration,
                        icon: const Icon(Icons.save),
                        label: const Text('Salva Config'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (_isConfigured)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _clearConfiguration,
                    icon: const Icon(Icons.delete),
                    label: const Text('Cancella Configurazione'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                if (_statusMessage != null)
                  Card(
                    color: _statusMessage!.contains('✅') 
                        ? Colors.green.withOpacity(0.1) 
                        : Colors.red.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _statusMessage!.contains('✅') 
                              ? Colors.green 
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _apiKeyController.dispose();
    _deploymentController.dispose();
    super.dispose();
  }
}
