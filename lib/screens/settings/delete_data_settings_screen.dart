import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/vision_storage_service.dart';
import '../../utils/utils.dart';

class DeleteDataSettingsScreen extends StatefulWidget {
  const DeleteDataSettingsScreen({super.key});

  @override
  State<DeleteDataSettingsScreen> createState() => _DeleteDataSettingsScreenState();
}

class _DeleteDataSettingsScreenState extends State<DeleteDataSettingsScreen> 
    with LoadingStateMixin {
  final VisionStorageService _visionStorageService = VisionStorageService();

  /// Delete all stored visions with confirmation
  Future<void> _deleteAllVisions() async {
    final localizations = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteAllVisionsConfirmTitle),
        content: Text(localizations.deleteAllVisionsWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 16),
                  Text('Deleting all visions...'),
                ],
              ),
              duration: Duration(seconds: 10),
            ),
          );
        }

        // Delete all visions
        final success = await _visionStorageService.deleteAllVisions();
        
        if (mounted) {
          // Hide loading snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.allVisionsDeleted),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.failedToDeleteVisions),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations.failedToDeleteVisions} Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.deleteDataPageTitle),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Critical Actions Section
          _buildSectionCard(
            title: localizations.criticalActions,
            children: [
              _buildDeleteAllVisionsField(localizations),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.redAccent.withValues(alpha: 0.1),
              Colors.redAccent.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAllVisionsField(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(
              localizations.deleteAllVisions,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _deleteAllVisions,
            icon: const Icon(Icons.delete_forever),
            label: Text(localizations.deleteAllVisions),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '⚠️ This action cannot be undone',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
