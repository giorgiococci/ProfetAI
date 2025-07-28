import 'package:flutter/material.dart';
import '../utils/utils.dart';

class VisionBookScreen extends StatelessWidget {
  const VisionBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: ThemeUtils.getGradientDecoration(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F0F23)]
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: ThemeUtils.paddingLG,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories,
                    size: 80,
                    color: Colors.white70,
                  ),
                  SizedBox(height: ThemeUtils.spacingLG),
                  Text(
                    'Libro delle Visioni',
                    style: ThemeUtils.headlineStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ThemeUtils.spacingMD),
                  Text(
                    'Coming Soon',
                    style: ThemeUtils.subtitleStyle.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
