import 'package:flutter/material.dart';

/// A reusable dialog widget with consistent theming and responsive design
class ResponsiveDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final Color primaryColor;
  final Color? backgroundColor;
  final IconData? titleIcon;
  final Widget? titleWidget;
  final bool scrollable;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;

  const ResponsiveDialog({
    super.key,
    required this.title,
    required this.content,
    required this.primaryColor,
    this.actions,
    this.backgroundColor,
    this.titleIcon,
    this.titleWidget,
    this.scrollable = true,
    this.contentPadding,
    this.actionsPadding,
  });

  /// Shows the dialog and returns a Future
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required Color primaryColor,
    List<Widget>? actions,
    Color? backgroundColor,
    IconData? titleIcon,
    Widget? titleWidget,
    bool scrollable = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return ResponsiveDialog(
          title: title,
          content: content,
          primaryColor: primaryColor,
          actions: actions,
          backgroundColor: backgroundColor,
          titleIcon: titleIcon,
          titleWidget: titleWidget,
          scrollable: scrollable,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor ?? const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
      ),
      title: titleWidget ?? _buildTitle(),
      content: scrollable
          ? SingleChildScrollView(child: content)
          : content,
      contentPadding: contentPadding ??
          const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      actions: actions,
      actionsPadding: actionsPadding ??
          const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
    );
  }

  Widget _buildTitle() {
    if (titleIcon != null) {
      return Row(
        children: [
          Icon(titleIcon, color: primaryColor, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
    
    return Text(
      title,
      style: TextStyle(
        color: primaryColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// A specialized dialog for confirmation actions
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color primaryColor;
  final IconData? titleIcon;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.primaryColor,
    this.onCancel,
    this.titleIcon,
    this.isDestructive = false,
  });

  /// Shows a confirmation dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required Color primaryColor,
    IconData? titleIcon,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          primaryColor: primaryColor,
          titleIcon: titleIcon,
          isDestructive: isDestructive,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: title,
      titleIcon: titleIcon,
      primaryColor: primaryColor,
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: TextStyle(
              color: isDestructive ? Colors.red : primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
