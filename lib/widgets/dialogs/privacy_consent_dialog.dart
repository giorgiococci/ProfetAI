import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';

/// Privacy consent dialog that appears at the end of onboarding
/// 
/// This dialog is mandatory and allows users to control whether their
/// personalization data is stored and used for prophet responses.
class PrivacyConsentDialog extends StatelessWidget {
  final Function(bool) onConsentResult;

  const PrivacyConsentDialog({
    super.key,
    required this.onConsentResult,
  });

  /// Shows the privacy consent dialog
  /// 
  /// Returns a Future<bool> that completes when the user makes a choice:
  /// - true: User accepted personalization
  /// - false: User declined personalization
  static Future<bool> show(BuildContext context) async {
    bool? result;
    
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // User cannot dismiss by tapping outside
      builder: (BuildContext dialogContext) {
        return PrivacyConsentDialog(
          onConsentResult: (bool consent) {
            result = consent;
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
    
    // Return the result, defaulting to false if somehow null
    return result ?? false;
  }

  /// Opens the privacy policy URL in the device's default browser
  Future<void> _openPrivacyPolicy() async {
    const String privacyPolicyUrl = 'https://sites.google.com/view/orakl-privacy-policy';
    
    try {
      final Uri url = Uri.parse(privacyPolicyUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // If we can't launch the URL, we could show an error or copy to clipboard
        debugPrint('Could not launch privacy policy URL: $privacyPolicyUrl');
      }
    } catch (e) {
      debugPrint('Error launching privacy policy URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return PopScope(
      canPop: false, // Prevent back button from dismissing
      child: AlertDialog(
        backgroundColor: const Color(0xFF1F1B24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          localizations.privacyConsentTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.privacyConsentMessage,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Privacy Policy Button
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
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurpleAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Action buttons in a column for better mobile layout
          Column(
            children: [
              // Enable Personalization Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => onConsentResult(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    localizations.enablePersonalization,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Disable Personalization Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => onConsentResult(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    localizations.disablePersonalization,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
