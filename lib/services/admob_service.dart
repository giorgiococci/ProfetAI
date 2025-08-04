import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/app_logger.dart';

/// Service for managing Google AdMob advertisements
/// 
/// This service handles initialization, loading, and displaying of rewarded ads
/// that show every 5 questions asked to any prophet
class AdMobService {
  static const String _component = 'AdMobService';
  
  // Test ad unit IDs (replace with real ones for production)
  static const String _androidTestRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';
  
  // Production ad unit IDs - Your actual AdMob ad unit IDs
  static const String _androidProdRewardedAdUnitId = 'ca-app-pub-2111391175565068/3552323425';
  static const String _iosProdRewardedAdUnitId = 'ca-app-pub-2111391175565068/3552323425';
  
  // Singleton pattern
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();
  
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isInitialized = false;
  
  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await MobileAds.instance.initialize();
      
      // Update ad request configuration
      final RequestConfiguration requestConfiguration = RequestConfiguration(
        // Set to true for testing, false for production
        testDeviceIds: kDebugMode ? ['YOUR_TEST_DEVICE_ID'] : [],
      );
      
      MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      
      _isInitialized = true;
      
      // Preload the first rewarded ad
      await _loadRewardedAd();
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to initialize AdMob SDK', e);
      rethrow;
    }
  }
  
  /// Get the appropriate rewarded ad unit ID based on platform and debug mode
  String get _rewardedAdUnitId {
    if (kDebugMode) {
      // Use test ad units in debug mode
      return Platform.isAndroid 
        ? _androidTestRewardedAdUnitId 
        : _iosTestRewardedAdUnitId;
    } else {
      // Use production ad units in release mode
      return Platform.isAndroid 
        ? _androidProdRewardedAdUnitId 
        : _iosProdRewardedAdUnitId;
    }
  }
  
  /// Load a rewarded ad
  Future<void> _loadRewardedAd() async {
    if (_isLoading) return;
    
    _isLoading = true;
    
    try {
      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _isLoading = false;
            _setAdCallbacks();
          },
          onAdFailedToLoad: (LoadAdError error) {
            AppLogger.logError(_component, 'Failed to load rewarded ad: ${error.message} (Code: ${error.code})');
            _rewardedAd = null;
            _isLoading = false;
            
            // Try to reload after a delay if it failed
            Future.delayed(Duration(seconds: 5), () {
              if (_rewardedAd == null && !_isLoading) {
                _loadRewardedAd();
              }
            });
          },
        ),
      );
    } catch (e) {
      AppLogger.logError(_component, 'Error loading rewarded ad', e);
      _isLoading = false;
    }
  }
  
  /// Force reload a rewarded ad (public method)
  Future<void> forceReloadAd() async {
    _isLoading = false; // Reset loading state
    await _loadRewardedAd();
  }
  
  /// Set initial callbacks for the rewarded ad (will be overridden when showing)
  void _setAdCallbacks() {
    if (_rewardedAd == null) return;
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        // Reduced logging
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        // Preload the next ad
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        AppLogger.logError(_component, 'Failed to show rewarded ad: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        // Try to load another ad
        _loadRewardedAd();
      },
    );
  }
  
  /// Check if a rewarded ad is ready to be shown
  bool isRewardedAdReady() {
    final isReady = _rewardedAd != null;
    return isReady;
  }
  
  /// Get debug info about ad service state
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'isLoading': _isLoading,
      'adReady': _rewardedAd != null,
      'adUnitId': _rewardedAdUnitId,
      'debugMode': kDebugMode,
    };
  }
  
  /// Show the rewarded ad
  /// 
  /// [onUserEarnedReward] - Called when user completes watching the ad
  /// [onAdClosed] - Called when the ad is closed (regardless of completion)
  Future<void> showRewardedAd({
    required Function() onUserEarnedReward,
    Function()? onAdClosed,
  }) async {
    if (_rewardedAd == null) {
      AppLogger.logWarning(_component, 'No rewarded ad available to show');
      onAdClosed?.call();
      return;
    }

    try {
      // Set the callbacks before showing the ad
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {
          // Ad shown
        },
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          _rewardedAd = null;
          
          // Call the onAdClosed callback when ad is actually dismissed
          onAdClosed?.call();
          // Preload the next ad
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          AppLogger.logError(_component, 'Failed to show ad: ${error.message}');
          ad.dispose();
          _rewardedAd = null;
          onAdClosed?.call();
          // Try to load another ad
          _loadRewardedAd();
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onUserEarnedReward();
        },
      );
      
    } catch (e) {
      AppLogger.logError(_component, 'Error showing rewarded ad', e);
      onAdClosed?.call();
    }
  }  /// Dispose of resources
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
