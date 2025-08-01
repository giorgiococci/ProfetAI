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

  // Static reference to track active dialog
  static OverlayEntry? _currentOverlay;
  static bool _isDialogShowing = false;

  /// Shows a loading dialog using Overlay instead of showDialog
  static Future<void> show({
    required BuildContext context,
    required Color primaryColor,
    required String message,
    bool isDismissible = false,
  }) async {
    // Only dismiss if there's actually a dialog showing
    if (_isDialogShowing) {
      dismiss(context);
      // Wait a bit for the previous dialog to be fully removed
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    _isDialogShowing = true;
    
    _currentOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: LoadingDialog(
            primaryColor: primaryColor,
            message: message,
            isDismissible: isDismissible,
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_currentOverlay!);
  }

  /// Dismisses the currently shown loading dialog
  static void dismiss(BuildContext context) {
    try {
      if (_isDialogShowing && _currentOverlay != null) {
        _currentOverlay!.remove();
        _currentOverlay = null;
        _isDialogShowing = false;
        print('LoadingDialog.dismiss: Dialog dismissed successfully using Overlay');
      } else {
        print('LoadingDialog.dismiss: No dialog to dismiss');
      }
    } catch (e) {
      print('LoadingDialog.dismiss: Error dismissing dialog: $e');
      // Force reset state even if removal failed
      _currentOverlay = null;
      _isDialogShowing = false;
    }
  }

  /// Check if dialog is currently showing
  static bool get isShowing => _isDialogShowing;

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
