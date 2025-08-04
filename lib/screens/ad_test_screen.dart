import 'package:flutter/material.dart';
import '../services/admob_service.dart';
import '../utils/app_logger.dart';

/// Simple test screen to verify AdMob reward callback functionality
class AdTestScreen extends StatefulWidget {
  const AdTestScreen({Key? key}) : super(key: key);

  @override
  State<AdTestScreen> createState() => _AdTestScreenState();
}

class _AdTestScreenState extends State<AdTestScreen> {
  static const String _component = 'AdTestScreen';
  final AdMobService _adMobService = AdMobService();
  
  String _status = 'Ready to test';
  bool _rewardEarned = false;
  bool _adClosed = false;

  @override
  void initState() {
    super.initState();
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    try {
      await _adMobService.initialize();
      setState(() {
        _status = 'AdMob initialized. Ready to test.';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to initialize AdMob: $e';
      });
    }
  }

  Future<void> _testRewardedAd() async {
    setState(() {
      _status = 'Testing rewarded ad...';
      _rewardEarned = false;
      _adClosed = false;
    });

    if (!_adMobService.isRewardedAdReady()) {
      setState(() {
        _status = 'Ad not ready - attempting to reload...';
      });
      
      await _adMobService.forceReloadAd();
      await Future.delayed(Duration(seconds: 3));
      
      if (!_adMobService.isRewardedAdReady()) {
        setState(() {
          _status = 'Ad still not ready after reload';
        });
        return;
      }
    }

    AppLogger.logInfo(_component, 'Starting reward test ad');

    await _adMobService.showRewardedAd(
      onUserEarnedReward: () {
        AppLogger.logInfo(_component, 'TEST: Reward earned callback triggered!');
        setState(() {
          _rewardEarned = true;
          _status = 'REWARD EARNED! ✅';
        });
      },
      onAdClosed: () {
        AppLogger.logInfo(_component, 'TEST: Ad closed callback triggered');
        setState(() {
          _adClosed = true;
          if (!_rewardEarned) {
            _status = 'Ad closed without reward ❌';
          }
        });
      },
    );

    // Give time for callbacks to process
    await Future.delayed(Duration(seconds: 1));
    
    AppLogger.logInfo(_component, 'TEST RESULT: Reward earned = $_rewardEarned, Ad closed = $_adClosed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ad Test Screen'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'AdMob Reward Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reward Earned:'),
                        Text(
                          _rewardEarned ? '✅ YES' : '❌ NO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _rewardEarned ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ad Closed:'),
                        Text(
                          _adClosed ? '✅ YES' : '❌ NO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _adClosed ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _testRewardedAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Test Rewarded Ad',
                style: TextStyle(fontSize: 18),
              ),
            ),
            
            SizedBox(height: 10),
            
            Text(
              'Instructions:\n'
              '1. Tap "Test Rewarded Ad"\n'
              '2. Watch the ad completely\n'
              '3. Check if "Reward Earned" shows ✅',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
