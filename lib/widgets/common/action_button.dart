import 'package:flutter/material.dart';

/// A responsive action button widget optimized for dialog actions
/// that adapts to screen size and shows/hides text based on available space.
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final double minScreenWidthForText;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.iconSize = 18,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    this.padding,
    this.minScreenWidthForText = 350,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showText = screenWidth > minScreenWidthForText;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      child: showText
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: iconSize),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: fontWeight,
                      fontSize: fontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Icon(icon, color: color, size: iconSize + 4), // Slightly larger when text is hidden
    );
  }
}

/// A row of action buttons with consistent spacing
class ActionButtonsRow extends StatelessWidget {
  final List<ActionButtonData> buttons;
  final MainAxisAlignment alignment;
  final double spacing;

  const ActionButtonsRow({
    super.key,
    required this.buttons,
    this.alignment = MainAxisAlignment.spaceEvenly,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: buttons.map((buttonData) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: ActionButton(
              icon: buttonData.icon,
              label: buttonData.label,
              color: buttonData.color,
              onPressed: buttonData.onPressed,
              iconSize: buttonData.iconSize ?? 18,
              fontSize: buttonData.fontSize ?? 12,
              fontWeight: buttonData.fontWeight ?? FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Data class for action button configuration
class ActionButtonData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final double? iconSize;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ActionButtonData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.iconSize,
    this.fontSize,
    this.fontWeight,
  });

  /// Factory for save action button
  factory ActionButtonData.save({
    required Color color,
    required VoidCallback onPressed,
    String label = 'Salva',
  }) {
    return ActionButtonData(
      icon: Icons.bookmark_add,
      label: label,
      color: color,
      onPressed: onPressed,
    );
  }

  /// Factory for share action button
  factory ActionButtonData.share({
    required Color color,
    required VoidCallback onPressed,
    String label = 'Condividi',
  }) {
    return ActionButtonData(
      icon: Icons.share,
      label: label,
      color: color,
      onPressed: onPressed,
    );
  }

  /// Factory for close action button
  factory ActionButtonData.close({
    required VoidCallback onPressed,
    String label = 'Chiudi',
    Color color = Colors.grey,
  }) {
    return ActionButtonData(
      icon: Icons.close,
      label: label,
      color: color,
      onPressed: onPressed,
    );
  }
}
