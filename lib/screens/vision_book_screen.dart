import 'package:flutter/material.dart';

class VisionBookScreen extends StatelessWidget {
  const VisionBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Libro delle Visioni\n(Coming Soon)',
          style: TextStyle(fontSize: 24, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
