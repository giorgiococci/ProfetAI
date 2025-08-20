import 'package:flutter/material.dart';
import '../../models/oracolo_caotico.dart';
import '../../models/oracolo_mistico.dart';
import '../../models/oracolo_cinico.dart';
import '../../l10n/prophet_localization_loader.dart';
import '../common/loading_indicator.dart';

/// Collection of specialized dialog widgets for the Orakl app
/// This includes loading dialogs, status dialogs, error dialogs, and confirmation dialogs

// ================================
// LOADING DIALOGS
// ================================

/// Prophet-specific loading dialog that shows personalized loading messages
class ProphetLoadingDialog {
  /// Shows a loading dialog with prophet-specific styling and localized messages
  static Future<void> show({
    required BuildContext context,
    required profet,
  }) async {
    // Get localized loading message based on prophet type
    String loadingMessage;
    if (profet is OracoloCaotico) {
      loadingMessage = await ProphetLocalizationLoader.getAILoadingMessage(context, 'chaotic');
    } else if (profet is OracoloMistico) {
      loadingMessage = await ProphetLocalizationLoader.getAILoadingMessage(context, 'mystic');
    } else if (profet is OracoloCinico) {
      loadingMessage = await ProphetLocalizationLoader.getAILoadingMessage(context, 'cynical');
    } else {
      loadingMessage = 'Loading...'; // Fallback
    }

    await LoadingDialog.show(
      context: context,
      primaryColor: profet.primaryColor,
      message: loadingMessage,
    );
  }

  /// Dismisses the currently shown loading dialog
  static void dismiss(BuildContext context) {
    LoadingDialog.dismiss(context);
  }
}

// ================================
// STATUS DIALOGS
// ================================

/// Status dialog for showing app initialization and system status information
class StatusDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final bool barrierDismissible;

  const StatusDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.barrierDismissible = false,
  });

  /// Factory constructor for success status
  factory StatusDialog.success({
    required String title,
    required String message,
    bool barrierDismissible = false,
  }) {
    return StatusDialog(
      title: title,
      message: message,
      icon: Icons.check_circle,
      iconColor: Colors.green,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Factory constructor for info status
  factory StatusDialog.info({
    required String title,
    required String message,
    bool barrierDismissible = false,
  }) {
    return StatusDialog(
      title: title,
      message: message,
      icon: Icons.info,
      iconColor: Colors.blue,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Factory constructor for warning status
  factory StatusDialog.warning({
    required String title,
    required String message,
    bool barrierDismissible = false,
  }) {
    return StatusDialog(
      title: title,
      message: message,
      icon: Icons.warning,
      iconColor: Colors.orange,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Shows the status dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    bool barrierDismissible = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) => StatusDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: iconColor.withValues(alpha: 0.8), width: 2),
      ),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.deepPurpleAccent),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// ================================
// ERROR DIALOGS
// ================================

/// Error dialog for displaying error messages with consistent styling
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool barrierDismissible;
  final VoidCallback? onOkPressed;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.barrierDismissible = false,
    this.onOkPressed,
  });

  /// Shows an error dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    bool barrierDismissible = false,
    VoidCallback? onOkPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) => ErrorDialog(
        title: title,
        message: message,
        barrierDismissible: barrierDismissible,
        onOkPressed: onOkPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D30),
      title: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.deepPurpleAccent),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            if (onOkPressed != null) {
              onOkPressed!();
            }
          },
        ),
      ],
    );
  }
}

// ================================
// CONFIRMATION DIALOGS
// ================================

/// Confirmation dialog for yes/no decisions with prophet theming
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final Color? cancelColor;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.cancelColor,
    this.onConfirm,
    this.onCancel,
  });

  /// Factory for delete confirmation
  factory ConfirmationDialog.delete({
    required String title,
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmationDialog(
      title: title,
      message: message,
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      cancelColor: Colors.grey,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Factory for save confirmation
  factory ConfirmationDialog.save({
    required String title,
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmationDialog(
      title: title,
      message: message,
      confirmText: 'Save',
      cancelText: 'Cancel',
      confirmColor: Colors.green,
      cancelColor: Colors.grey,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Shows a confirmation dialog and returns the user's choice
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogColor = confirmColor ?? Colors.deepPurpleAccent;
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: dialogColor.withValues(alpha: 0.8), width: 2),
      ),
      title: Text(
        title,
        style: TextStyle(color: dialogColor, fontSize: 18),
      ),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            cancelText,
            style: TextStyle(
              color: cancelColor ?? Colors.grey,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
            if (onCancel != null) {
              onCancel!();
            }
          },
        ),
        TextButton(
          child: Text(
            confirmText,
            style: TextStyle(
              color: confirmColor ?? Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
            if (onConfirm != null) {
              onConfirm!();
            }
          },
        ),
      ],
    );
  }
}

// ================================
// INPUT DIALOGS
// ================================

/// Dialog for collecting text input from the user
class InputDialog extends StatefulWidget {
  final String title;
  final String? hint;
  final String? initialValue;
  final String confirmText;
  final String cancelText;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const InputDialog({
    super.key,
    required this.title,
    this.hint,
    this.initialValue,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  /// Shows an input dialog and returns the entered text
  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? hint,
    String? initialValue,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => InputDialog(
        title: title,
        hint: hint,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final text = _controller.text;
    if (widget.validator != null) {
      final error = widget.validator!(text);
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D30),
      title: Text(
        widget.title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Colors.white54),
              errorText: _errorText,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurpleAccent),
              ),
            ),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() {
                  _errorText = null;
                });
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            widget.cancelText,
            style: const TextStyle(color: Colors.grey),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            widget.confirmText,
            style: const TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _onConfirm,
        ),
      ],
    );
  }
}
