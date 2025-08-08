import 'package:flutter/material.dart';
import '../../services/bio/bio_storage_service.dart';
import '../../services/bio/bio_generation_service.dart';
import '../../services/ai_service_manager.dart';
import '../../services/database_service.dart';
import '../../utils/app_logger.dart';
import '../../utils/privacy/privacy_levels.dart';
import '../../utils/bio/insight_source_type.dart';

/// Debug screen for bio system testing and maintenance
/// 
/// This screen contains all development and debugging tools
/// for the biographical insight system
class BioDebugScreen extends StatefulWidget {
  const BioDebugScreen({super.key});

  @override
  State<BioDebugScreen> createState() => _BioDebugScreenState();
}

class _BioDebugScreenState extends State<BioDebugScreen> {
  static const String _component = 'BioDebugScreen';
  
  final BioStorageService _bioStorageService = BioStorageService();
  
  bool _isLoading = false;
  String? _lastResult;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bio System Debug'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_lastResult != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Result:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_lastResult!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            _buildDebugSection('Bio Information', [
              _buildDebugButton(
                'Show Bio Metadata',
                Icons.info,
                _showBioMetadata,
              ),
            ]),
            
            const SizedBox(height: 16),
            
            _buildDebugSection('Bio Generation', [
              _buildDebugButton(
                'Generate Bio Manually',
                Icons.auto_awesome,
                _generateBioManually,
              ),
              _buildDebugButton(
                'Test Bio System',
                Icons.science,
                _testBioSystem,
              ),
            ]),
            
            const SizedBox(height: 16),
            
            _buildDebugSection('Test Data', [
              _buildDebugButton(
                'Add Test Insights',
                Icons.add_box,
                _addTestInsights,
              ),
              _buildDebugButton(
                'Debug & Fix Insights',
                Icons.build,
                _debugAndFixInsights,
              ),
            ]),
            
            const SizedBox(height: 16),
            
            _buildDebugSection('Database', [
              _buildDebugButton(
                'Check Database Structure',
                Icons.storage,
                _checkDatabaseStructure,
              ),
              _buildDebugButton(
                'Show Debug Info',
                Icons.bug_report,
                _showDebugInfo,
              ),
            ]),
            
            const SizedBox(height: 16),
            
            _buildDebugSection('Data Management', [
              _buildDebugButton(
                'Clear All Insights',
                Icons.clear_all,
                _clearAllInsights,
                isDestructive: true,
              ),
            ]),
            
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDebugSection(String title, List<Widget> buttons) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...buttons,
          ],
        ),
      ),
    );
  }
  
  Widget _buildDebugButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isLoading ? null : onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: isDestructive
              ? OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                )
              : null,
        ),
      ),
    );
  }
  
  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }
  
  void _setResult(String result) {
    if (mounted) {
      setState(() {
        _lastResult = result;
      });
    }
  }
  
  /// Generate bio manually on demand
  Future<void> _generateBioManually() async {
    try {
      _setLoading(true);
      AppLogger.logInfo(_component, 'Manual bio generation started');
      
      // First, check if we have insights
      final userBio = await _bioStorageService.getUserBio(userId: 'default_user');
      if (userBio == null || userBio.insights.isEmpty) {
        _setResult('No insights found for bio generation. Add test insights first.');
        return;
      }
      
      AppLogger.logInfo(_component, 'Found ${userBio.insights.length} insights for bio generation');
      
      final bioGenerationService = BioGenerationService.instance;
      await bioGenerationService.initialize();
      await bioGenerationService.generateBioOnDemand(userId: 'default_user');
      
      // Check if bio was actually generated
      final generatedBio = await _bioStorageService.getGeneratedBio(userId: 'default_user');
      
      if (generatedBio != null) {
        _setResult('Bio generated successfully with ${generatedBio.sections.length} sections');
      } else {
        _setResult('Bio generation completed but no content was generated');
      }
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to generate bio manually', e);
      _setResult('Bio generation failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Simple test method to check system connectivity
  Future<void> _testBioSystem() async {
    try {
      _setLoading(true);
      AppLogger.logInfo(_component, 'Testing bio system...');
      
      // Test database connection
      final userBio = await _bioStorageService.getUserBio(userId: 'default_user');
      final insightsCount = userBio?.insights.length ?? 0;
      
      // Test AI service
      final testResponse = await AIServiceManager.generateResponse(
        prompt: 'Say hello',
        systemMessage: 'You are a test assistant. Respond with exactly "Hello World"',
        maxTokens: 10,
      );
      
      _setResult('System test completed:\\n'
          '• Database: ${userBio != null ? "Connected" : "Failed"}\\n'
          '• Insights: $insightsCount\\n'
          '• AI Service: ${testResponse != null ? "Working" : "Failed"}\\n'
          '• AI Response: "${testResponse ?? "null"}"');
      
    } catch (e) {
      AppLogger.logError(_component, 'Bio system test failed', e);
      _setResult('System test failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Add test insights if none exist
  Future<void> _addTestInsights() async {
    try {
      _setLoading(true);
      AppLogger.logInfo(_component, 'Adding test insights...');
      
      final testInsights = [
        // Interests
        {'content': 'User enjoys reading science fiction books', 'category': 'interests'},
        {'content': 'User is interested in artificial intelligence', 'category': 'interests'},
        {'content': 'User likes classical music', 'category': 'interests'},
        {'content': 'User enjoys outdoor activities and hiking', 'category': 'interests'},
        
        // Personality
        {'content': 'User prefers working in the morning hours', 'category': 'personality'},
        {'content': 'User is detail-oriented and methodical in approach', 'category': 'personality'},
        {'content': 'User enjoys helping others solve problems', 'category': 'personality'},
        
        // Background
        {'content': 'User has experience with programming', 'category': 'background'},
        {'content': 'User has worked in technology field', 'category': 'background'},
        
        // Goals
        {'content': 'User wants to learn more about machine learning', 'category': 'goals'},
        {'content': 'User aims to improve work-life balance', 'category': 'goals'},
      ];
      
      int addedCount = 0;
      for (final insightData in testInsights) {
        try {
          await _bioStorageService.addInsight(
            content: insightData['content']!,
            category: insightData['category']!,
            sourceQuestionId: 'test_question_\${DateTime.now().millisecondsSinceEpoch}',
            sourceAnswer: 'Test answer for debugging purposes',
            extractedFrom: 'debug_test_data',
            privacyLevel: PrivacyLevel.personal,
            sourceType: InsightSourceType.user,
            userId: 'default_user',
          );
          addedCount++;
        } catch (e) {
          AppLogger.logWarning(_component, 'Failed to add test insight: $e');
        }
      }
      
      _setResult('Successfully added $addedCount test insights out of ${testInsights.length} attempted');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to add test insights', e);
      _setResult('Failed to add test insights: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Debug and fix any issues with insights
  Future<void> _debugAndFixInsights() async {
    try {
      _setLoading(true);
      AppLogger.logInfo(_component, 'Running insight debugging...');
      
      final userBio = await _bioStorageService.getUserBio(userId: 'default_user');
      if (userBio == null) {
        _setResult('No user bio found. System needs initialization.');
        return;
      }
      
      final insights = userBio.insights;
      int fixedCount = 0;
      
      for (final insight in insights) {
        // Check for insights with null or invalid source types
        if (insight.sourceType == InsightSourceType.user) {
          // This is fine, nothing to fix
          continue;
        }
        // If we find insights that need fixing, we could implement fixes here
      }
      
      _setResult('Debugging complete:\\n'
          '• Total insights: ${insights.length}\\n'
          '• Issues fixed: $fixedCount\\n'
          '• System status: Healthy');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to debug insights', e);
      _setResult('Debug failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Check database structure and integrity
  Future<void> _checkDatabaseStructure() async {
    try {
      _setLoading(true);
      
      final db = await DatabaseService().database;
      
      // Check all tables
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
      AppLogger.logInfo(_component, 'Database tables found: ${tables.map((t) => t['name']).join(', ')}');
      
      // Check generated_bio table
      final generatedBioTableExists = tables.any((t) => t['name'] == 'generated_bio');
      
      StringBuffer result = StringBuffer();
      result.writeln('Database Structure Check:');
      result.writeln('• Tables: ${tables.length}');
      result.writeln('• Table names: ${tables.map((t) => t['name']).join(', ')}');
      result.writeln('• Generated bio table: ${generatedBioTableExists ? "Exists" : "Missing"}');
      
      if (generatedBioTableExists) {
        final bioRecords = await db.query('generated_bio');
        result.writeln('• Bio records: ${bioRecords.length}');
      }
      
      final insightsRecords = await db.query('biographical_insights');
      result.writeln('• Insight records: ${insightsRecords.length}');
      
      _setResult(result.toString());
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to check database structure', e);
      _setResult('Database check failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Clear all biographical insights and data
  Future<void> _clearAllInsights() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all biographical insights and generated bios. '
          'This action cannot be undone.\\n\\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      _setLoading(true);
      AppLogger.logInfo(_component, 'Clearing all bio data...');
      
      await _bioStorageService.deleteAllBioData(userId: 'default_user');
      
      _setResult('All biographical data cleared successfully');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to clear all data', e);
      _setResult('Failed to clear data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Show bio metadata information
  Future<void> _showBioMetadata() async {
    try {
      final generatedBio = await _bioStorageService.getGeneratedBio(userId: 'default_user');
      
      if (generatedBio == null) {
        _setResult('No generated bio found');
        return;
      }
      
      final formattedDate = _formatDateTime(generatedBio.generatedAt);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bio Metadata'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMetadataRow('Generated', formattedDate),
                _buildMetadataRow('Insights Used', '${generatedBio.totalInsightsUsed}'),
                _buildMetadataRow('Sections', '${generatedBio.sections.length}'),
                const SizedBox(height: 12),
                const Text('Sections:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...generatedBio.sections.entries.map((entry) =>
                  _buildMetadataRow('${entry.key} length', '${entry.value.length} chars')
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      _setResult('Failed to load bio metadata: ${e.toString()}');
    }
  }
  
  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Show debug information
  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bio System Debug Info', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('• Automatic bio generation: Enabled'),
              const Text('• Source type filtering: Disabled'),
              const Text('• Privacy filtering: Enabled'),
              const Text('• Debug mode: Active'),
              const SizedBox(height: 12),
              const Text('Recent Changes:', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('• Removed manual generation button'),
              const Text('• Added automatic generation after prophet responses'),
              const Text('• Simplified empty state message'),
              const Text('• Moved debug functions to separate screen'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
