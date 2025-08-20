import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../services/privacy_consent_service.dart';

/// Privacy Settings Screen
/// 
/// Allows users to view and modify their privacy consent preferences
/// and provides access to the privacy policy
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final PrivacyConsentService _privacyService = PrivacyConsentService();
  bool? _currentConsent;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadConsentStatus();
  }

  Future<void> _loadConsentStatus() async {
    try {
      await _privacyService.loadConsentStatus();
      setState(() {
        _currentConsent = _privacyService.consentGiven;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load privacy settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateConsent(bool newConsent) async {
    if (_currentConsent == newConsent) return;

    // If disabling personalization, show confirmation dialog
    if (!newConsent && _currentConsent == true) {
      final bool? shouldProceed = await _showDisableConfirmationDialog();
      if (shouldProceed != true) return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _privacyService.changeConsent(newConsent);
      setState(() {
        _currentConsent = newConsent;
        _isUpdating = false;
      });

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newConsent 
                ? localizations.personalizationEnabledSuccess
                : localizations.personalizationDisabledSuccess,
            ),
            backgroundColor: newConsent ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update privacy settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openPrivacyPolicy() async {
    const String privacyPolicyUrl = 'https://sites.google.com/view/orakl-privacy-policy';
    
    try {
      final Uri url = Uri.parse(privacyPolicyUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open privacy policy'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening privacy policy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showDisableConfirmationDialog() async {
    final localizations = AppLocalizations.of(context)!;
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A1810),
          title: Text(
            localizations.confirmDisablePersonalization,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            localizations.disablePersonalizationConfirmMessage,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                localizations.cancel,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.disable),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1B24),
        elevation: 0,
        title: Text(
          localizations.privacySettings,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1F1B24),
              Color(0xFF121212),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: _isLoading 
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            )
          : _buildContent(context, localizations),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current status card
          _buildStatusCard(localizations),
          
          const SizedBox(height: 24),
          
          // Information section
          _buildInformationSection(localizations),
          
          const SizedBox(height: 24),
          
          // Controls section
          _buildControlsSection(localizations),
          
          const SizedBox(height: 24),
          
          // Privacy policy section
          _buildPrivacyPolicySection(localizations),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations localizations) {
    final isEnabled = _currentConsent == true;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isEnabled ? Colors.green : Colors.grey).withValues(alpha: 0.1),
              (isEnabled ? Colors.green : Colors.grey).withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (isEnabled ? Colors.green : Colors.grey).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isEnabled ? Icons.shield_outlined : Icons.shield_outlined,
                color: isEnabled ? Colors.green : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.personalizationStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEnabled ? localizations.enabled : localizations.disabled,
                    style: TextStyle(
                      color: isEnabled ? Colors.green : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildInformationSection(AppLocalizations localizations) {
    final isEnabled = _currentConsent == true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.howItWorks,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1B24),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEnabled 
                  ? localizations.personalizationEnabledDescription
                  : localizations.personalizationDisabledDescription,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              if (isEnabled) ...[
                Text(
                  '• ${localizations.personalizationEnabledFeature1}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '• ${localizations.personalizationEnabledFeature2}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '• ${localizations.personalizationEnabledFeature3}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ] else ...[
                Text(
                  '• ${localizations.personalizationDisabledFeature1}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '• ${localizations.personalizationDisabledFeature2}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '• ${localizations.personalizationDisabledFeature3}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlsSection(AppLocalizations localizations) {
    final isEnabled = _currentConsent == true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.settings,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Enable/Disable personalization button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isUpdating ? null : () => _updateConsent(!isEnabled),
            icon: _isUpdating 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isEnabled ? Icons.toggle_off : Icons.toggle_on,
                  color: Colors.white,
                ),
            label: Text(
              _isUpdating
                ? localizations.updating
                : isEnabled 
                  ? localizations.disablePersonalization
                  : localizations.enablePersonalization,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled ? Colors.red : Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        if (isEnabled && !_isUpdating) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.disablePersonalizationWarning,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        if (!isEnabled && !_isUpdating) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.enablePersonalizationNote,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacyPolicySection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.privacyPolicy,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openPrivacyPolicy,
            icon: const Icon(
              Icons.open_in_new,
              color: Colors.deepPurpleAccent,
            ),
            label: Text(
              localizations.reviewPrivacyPolicy,
              style: const TextStyle(
                color: Colors.deepPurpleAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurpleAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
