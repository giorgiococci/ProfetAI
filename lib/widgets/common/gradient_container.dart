import 'package:flutter/material.dart';

/// A reusable container widget with gradient background and optional image overlay.
/// Commonly used for creating themed backgrounds throughout the app.
class GradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final String? backgroundImagePath;
  final double backgroundOpacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const GradientContainer({
    super.key,
    required this.child,
    required this.gradientColors,
    this.gradientBegin = Alignment.topCenter,
    this.gradientEnd = Alignment.bottomCenter,
    this.backgroundImagePath,
    this.backgroundOpacity = 0.3,
    this.padding,
    this.margin,
    this.borderRadius,
    this.boxShadow,
  });

  /// Factory constructor for prophet-themed backgrounds
  factory GradientContainer.prophetThemed({
    Key? key,
    required Widget child,
    required List<Color> gradientColors,
    String? backgroundImagePath,
    EdgeInsetsGeometry? padding,
  }) {
    // Create overlay colors when there's a background image
    final overlayColors = backgroundImagePath != null
        ? [
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.7),
          ]
        : gradientColors;

    return GradientContainer(
      key: key,
      child: child,
      gradientColors: overlayColors,
      backgroundImagePath: backgroundImagePath,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        // Background image if provided
        image: backgroundImagePath != null
            ? DecorationImage(
                image: AssetImage(backgroundImagePath!),
                fit: BoxFit.cover,
                opacity: backgroundOpacity,
              )
            : null,
        // Gradient overlay
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: gradientColors,
        ),
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: padding != null
          ? Padding(
              padding: padding!,
              child: child,
            )
          : child,
    );
  }
}

/// A specialized container for content with prophet-themed styling
class ProphetContentContainer extends StatelessWidget {
  final Widget child;
  final Color primaryColor;
  final Color secondaryColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool hasBorder;
  final double borderOpacity;

  const ProphetContentContainer({
    super.key,
    required this.child,
    required this.primaryColor,
    required this.secondaryColor,
    this.padding = const EdgeInsets.all(15),
    this.margin,
    this.borderRadius = 10,
    this.hasBorder = true,
    this.borderOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.1),
            secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder
            ? Border.all(color: primaryColor.withValues(alpha: borderOpacity))
            : null,
      ),
      child: child,
    );
  }
}
