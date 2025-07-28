import 'package:flutter/material.dart';
import '../../models/profet.dart';

/// A circular avatar widget displaying the oracle/prophet image with themed styling.
/// Includes a gradient border, shadow effects, and fallback icon support.
class OracleAvatar extends StatelessWidget {
  final Profet profet;
  final double size;
  final double borderWidth;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;

  const OracleAvatar({
    super.key,
    required this.profet,
    this.size = 200,
    this.borderWidth = 3,
    this.shadowBlurRadius = 20,
    this.shadowSpreadRadius = 5,
  });

  /// Factory constructor for a small avatar (for use in lists, cards, etc.)
  factory OracleAvatar.small({
    Key? key,
    required Profet profet,
    double size = 60,
  }) {
    return OracleAvatar(
      key: key,
      profet: profet,
      size: size,
      borderWidth: 2,
      shadowBlurRadius: 10,
      shadowSpreadRadius: 2,
    );
  }

  /// Factory constructor for a medium avatar
  factory OracleAvatar.medium({
    Key? key,
    required Profet profet,
    double size = 120,
  }) {
    return OracleAvatar(
      key: key,
      profet: profet,
      size: size,
      borderWidth: 2.5,
      shadowBlurRadius: 15,
      shadowSpreadRadius: 3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = size / 2;
    final imageSize = size - (borderWidth * 2);
    final iconSize = size * 0.4; // Proportional icon size

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: profet.primaryColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: profet.primaryColor.withValues(alpha: 0.3),
            blurRadius: shadowBlurRadius,
            spreadRadius: shadowSpreadRadius,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                profet.primaryColor.withValues(alpha: 0.1),
                profet.secondaryColor.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: _buildAvatarContent(imageSize, iconSize, borderRadius),
        ),
      ),
    );
  }

  Widget _buildAvatarContent(double imageSize, double iconSize, double borderRadius) {
    if (profet.profetImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          profet.profetImagePath!,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon(iconSize);
          },
        ),
      );
    } else {
      return _buildFallbackIcon(iconSize);
    }
  }

  Widget _buildFallbackIcon(double iconSize) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            profet.primaryColor.withValues(alpha: 0.1),
            profet.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          profet.icon,
          size: iconSize,
          color: profet.primaryColor,
        ),
      ),
    );
  }
}

/// An interactive oracle avatar that can be tapped
class InteractiveOracleAvatar extends StatefulWidget {
  final Profet profet;
  final double size;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const InteractiveOracleAvatar({
    super.key,
    required this.profet,
    this.size = 200,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<InteractiveOracleAvatar> createState() => _InteractiveOracleAvatarState();
}

class _InteractiveOracleAvatarState extends State<InteractiveOracleAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: OracleAvatar(
              profet: widget.profet,
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}
