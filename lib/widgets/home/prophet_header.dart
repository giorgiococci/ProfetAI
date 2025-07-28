import 'package:flutter/material.dart';
import '../../models/profet.dart';
import '../../prophet_localizations.dart';

/// A header widget that displays the prophet's temple/location name and description
/// with proper localization support.
class ProphetHeader extends StatelessWidget {
  final Profet profet;
  final String prophetTypeString;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final EdgeInsetsGeometry? padding;
  final bool showDescription;

  const ProphetHeader({
    super.key,
    required this.profet,
    required this.prophetTypeString,
    this.titleStyle,
    this.descriptionStyle,
    this.padding,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          FutureBuilder<String>(
            future: ProphetLocalizations.getLocation(context, prophetTypeString),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Temple of Wisdom',
                style: titleStyle ??
                    TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: profet.primaryColor,
                      letterSpacing: 2.0,
                    ),
                textAlign: TextAlign.center,
              );
            },
          ),
          if (showDescription) ...[
            const SizedBox(height: 10),
            FutureBuilder<String>(
              future: ProphetLocalizations.getDescription(context, prophetTypeString),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'An ancient oracle with wisdom',
                  style: descriptionStyle ??
                      TextStyle(
                        fontSize: 16,
                        color: Colors.grey[300],
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// An animated version of the prophet header with fade-in effects
class AnimatedProphetHeader extends StatefulWidget {
  final Profet profet;
  final String prophetTypeString;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedProphetHeader({
    super.key,
    required this.profet,
    required this.prophetTypeString,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AnimatedProphetHeader> createState() => _AnimatedProphetHeaderState();
}

class _AnimatedProphetHeaderState extends State<AnimatedProphetHeader>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _descriptionController;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _descriptionOpacity;
  late Animation<Offset> _descriptionSlide;

  @override
  void initState() {
    super.initState();
    
    _titleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _descriptionController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: widget.animationCurve,
    ));

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: widget.animationCurve,
    ));

    _descriptionOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _descriptionController,
      curve: widget.animationCurve,
    ));

    _descriptionSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _descriptionController,
      curve: widget.animationCurve,
    ));

    // Start animations
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _descriptionController.forward();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          SlideTransition(
            position: _titleSlide,
            child: FadeTransition(
              opacity: _titleOpacity,
              child: FutureBuilder<String>(
                future: ProphetLocalizations.getLocation(context, widget.prophetTypeString),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Temple of Wisdom',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.profet.primaryColor,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          SlideTransition(
            position: _descriptionSlide,
            child: FadeTransition(
              opacity: _descriptionOpacity,
              child: FutureBuilder<String>(
                future: ProphetLocalizations.getDescription(context, widget.prophetTypeString),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'An ancient oracle with wisdom',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact version of the prophet header for smaller spaces
class CompactProphetHeader extends StatelessWidget {
  final Profet profet;
  final String prophetTypeString;
  final bool showIcon;

  const CompactProphetHeader({
    super.key,
    required this.profet,
    required this.prophetTypeString,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              profet.icon,
              color: profet.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: FutureBuilder<String>(
              future: ProphetLocalizations.getLocation(context, prophetTypeString),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Temple of Wisdom',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: profet.primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
