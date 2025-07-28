import 'package:flutter/material.dart';
import '../../models/vision_feedback.dart';

/// Utility class for showing notifications and snackbars with consistent styling
/// Provides themed notifications for different types of messages
class NotificationUtils {
  
  /// Shows a success snackbar with green styling
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.check_circle,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.green[700]!,
      icon: icon,
      duration: duration,
    );
  }

  /// Shows an error snackbar with red styling
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.error,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.red[700]!,
      icon: icon,
      duration: duration,
    );
  }

  /// Shows an info snackbar with blue styling
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.info,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.blue[700]!,
      icon: icon,
      duration: duration,
    );
  }

  /// Shows a warning snackbar with orange styling
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.warning,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.orange[700]!,
      icon: icon,
      duration: duration,
    );
  }

  /// Shows a prophet-themed notification with custom colors
  static void showProphetNotification({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
    );
  }

  /// Shows a save confirmation snackbar
  static void showSaveConfirmation({
    required BuildContext context,
    required Color prophetColor,
    String message = 'Visione salvata nel Libro delle Visioni',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bookmark_added, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: prophetColor.withValues(alpha: 0.9),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Shows a share confirmation snackbar
  static void showShareConfirmation({
    required BuildContext context,
    required Color prophetColor,
    String message = 'Preparando la condivisione della visione...',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: prophetColor.withValues(alpha: 0.9),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Shows feedback confirmation snackbar with vision feedback details
  static void showFeedbackConfirmation({
    required BuildContext context,
    required VisionFeedback feedback,
    required Color prophetColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              feedback.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    feedback.action,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    feedback.thematicText,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: prophetColor.withValues(alpha: 0.9),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Private helper method to show basic snackbars
  static void _showSnackBar({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Dismisses any currently showing snackbar
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Shows a loading snackbar (useful for quick operations)
  static void showLoading({
    required BuildContext context,
    String message = 'Loading...',
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.grey[800]!,
        duration: const Duration(seconds: 30), // Long duration for loading
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
