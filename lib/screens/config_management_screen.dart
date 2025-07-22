import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/secure_config_service.dart';

/// Configuration management screen for secure settings
/// 
/// This screen allows users to:
/// - View current configuration status (masked)
/// - Update API credentials
/// - Test secure storage functionality
/// - Clear configuration for security incidents
class ConfigManagementScreen extends StatefulWidget {
  const ConfigManagementScreen({super.key});

  @override
  State<ConfigManagementScreen> createState() => _ConfigManagementScreenState();
}

class _ConfigManagementScreenState extends State<ConfigManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _endpointController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _deploymentController = TextEditingController();
  
  bool _enableAI = false;
  bool _isLoading = false;
  bool _secureStorageAvailable = false;
  Map<String, String?> _currentConfig = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentConfiguration();
    _checkSecureStorage();
  }

  /// Load current configuration for display
  Future<void> _loadCurrentConfiguration() async {
    try {
      final config = await SecureConfigService.getConfiguration(maskSensitive: true);
      setState(() {
        _currentConfig = config;
        _enableAI = config['enableAI'] == 'true';
      });
    } catch (e) {
      _showErrorDialog('Failed to load configuration: $e');
    }
  }

  /// Check if secure storage is available on this device
  Future<void> _checkSecureStorage() async {
    final available = await SecureConfigService.isSecureStorageAvailable();
    setState(() {
      _secureStorageAvailable = available;
    });
  }

  /// Save new configuration
  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await SecureConfigService.storeConfiguration(
        endpoint: _endpointController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        deploymentName: _deploymentController.text.trim(),
        enableAI: _enableAI,
      );

      // Reload configuration to show updated status
      await _loadCurrentConfiguration();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration saved securely'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Clear form
      _clearForm();
    } catch (e) {
      _showErrorDialog('Failed to save configuration: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Clear all configuration (security response)
  Future<void> _clearConfiguration() async {
    final confirmed = await _showConfirmDialog(
      'Clear Configuration',
      'This will remove all stored API keys and disable AI features. This action cannot be undone. Continue?',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await SecureConfigService.clearConfiguration();
      await _loadCurrentConfiguration();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration cleared'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      _clearForm();
    } catch (e) {
      _showErrorDialog('Failed to clear configuration: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Clear form fields
  void _clearForm() {
    _endpointController.clear();
    _apiKeyController.clear();
    _deploymentController.clear();
    setState(() {
      _enableAI = false;
    });
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentConfiguration,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Security Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _secureStorageAvailable ? Icons.security : Icons.warning,
                          color: _secureStorageAvailable ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Secure Storage',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _secureStorageAvailable
                          ? 'Hardware-backed secure storage is available'
                          : 'Secure storage may not be hardware-backed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Current Configuration Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Configuration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildConfigurationStatus(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Configuration Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Configuration',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Enable AI Switch
                      SwitchListTile(
                        title: const Text('Enable AI Features'),
                        subtitle: const Text('Enable Azure OpenAI integration'),
                        value: _enableAI,
                        onChanged: (value) {
                          setState(() {
                            _enableAI = value;
                          });
                        },
                      ),
                      
                      if (_enableAI) ...[
                        const SizedBox(height: 16),
                        
                        // Azure Endpoint
                        TextFormField(
                          controller: _endpointController,
                          decoration: const InputDecoration(
                            labelText: 'Azure OpenAI Endpoint',
                            hintText: 'https://your-resource.openai.azure.com',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_enableAI && (value == null || value.isEmpty)) {
                              return 'Endpoint is required when AI is enabled';
                            }
                            if (value != null && value.isNotEmpty && !value.startsWith('https://')) {
                              return 'Endpoint must start with https://';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // API Key
                        TextFormField(
                          controller: _apiKeyController,
                          decoration: const InputDecoration(
                            labelText: 'API Key',
                            hintText: 'Your Azure OpenAI API key',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (_enableAI && (value == null || value.isEmpty)) {
                              return 'API Key is required when AI is enabled';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Deployment Name
                        TextFormField(
                          controller: _deploymentController,
                          decoration: const InputDecoration(
                            labelText: 'Deployment Name',
                            hintText: 'Your model deployment name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_enableAI && (value == null || value.isEmpty)) {
                              return 'Deployment name is required when AI is enabled';
                            }
                            return null;
                          },
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveConfiguration,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Save Configuration'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _clearConfiguration,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Clear All'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationStatus() {
    if (_currentConfig.isEmpty) {
      return const Text('No configuration loaded');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusRow('AI Enabled', _currentConfig['enableAI'] == 'true' ? 'Yes' : 'No'),
        _buildStatusRow('Endpoint', _currentConfig['endpoint'] ?? 'Not set'),
        _buildStatusRow('API Key', _currentConfig['apiKey'] ?? 'Not set'),
        _buildStatusRow('Deployment', _currentConfig['deploymentName'] ?? 'Not set'),
        _buildStatusRow('Version', _currentConfig['configVersion'] ?? 'Unknown'),
        const SizedBox(height: 8),
        Text(
          'Status: ${SecureConfigService.getStatus()}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: SecureConfigService.isAIEnabled ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
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
