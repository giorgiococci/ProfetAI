import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/ai_service_manager.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';
import '../l10n/prophet_localization_loader.dart';
import '../utils/utils.dart';

class AIStatusScreen extends StatefulWidget {
  const AIStatusScreen({super.key});

  @override
  State<AIStatusScreen> createState() => _AIStatusScreenState();
}

class _AIStatusScreenState extends State<AIStatusScreen> with LoadingStateMixin {
  bool _isAIEnabled = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _checkAIStatus();
    
    // Auto-refresh every 3 seconds when debug mode is on
    if (AppConfig.isDebugMode) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          setState(() {
            // This will rebuild the widget and refresh the logs
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAIStatus() async {
    await executeWithLoading(() async {
      final isInitialized = await AIServiceManager.initialize();
      
      setState(() {
        _isAIEnabled = AIServiceManager.isAIAvailable;
      });
      
      AppLogger.logInfo('AIStatusScreen', 'AI Status Check - Available: $_isAIEnabled, Initialized: $isInitialized');
    });
  }

  Future<void> _verifyProphetAssets() async {
    AppLogger.logInfo('AIStatusScreen', 'Starting prophet assets verification...');
    
    try {
      final allLoaded = await ProphetLocalizationLoader.verifyAssetsLoaded();
      
      if (mounted) {
        setState(() {}); // Refresh the logs display
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              allLoaded 
                  ? 'All prophet assets loaded successfully!' 
                  : 'Some prophet assets are missing - check logs for details'
            ),
            backgroundColor: allLoaded ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      AppLogger.logError('AIStatusScreen', 'Error during prophet assets verification', e);
      
      if (mounted) {
        setState(() {}); // Refresh the logs display
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error during verification - check logs for details'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'AI Status',
          style: ThemeUtils.headlineStyle,
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: ThemeUtils.getGradientDecoration(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F0F23)]
        ),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                  ),
                )
              : SingleChildScrollView(
                  padding: ThemeUtils.paddingMD,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      SizedBox(height: ThemeUtils.spacingLG),
                      _buildConfigurationCard(),
                      SizedBox(height: ThemeUtils.spacingLG),
                      // Always show debug card if there are logs or if debug mode is on
                      if (AppConfig.isDebugMode || AppLogger.getLogsAsString(lastN: 1).isNotEmpty) 
                        _buildDebugCard(),
                      SizedBox(height: ThemeUtils.spacingLG),
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
        padding: ThemeUtils.paddingMD,
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
                SizedBox(width: ThemeUtils.spacingXS),
                Text(
                  'AI Service Status',
                  style: ThemeUtils.titleStyle,
                ),
              ],
            ),
            SizedBox(height: ThemeUtils.spacingMD),
            Text(
              _isAIEnabled 
                  ? 'AI Service is operational and ready to provide responses'
                  : 'AI Service is not available. Check configuration.',
              style: ThemeUtils.bodyStyle.copyWith(
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
        padding: ThemeUtils.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration Status',
              style: ThemeUtils.subtitleStyle,
            ),
            SizedBox(height: ThemeUtils.spacingMD),
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
        padding: ThemeUtils.paddingMD,
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
            
            // AI Service Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Service Status:',
                    style: TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AIServiceManager.getDetailedStatus(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Runtime Logs
            Container(
              width: double.infinity,
              height: 400, // Increased from 200 to 400
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'All Runtime Logs:', // Changed from "Last 10" to "All"
                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 16),
                        onPressed: () => setState(() {}),
                        color: Colors.deepPurpleAccent,
                        tooltip: 'Refresh logs',
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          AppLogger.clear();
                          setState(() {});
                        },
                        color: Colors.redAccent,
                        tooltip: 'Clear logs',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: true, // Show newest logs at bottom
                      child: Text(
                        AppLogger.getLogsAsString().isEmpty // Removed lastN parameter to show all logs
                            ? 'No logs available. Try using the app to generate some logs.'
                            : AppLogger.getLogsAsString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11, // Slightly increased from 10 to 11
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
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
      padding: ThemeUtils.verticalPaddingSM,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ThemeUtils.bodyStyle.copyWith(color: Colors.white70),
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
              style: ThemeUtils.captionStyle.copyWith(
                color: isGood ? Colors.green[300] : Colors.orange[300],
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
            style: ThemeUtils.getPrimaryButtonStyle(),
          ),
        ),
        SizedBox(height: ThemeUtils.spacingSM),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _copyDebugInfo,
            icon: const Icon(Icons.copy),
            label: const Text('Copy Debug Info'),
            style: ThemeUtils.getSecondaryButtonStyle(),
          ),
        ),
        SizedBox(height: ThemeUtils.spacingXS),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              AppLogger.clear();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Runtime logs cleared'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Runtime Logs'),
            style: ThemeUtils.getSecondaryButtonStyle(),
          ),
        ),
        SizedBox(height: ThemeUtils.spacingXS),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _verifyProphetAssets,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Verify Prophet Assets'),
            style: ThemeUtils.getSecondaryButtonStyle(),
          ),
        ),
      ],
    );
  }

  Future<void> _copyDebugInfo() async {
    final debugInfo = '''
=== Orakl Debug Information ===
AI Available: ${AIServiceManager.isAIAvailable}
Build Config: ${AppConfig.isAIConfigured ? 'Configured' : 'Not Configured'}

${AppConfig.getDebugInfo()}

=== Detailed Status ===
${AIServiceManager.getDetailedStatus()}

=== Runtime Logs (Last 30 entries) ===
${AppLogger.getLogsAsString(lastN: 30)}

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
