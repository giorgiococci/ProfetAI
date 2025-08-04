import 'package:flutter/material.dart';
import '../services/question_ad_service.dart';
import 'ad_test_screen.dart';

/// Simple debug screen to test ad functionality
class AdDebugScreen extends StatefulWidget {
  const AdDebugScreen({Key? key}) : super(key: key);

  @override
  _AdDebugScreenState createState() => _AdDebugScreenState();
}

class _AdDebugScreenState extends State<AdDebugScreen> {
  final QuestionAdService _questionAdService = QuestionAdService();
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _updateDebugInfo();
  }

  void _updateDebugInfo() {
    setState(() {
      final info = _questionAdService.getDebugInfo();
      _debugInfo = '''
Question Count: ${info['questionCount']}
Cooldown Active: ${info['cooldownActive']}
Questions Until Next Ad: ${info['questionsUntilNextAd']}
Will Show Ad on Next Question: ${info['willShowAdOnNextQuestion']}
Service Initialized: ${info['serviceInitialized']}
Ad Service Initialized: ${info['adService']['isInitialized']}
Ad Ready: ${info['adService']['adReady']}
Ad Loading: ${info['adService']['isLoading']}
Debug Mode: ${info['adService']['debugMode']}
Ad Unit ID: ${info['adService']['adUnitId']}
      ''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ad Debug'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ad System Debug Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: Text(
                _debugInfo,
                style: TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _questionAdService.debugPrintCurrentState();
                    _updateDebugInfo();
                  },
                  child: Text('Print State'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _questionAdService.debugTestAdLoading();
                    _updateDebugInfo();
                  },
                  child: Text('Test Ad Loading'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _questionAdService.debugReset();
                    _updateDebugInfo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Debug reset complete')),
                    );
                  },
                  child: Text('Reset All'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await _questionAdService.handleUserQuestion(context);
                    _updateDebugInfo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Handle question result: $result')),
                    );
                  },
                  child: Text('Test Question'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdTestScreen()),
                    );
                  },
                  child: Text('AdMob Reward Test'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. "Print State" - Shows current state in logs\n'
              '2. "Test Ad Loading" - Attempts to load an ad\n'
              '3. "Reset All" - Clears question count and cooldown\n'
              '4. "Test Question" - Simulates asking a question\n'
              '5. "AdMob Reward Test" - Direct AdMob callback test',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
