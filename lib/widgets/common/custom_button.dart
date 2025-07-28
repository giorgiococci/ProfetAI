import 'package:flutter/material.dart';

/// A reusable custom button widget that can be either elevated or outlined
/// with consistent styling across the app.
class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOutlined;
  final double? width;
  final double height;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    required this.primaryColor,
    this.backgroundColor,
    this.foregroundColor,
    this.isOutlined = false,
    this.width,
    this.height = 55,
    this.borderRadius = 25,
    this.elevation = 8,
    this.padding,
    this.textStyle,
  });

  /// Factory constructor for a primary elevated button
  factory CustomButton.primary({
    Key? key,
    required String text,
    IconData? icon,
    required VoidCallback? onPressed,
    required Color primaryColor,
    double? width,
    double height = 55,
  }) {
    return CustomButton(
      key: key,
      text: text,
      icon: icon,
      onPressed: onPressed,
      primaryColor: primaryColor,
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      width: width,
      height: height,
    );
  }

  /// Factory constructor for an outlined button
  factory CustomButton.outlined({
    Key? key,
    required String text,
    IconData? icon,
    required VoidCallback? onPressed,
    required Color primaryColor,
    double? width,
    double height = 55,
  }) {
    return CustomButton(
      key: key,
      text: text,
      icon: icon,
      onPressed: onPressed,
      primaryColor: primaryColor,
      foregroundColor: primaryColor,
      backgroundColor: primaryColor.withValues(alpha: 0.1),
      isOutlined: true,
      width: width,
      height: height,
      elevation: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? primaryColor,
            side: BorderSide(color: primaryColor, width: 2),
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: elevation,
            padding: padding,
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? primaryColor,
            foregroundColor: foregroundColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: elevation,
            padding: padding,
          );

    final buttonTextStyle = textStyle ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        );

    final child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Text(text, style: buttonTextStyle),
            ],
          )
        : Text(text, style: buttonTextStyle);

    final button = isOutlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: child,
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: child,
          );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: button,
    );
  }
}
