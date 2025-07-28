import 'package:flutter/material.dart';
import '../../utils/utils.dart';

/// A widget that displays error messages with consistent styling.
/// Shows an error icon, message text, and red-themed background.
class ErrorDisplayWidget extends StatelessWidget {
  final String errorMessage;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ErrorDisplayWidget({
    super.key,
    required this.errorMessage,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? ThemeUtils.verticalPaddingMD,
      padding: padding ?? ThemeUtils.paddingMD,
      decoration: ThemeUtils.getCardDecoration(
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          ThemeUtils.horizontalSpacerSM,
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
