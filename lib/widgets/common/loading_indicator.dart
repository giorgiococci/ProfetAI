import 'package:flutter/material.dart';

/// A reusable loading indicator widget with customizable styling
/// and optional message display.
class LoadingIndicator extends StatelessWidget {
  final Color primaryColor;
  final String? message;
  final double size;
  final TextStyle? messageStyle;
  final double spacing;

  const LoadingIndicator({
    super.key,
    required this.primaryColor,
    this.message,
    this.size = 40,
    this.messageStyle,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            strokeWidth: 3,
          ),
        ),
        if (message != null) ...[
          SizedBox(height: spacing),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: messageStyle ??
                TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                ),
          ),
        ],
      ],
    );
  }
}

/// A dialog that shows a loading indicator with a message
class LoadingDialog extends StatelessWidget {
  final Color primaryColor;
  final String message;
  final bool isDismissible;

  const LoadingDialog({
    super.key,
    required this.primaryColor,
    required this.message,
    this.isDismissible = false,
  });

  /// Shows a loading dialog and returns a Future that can be used to dismiss it
  static Future<void> show({
    required BuildContext context,
    required Color primaryColor,
    required String message,
    bool isDismissible = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (BuildContext context) {
        return LoadingDialog(
          primaryColor: primaryColor,
          message: message,
          isDismissible: isDismissible,
        );
      },
    );
  }

  /// Dismisses the currently shown loading dialog
  static void dismiss(BuildContext context) {
    try {
      // Check if we can safely pop the navigation stack
      final navigator = Navigator.maybeOf(context);
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
      } else if (navigator == null) {
        // Navigator is null - context might be invalid
        print('LoadingDialog.dismiss: Navigator is null, cannot dismiss dialog');
      } else {
        // Navigator exists but can't pop - no dialog to dismiss
        print('LoadingDialog.dismiss: No dialog to dismiss (canPop returned false)');
      }
    } catch (e) {
      // Silently handle any dismiss errors to prevent crashes
      // This can happen if the dialog was already dismissed or context is invalid
      print('LoadingDialog.dismiss: Error dismissing dialog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
      ),
      content: LoadingIndicator(
        primaryColor: primaryColor,
        message: message,
      ),
    );
  }
}
