import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/bio/generated_bio.dart';
import '../../services/bio/bio_storage_service.dart';
import '../../services/bio/bio_generation_service.dart';
import '../../services/ai_service_manager.dart';
import '../../services/database_service.dart';
import '../../widgets/home/error_display_widget.dart';
import '../../utils/app_logger.dart';
import '../../utils/privacy/privacy_levels.dart';

/// Simplified biographical profile screen
/// 
/// Shows AI-generated biographical narrative to users
/// Debug mode shows raw insights for development
class BioProfileScreen extends StatefulWidget {
  const BioProfileScreen({super.key});

  @override
  State<BioProfileScreen> createState() => _BioProfileScreenState();
}

class _BioProfileScreenState extends State<BioProfileScreen> {
  static const String _component = 'BioProfileScreen';
  
  final BioStorageService _bioStorageService = BioStorageService();
  
  GeneratedBio? _generatedBio;
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadBioProfile();
  }
  
  /// Load the user's generated biographical profile
  Future<void> _loadBioProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      AppLogger.logInfo(_component, 'Loading user bio profile...');
      
      final bio = await _bioStorageService.getGeneratedBio(userId: 'default_user');
      
      // If no bio exists, try to generate one if there are insights
      if (bio == null) {
        AppLogger.logInfo(_component, 'No generated bio found, checking for insights to generate bio...');
        final userBio = await _bioStorageService.getUserBio(userId: 'default_user');
        
        if (userBio != null && userBio.insights.isNotEmpty) {
          AppLogger.logInfo(_component, 'Found ${userBio.insights.length} insights, triggering bio generation...');
          
          // Trigger bio generation on demand
          final bioGenerationService = BioGenerationService.instance;
          await bioGenerationService.initialize();
          await bioGenerationService.generateBioOnDemand(userId: 'default_user');
          
          // Try to load the bio again after generation
          final generatedBio = await _bioStorageService.getGeneratedBio(userId: 'default_user');
          
          setState(() {
            _generatedBio = generatedBio;
            _isLoading = false;
          });
          
          if (generatedBio != null) {
            AppLogger.logInfo(_component, 'Bio generated and loaded successfully');
          } else {
            AppLogger.logWarning(_component, 'Bio generation completed but no bio was created');
          }
        } else {
          setState(() {
            _generatedBio = null;
            _isLoading = false;
          });
          AppLogger.logInfo(_component, 'No insights available for bio generation');
        }
      } else {
        setState(() {
          _generatedBio = bio;
          _isLoading = false;
        });
        AppLogger.logInfo(_component, 'Bio profile loaded successfully');
      }
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to load bio profile', e);
      setState(() {
        _error = 'Failed to load biographical profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  /// Delete all biographical data
  Future<void> _deleteAllBioData() async {
    try {
      AppLogger.logInfo(_component, 'Deleting all bio data...');
      
      await _bioStorageService.deleteAllBioData(userId: 'default_user');
      
      setState(() {
        _generatedBio = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All biographical data deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      AppLogger.logInfo(_component, 'Bio data deletion completed');
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to delete bio data', e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generate bio manually on demand
  Future<void> _generateBioManually() async {
    try {
      print('DEBUG: Manual bio generation started');
      AppLogger.logInfo(_component, 'Manual bio generation started');
      
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('DEBUG: Checking insights availability...');
      AppLogger.logInfo(_component, 'Checking insights availability...');
      
      // First, check if we have insights
      final userBio = await _bioStorageService.getUserBio(userId: 'default_user');
      if (userBio == null || userBio.insights.isEmpty) {
        print('DEBUG: No insights found for bio generation');
        AppLogger.logWarning(_component, 'No insights found for bio generation');
        setState(() {
          _error = 'No biographical insights available. Please interact with prophets first to collect insights.';
          _isLoading = false;
        });
        return;
      }
      
      print('DEBUG: Found ${userBio.insights.length} insights');
      AppLogger.logInfo(_component, 'Found ${userBio.insights.length} insights for bio generation');
      
      print('DEBUG: Initializing bio generation service...');
      AppLogger.logInfo(_component, 'Initializing bio generation service...');
      
      final bioGenerationService = BioGenerationService.instance;
      await bioGenerationService.initialize();
      
      print('DEBUG: Calling generateBioOnDemand...');
      AppLogger.logInfo(_component, 'Calling generateBioOnDemand...');
      
      await bioGenerationService.generateBioOnDemand(userId: 'default_user');
      
      print('DEBUG: Bio generation completed, reloading profile...');
      AppLogger.logInfo(_component, 'Bio generation completed, reloading profile...');
      
      // Reload the bio after generation
      await _loadBioProfile();
      
      // Check if bio was actually generated and show it in alert
      final generatedBio = await _bioStorageService.getGeneratedBio(userId: 'default_user');
      print('DEBUG: Retrieved bio for alert: ${generatedBio != null ? 'Found bio with ${generatedBio.sections.length} sections' : 'No bio found'}');
      
      print('DEBUG: Bio generation process finished');
      
      if (mounted) {
        if (generatedBio != null && generatedBio.sections.isNotEmpty) {
          // Show the bio in an alert dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Generated Bio'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: generatedBio.sections.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biographical profile generated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('DEBUG: Bio generation completed but no bio content was found');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Bio Generation Result'),
                content: const Text('Bio generation completed but no content was generated. This could be due to:\n\n• AI service connectivity issues\n• Insufficient insights for bio generation\n• Bio storage problems\n\nCheck the logs for more details.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
          setState(() {
            _error = 'Bio generation completed but no content was generated. Please check logs.';
            _isLoading = false;
          });
        }
      }
      
    } catch (e) {
      print('DEBUG: Bio generation failed with error: $e');
      AppLogger.logError(_component, 'Failed to generate bio manually', e);
      setState(() {
        _error = 'Failed to generate bio: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  /// Show confirmation dialog for data deletion
  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Biographical Data'),
        content: const Text(
          'This will permanently delete all your biographical information. '
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
            child: const Text('Delete All Data'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _deleteAllBioData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _generateBioManually,
            tooltip: 'Generate Bio',
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.science),
              onPressed: _testBioSystem,
              tooltip: 'Test System',
            ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: _addTestInsights,
              tooltip: 'Add Test Insights',
            ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.storage),
              onPressed: _checkDatabaseStructure,
              tooltip: 'Check Database',
            ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllInsights,
              tooltip: 'Clear All Data',
            ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: _showDebugInfo,
              tooltip: 'Debug Info',
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _generatedBio != null ? _showDeleteConfirmation : null,
            tooltip: 'Delete All Data',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your profile...'),
          ],
        ),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ErrorDisplayWidget(errorMessage: _error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadBioProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_generatedBio == null) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: _loadBioProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildBioSections(),
            const SizedBox(height: 32),
            _buildMetadataCard(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return FutureBuilder<bool>(
      future: _checkIfInsightsExist(),
      builder: (context, snapshot) {
        final hasInsights = snapshot.data ?? false;
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Profile Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasInsights 
                    ? 'You have ${hasInsights ? 'collected' : 'no'} biographical insights. Generate your profile to see them organized.'
                    : 'Your biographical profile will appear here after you interact with the prophets.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                if (hasInsights) ...[
                  FilledButton.icon(
                    onPressed: _generateBioManually,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Profile'),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chat),
                  label: const Text('Start Conversation'),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  /// Check if the user has any insights available for bio generation
  Future<bool> _checkIfInsightsExist() async {
    try {
      final userBio = await _bioStorageService.getUserBio(userId: 'default_user');
      final hasInsights = userBio != null && userBio.insights.isNotEmpty;
      print('DEBUG: Checking insights - Found ${userBio?.insights.length ?? 0} insights');
      return hasInsights;
    } catch (e) {
      print('DEBUG: Error checking insights: $e');
      AppLogger.logError(_component, 'Failed to check insights existence', e);
      return false;
    }
  }

  /// Simple test method to check system connectivity
  Future<void> _testBioSystem() async {
    try {
      print('DEBUG: Testing bio system...');
      
      // Test database connection
      final userBio = await _bioStorageService.getUserBio(userId: 'default_user');
      print('DEBUG: UserBio found: ${userBio != null}');
      print('DEBUG: Insights count: ${userBio?.insights.length ?? 0}');
      
      // Test AI service
      print('DEBUG: Testing AI service...');
      final testResponse = await AIServiceManager.generateResponse(
        prompt: 'Say hello',
        systemMessage: 'You are a test assistant. Respond with exactly "Hello World"',
        maxTokens: 10,
      );
      print('DEBUG: AI Service response: $testResponse');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('System test completed. AI response: ${testResponse ?? "null"}'),
            backgroundColor: testResponse != null ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      print('DEBUG: Bio system test failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('System test failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Add test insights if none exist
  Future<void> _addTestInsights() async {
    try {
      print('DEBUG: Adding test insights...');
      
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
      
      for (final insightData in testInsights) {
        await _bioStorageService.addInsight(
          content: insightData['content']!,
          category: insightData['category']!,
          sourceQuestionId: 'test_question',
          sourceAnswer: 'Test answer for insights',
          extractedFrom: 'Test data generation',
          privacyLevel: PrivacyLevel.personal,
        );
        print('DEBUG: Added insight: ${insightData['content']} (${insightData['category']})');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test insights added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      print('DEBUG: Failed to add test insights: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add test insights: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Check database tables and structure
  Future<void> _checkDatabaseStructure() async {
    try {
      print('DEBUG: Checking database structure...');
      AppLogger.logInfo(_component, 'Checking database structure...');
      
      // Get database service
      final databaseService = DatabaseService();
      final db = await databaseService.database;
      
      // Check all tables
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
      print('DEBUG: Database tables found: ${tables.map((t) => t['name']).join(', ')}');
      AppLogger.logInfo(_component, 'Database tables found: ${tables.map((t) => t['name']).join(', ')}');
      
      // Check generated_bio table specifically
      final generatedBioTableExists = tables.any((t) => t['name'] == 'generated_bio');
      print('DEBUG: generated_bio table exists: $generatedBioTableExists');
      AppLogger.logInfo(_component, 'generated_bio table exists: $generatedBioTableExists');
      
      if (generatedBioTableExists) {
        // Check if there are any records in generated_bio
        final bioRecords = await db.query('generated_bio');
        print('DEBUG: Records in generated_bio table: ${bioRecords.length}');
        AppLogger.logInfo(_component, 'Records in generated_bio table: ${bioRecords.length}');
        
        for (int i = 0; i < bioRecords.length; i++) {
          final record = bioRecords[i];
          print('DEBUG: Bio record $i: ${record.keys.join(', ')}');
          print('DEBUG: Bio record $i user_id: ${record['user_id']}');
          print('DEBUG: Bio record $i sections length: ${record['sections']?.toString().length ?? 'null'}');
          AppLogger.logInfo(_component, 'Bio record $i: user_id=${record['user_id']}, sections_length=${record['sections']?.toString().length ?? 'null'}');
        }
      }
      
      // Check biographical_insights table
      final insightsRecords = await db.query('biographical_insights');
      print('DEBUG: Records in biographical_insights table: ${insightsRecords.length}');
      AppLogger.logInfo(_component, 'Records in biographical_insights table: ${insightsRecords.length}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database check complete - see debug output'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
    } catch (e) {
      print('DEBUG: Failed to check database structure: $e');
      AppLogger.logError(_component, 'Failed to check database structure', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database check failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Clear all insights for testing
  Future<void> _clearAllInsights() async {
    try {
      print('DEBUG: Clearing all insights and bios...');
      AppLogger.logInfo(_component, 'Clearing all insights and bios...');
      
      // Get database service
      final databaseService = DatabaseService();
      final db = await databaseService.database;
      
      // Clear insights
      await db.delete('biographical_insights');
      print('DEBUG: Cleared biographical_insights table');
      
      // Clear generated bios
      await db.delete('generated_bio');
      print('DEBUG: Cleared generated_bio table');
      
      // Clear user_bio
      await db.delete('user_bio');
      print('DEBUG: Cleared user_bio table');
      
      // Reload the profile
      await _loadBioProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All insights and bios cleared successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
    } catch (e) {
      print('DEBUG: Failed to clear insights: $e');
      AppLogger.logError(_component, 'Failed to clear insights', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear insights: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Biographical Profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generated from ${_generatedBio!.totalInsightsUsed} insights',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
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
  
  Widget _buildBioSections() {
    final sections = _generatedBio!.sections;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Summary',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...sections.entries
            .where((entry) => entry.value != 'No specific information available')
            .map((entry) => _buildSectionCard(entry.key, entry.value)),
      ],
    );
  }
  
  Widget _buildSectionCard(String sectionKey, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getSectionIcon(sectionKey),
                const SizedBox(width: 8),
                Text(
                  _getSectionTitle(sectionKey),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _getSectionIcon(String sectionKey) {
    switch (sectionKey.toLowerCase()) {
      case 'interests':
        return const Icon(Icons.interests, size: 20);
      case 'personality':
        return const Icon(Icons.psychology, size: 20);
      case 'background':
        return const Icon(Icons.school, size: 20);
      case 'goals':
        return const Icon(Icons.flag, size: 20);
      case 'preferences':
        return const Icon(Icons.tune, size: 20);
      default:
        return const Icon(Icons.info_outline, size: 20);
    }
  }
  
  String _getSectionTitle(String sectionKey) {
    switch (sectionKey.toLowerCase()) {
      case 'interests':
        return 'Interests & Hobbies';
      case 'personality':
        return 'Personality Traits';
      case 'background':
        return 'Background';
      case 'goals':
        return 'Goals & Aspirations';
      case 'preferences':
        return 'Preferences';
      default:
        return sectionKey.toUpperCase();
    }
  }
  
  Widget _buildMetadataCard() {
    final bio = _generatedBio!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Information',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetadataRow('Generated', _formatDateTime(bio.generatedAt)),
            _buildMetadataRow('Last Used', bio.lastUsedAt != null 
                ? _formatDateTime(bio.lastUsedAt!) 
                : 'Never'),
            _buildMetadataRow('Confidence', '${(bio.confidenceScore * 100).toInt()}%'),
            _buildMetadataRow('Data Points', '${bio.totalInsightsUsed} insights'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Show debug information (only in debug mode)
  void _showDebugInfo() {
    if (!kDebugMode) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bio ID: ${_generatedBio?.id ?? 'N/A'}'),
              Text('User ID: ${_generatedBio?.userId ?? 'N/A'}'),
              Text('Sections: ${_generatedBio?.sections.length ?? 0}'),
              Text('Total Insights: ${_generatedBio?.totalInsightsUsed ?? 0}'),
              Text('Confidence: ${(_generatedBio?.confidenceScore ?? 0) * 100}%'),
              const SizedBox(height: 16),
              const Text('Available Actions:'),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // TODO: Show raw insights in debug mode
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Raw insights view not implemented yet')),
                  );
                },
                child: const Text('View Raw Insights'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
