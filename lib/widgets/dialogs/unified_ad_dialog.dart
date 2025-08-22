import 'package:flutter/material.dart';
import '../../utils/theme_utils.dart';
import '../../l10n/app_localizations.dart';

/// Unified dialog for handling ad display with cooldown information
/// 
/// Shows user their question progress and gives options to either watch an ad
/// or skip and wait for the cooldown period
class UnifiedAdDialog extends StatelessWidget {
  final int questionsAsked;
  final int adFrequency;
  final Future<bool> Function() onShowAd;
  final Duration? remainingCooldownTime;
  final bool isInCooldown;
  
  const UnifiedAdDialog({
    super.key,
    required this.questionsAsked,
    required this.adFrequency,
    required this.onShowAd,
    this.remainingCooldownTime,
    this.isInCooldown = false,
  });
  
  /// Show the unified ad dialog
  /// 
  /// Returns true if user watched the ad completely, false if skipped
  static Future<bool?> show({
    required BuildContext context,
    required int questionsAsked,
    required int adFrequency,
    required Future<bool> Function() onShowAd,
    Duration? remainingCooldownTime,
    bool isInCooldown = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (context) => UnifiedAdDialog(
        questionsAsked: questionsAsked,
        adFrequency: adFrequency,
        onShowAd: onShowAd,
        remainingCooldownTime: remainingCooldownTime,
        isInCooldown: isInCooldown,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button
      child: AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              isInCooldown ? Icons.access_time : Icons.play_circle_filled,
              color: isInCooldown ? Colors.orange : ThemeUtils.primaryBlue,
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isInCooldown 
                    ? AppLocalizations.of(context)!.waitTimeActive 
                    : AppLocalizations.of(context)!.watchAdTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isInCooldown ? Colors.orange : ThemeUtils.primaryBlue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isInCooldown ? Colors.orange : ThemeUtils.primaryBlue).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isInCooldown ? Icons.hourglass_empty : Icons.celebration,
                    color: isInCooldown ? Colors.orange : Colors.amber,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMainMessage(context),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getSubMessage(context),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (!isInCooldown) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.aboutThirtySeconds,
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.free_breakfast,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.freeToUse,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          // Skip button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white54,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              isInCooldown 
                  ? AppLocalizations.of(context)!.waitButton 
                  : AppLocalizations.of(context)!.skipButton,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Watch Ad button
          ElevatedButton(
            onPressed: () async {
              // Show loading and handle ad
              await _handleAdDisplay(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isInCooldown ? Colors.orange : ThemeUtils.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow, size: 18),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.watchAdButton,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getMainMessage(BuildContext context) {
    if (isInCooldown) {
      return AppLocalizations.of(context)!.youSkippedAdEarlier;
    } else {
      return questionsAsked == 1 
          ? AppLocalizations.of(context)!.youAskedOneQuestion
          : AppLocalizations.of(context)!.youAskedMultipleQuestions(questionsAsked);
    }
  }
  
  String _getSubMessage(BuildContext context) {
    if (isInCooldown) {
      final timeString = _formatDuration(remainingCooldownTime!);
      return AppLocalizations.of(context)!.waitOrWatchAdMessage(timeString);
    } else {
      return AppLocalizations.of(context)!.unlimitedOracleWisdomMessage;
    }
  }
  
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    final seconds = (duration.inSeconds % 60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  /// Handle the ad display process with loading state
  Future<void> _handleAdDisplay(BuildContext context) async {
    try {
      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const _AdLoadingDialog(),
        );
      }
      
      // Wait a moment for loading dialog to appear
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Show the actual ad
      final bool adCompleted = await onShowAd();
      
      // Close loading dialog
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Close main dialog with result
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(adCompleted);
      }
      
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Close main dialog with false result
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(false);
      }
    }
  }
}

/// Loading dialog shown while ad is being prepared
class _AdLoadingDialog extends StatelessWidget {
  const _AdLoadingDialog();
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.preparingAd,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
