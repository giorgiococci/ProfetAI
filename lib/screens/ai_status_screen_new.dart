import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_service_manager.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';

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
      final isInitialized = await AIServiceManager.initialize();
      final configStatus = await _getConfigurationStatus();
      
      setState(() {
        _isAIEnabled = AIServiceManager.isAIAvailable;
        _configStatus = configStatus;
        _isLoading = false;
      });
      
      AppLogger.logInfo('AIStatusScreen', 'AI Status Check - Available: $_isAIEnabled, Initialized: $isInitialized');
    } catch (e) {
      AppLogger.logError('AIStatusScreen', 'Failed to check AI status', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get configuration status using new system
  Future<Map<String, String?>> _getConfigurationStatus() async {
    try {
      final storedConfig = await SecureConfigManager.getStoredConfig();
      return {
        'buildTimeConfigured': AppConfig.isAIConfigured.toString(),
        'aiAvailable': AIServiceManager.isAIAvailable.toString(),
        'endpoint': storedConfig['endpoint'] ?? AppConfig.azureEndpoint,
        'apiKey': storedConfig['apiKey']?.isNotEmpty == true ? 'CONFIGURED' : 'EMPTY',
        'deploymentName': storedConfig['deploymentName'] ?? AppConfig.azureDeploymentName,
        'enableAI': storedConfig['enableAI'] ?? AppConfig.enableAI.toString(),
      };
    } catch (e) {
      AppLogger.logError('AIStatusScreen', 'Failed to get configuration status', e);
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'AI Status',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
              Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 20),
                      _buildConfigurationCard(),
                      const SizedBox(height: 20),
                      if (AppConfig.isDebugMode) _buildDebugCard(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: const Color(0xFF2D2D30),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isAIEnabled ? Icons.check_circle : Icons.error,
                  color: _isAIEnabled ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Service Status',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _isAIEnabled 
                  ? 'AI Service is operational and ready to provide responses'
                  : 'AI Service is not available. Check configuration.',
              style: TextStyle(
                fontSize: 16,
                color: _isAIEnabled ? Colors.green[300] : Colors.red[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationCard() {
    return Card(
      color: const Color(0xFF2D2D30),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildConfigRow('Build Config', AppConfig.isAIConfigured ? 'Configured' : 'Not Configured'),
            _buildConfigRow('AI Available', AIServiceManager.isAIAvailable ? 'Yes' : 'No'),
            _buildConfigRow('Endpoint', AppConfig.azureEndpoint.isNotEmpty ? 'Configured' : 'Empty'),
            _buildConfigRow('API Key', AppConfig.azureApiKey.isNotEmpty ? 'Configured' : 'Empty'),
            _buildConfigRow('Deployment', AppConfig.azureDeploymentName.isNotEmpty ? 'Configured' : 'Empty'),
            _buildConfigRow('AI Enabled', AppConfig.enableAI ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugCard() {
    return Card(
      color: const Color(0xFF2D2D30),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Text(
                AIServiceManager.getDetailedStatus(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    final isGood = value.toLowerCase().contains('configured') || 
                   value.toLowerCase().contains('yes') ||
                   value.toLowerCase().contains('operational');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isGood ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isGood ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: isGood ? Colors.green[300] : Colors.orange[300],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _checkAIStatus,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _copyDebugInfo,
            icon: const Icon(Icons.copy),
            label: const Text('Copy Debug Info'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D2D30),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.deepPurpleAccent),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _copyDebugInfo() async {
    final debugInfo = '''
=== ProfetAI Debug Information ===
AI Available: ${AIServiceManager.isAIAvailable}
Build Config: ${AppConfig.isAIConfigured ? 'Configured' : 'Not Configured'}

${AppConfig.getDebugInfo()}

=== Detailed Status ===
${AIServiceManager.getDetailedStatus()}

Generated: ${DateTime.now()}
    ''';

    await Clipboard.setData(ClipboardData(text: debugInfo));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debug information copied to clipboard'),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      );
    }
  }
}
