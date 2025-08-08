import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/bio/generated_bio.dart';
import '../../services/bio/bio_storage_service.dart';
import '../../widgets/home/error_display_widget.dart';
import '../../utils/app_logger.dart';
import 'bio_debug_screen.dart';

/// Simplified biographical profile screen
/// 
/// Shows AI-generated biographical narrative to users
/// Bio generation happens automatically after prophet interactions
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
      
      setState(() {
        _generatedBio = bio;
        _isLoading = false;
      });
      
      if (bio != null) {
        AppLogger.logInfo(_component, 'Bio profile loaded successfully');
      } else {
        AppLogger.logInfo(_component, 'No generated bio found');
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
          // Debug screen accessible in debug mode
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BioDebugScreen()),
              ),
              tooltip: 'Debug Tools',
            ),
          // Data deletion option
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
            // Removed metadata card - moved to debug screen
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
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
              'No bio still available. The prophets need more information.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.chat),
              label: const Text('Ask the Prophets'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.person,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generated from your prophet interactions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    if (_generatedBio?.sections.isEmpty ?? true) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No biographical content available'),
        ),
      );
    }
    
    return Column(
      children: _generatedBio!.sections.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Changed to black for better readability
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
}
