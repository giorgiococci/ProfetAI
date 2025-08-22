import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import '../widgets/dialogs/unified_ad_dialog.dart';
import 'admob_service.dart';

/// Service for tracking questions and prophet responses, managing rewarded ad display with cooldown system
/// 
/// This service counts total questions across all prophets and prophet responses across all conversations.
/// It shows a rewarded ad when EITHER:
/// - 5 questions have been asked (existing logic)
/// - 5 prophet responses have been generated (new logic)
/// Users who skip ads must wait 4 hours before asking again.
class QuestionAdService {
  static const String _component = 'QuestionAdService';
  static const String _questionCountKey = 'total_question_count';
  static const String _prophetResponseCountKey = 'total_prophet_response_count';
  static const String _cooldownEndTimeKey = 'cooldown_end_time';
  static const int _adFrequency = 10; // Show ad every 10 questions OR 10 prophet responses
  static const int _cooldownHours = 4; // 4 hours cooldown for skipped ads
  
  // Singleton pattern
  static final QuestionAdService _instance = QuestionAdService._internal();
  factory QuestionAdService() => _instance;
  QuestionAdService._internal();
  
  final AdMobService _adMobService = AdMobService();
  int _questionCount = 0;
  int _prophetResponseCount = 0;
  DateTime? _cooldownEndTime;
  bool _isInitialized = false;
  bool _isProcessingQuestion = false; // Add flag to prevent concurrent processing
  bool _isProcessingProphetResponse = false; // Add flag to prevent concurrent processing
  
  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize AdMob
      await _adMobService.initialize();
      
      // Load question count, prophet response count, and cooldown data from persistent storage
      await _loadQuestionCount();
      await _loadProphetResponseCount();
      await _loadCooldownData();
      
      _isInitialized = true;
      
    } catch (e) {
      AppLogger.logError(_component, 'Failed to initialize QuestionAdService', e);
      rethrow;
    }
  }
  
  /// Load question count from SharedPreferences
  Future<void> _loadQuestionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _questionCount = prefs.getInt(_questionCountKey) ?? 0;
      AppLogger.logInfo(_component, '📖 LOADED question count: $_questionCount');
    } catch (e) {
      AppLogger.logError(_component, 'Failed to load question count', e);
      _questionCount = 0;
    }
  }
  
  /// Load prophet response count from SharedPreferences
  Future<void> _loadProphetResponseCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prophetResponseCount = prefs.getInt(_prophetResponseCountKey) ?? 0;
      AppLogger.logInfo(_component, '🔮 LOADED prophet response count: $_prophetResponseCount');
    } catch (e) {
      AppLogger.logError(_component, 'Failed to load prophet response count', e);
      _prophetResponseCount = 0;
    }
  }
  
  /// Load cooldown data from SharedPreferences
  Future<void> _loadCooldownData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cooldownTimeMs = prefs.getInt(_cooldownEndTimeKey);
      if (cooldownTimeMs != null) {
        _cooldownEndTime = DateTime.fromMillisecondsSinceEpoch(cooldownTimeMs);
      }
    } catch (e) {
      AppLogger.logError(_component, 'Failed to load cooldown data', e);
      _cooldownEndTime = null;
    }
  }

  /// Save question count to SharedPreferences
  Future<void> _saveQuestionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_questionCountKey, _questionCount);
      AppLogger.logInfo(_component, '💾 SAVED question count: $_questionCount');
    } catch (e) {
      AppLogger.logError(_component, 'Failed to save question count', e);
    }
  }
  
  /// Save prophet response count to SharedPreferences
  Future<void> _saveProphetResponseCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prophetResponseCountKey, _prophetResponseCount);
      AppLogger.logInfo(_component, '💾 SAVED prophet response count: $_prophetResponseCount');
    } catch (e) {
      AppLogger.logError(_component, 'Failed to save prophet response count', e);
    }
  }
  
  /// Save cooldown data to SharedPreferences
  Future<void> _saveCooldownData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_cooldownEndTime != null) {
        await prefs.setInt(_cooldownEndTimeKey, _cooldownEndTime!.millisecondsSinceEpoch);
        AppLogger.logInfo(_component, '💾 SAVED cooldown: ${_cooldownEndTime}');
      } else {
        await prefs.remove(_cooldownEndTimeKey);
        AppLogger.logInfo(_component, '💾 CLEARED cooldown from storage');
      }
    } catch (e) {
      AppLogger.logError(_component, 'Failed to save cooldown data', e);
    }
  }
  
  /// Check if user is currently in cooldown period
  bool isInCooldown() {
    if (_cooldownEndTime == null) return false;
    final now = DateTime.now();
    final inCooldown = now.isBefore(_cooldownEndTime!);
    
    AppLogger.logInfo(_component, '⏰ COOLDOWN CHECK: End=${_cooldownEndTime}, Now=$now, InCooldown=$inCooldown');
    
    // Clear expired cooldown
    if (!inCooldown && _cooldownEndTime != null) {
      AppLogger.logInfo(_component, '⏰ Clearing expired cooldown');
      _cooldownEndTime = null;
      _saveCooldownData(); // Save the cleared state
    }
    
    return inCooldown;
  }
  
  /// Get remaining cooldown time
  Duration? getRemainingCooldownTime() {
    if (!isInCooldown()) return null;
    return _cooldownEndTime!.difference(DateTime.now());
  }
  
  /// Main method to handle user asking a question
  /// 
  /// This method:
  /// 1. Checks if user is in cooldown and shows unified dialog if needed
  /// 2. Increments question count if allowed to proceed
  /// 3. Shows ad dialog when ad frequency is reached
  /// 4. Handles cooldown setting if user skips ad
  /// 
  /// Returns true if user can proceed with their question, false if blocked
  Future<bool> handleUserQuestion(BuildContext context) async {
    // Prevent concurrent processing
    if (_isProcessingQuestion) {
      AppLogger.logWarning(_component, '⚠️ CONCURRENT CALL BLOCKED - Already processing question');
      return false;
    }
    
    _isProcessingQuestion = true;
    
    try {
      AppLogger.logInfo(_component, '🎯 STARTING handleUserQuestion - Q:$_questionCount, Cooldown:${isInCooldown()}');
      
      if (!_isInitialized) {
        await initialize();
      }
      
      // If user is in cooldown, show unified dialog with remaining time
      if (isInCooldown()) {
        final remaining = getRemainingCooldownTime();
        
        if (remaining != null && context.mounted) {
          final result = await _showUnifiedDialog(
            context: context,
            isInCooldown: true,
            remainingCooldownTime: remaining,
          );
          
          // If user watched ad, clear cooldown and reset both counters
          if (result == true) {
            AppLogger.logInfo(_component, '✅ SUCCESS: Cooldown cleared by ad - Both counters reset to 0');
            _cooldownEndTime = null;
            _questionCount = 0; // RESET QUESTIONS WHEN BYPASSING COOLDOWN
            _prophetResponseCount = 0; // RESET PROPHET RESPONSES WHEN BYPASSING COOLDOWN
            await _saveCooldownData();
            await _saveQuestionCount();
            await _saveProphetResponseCount();
            AppLogger.logInfo(_component, '🎯 COOLDOWN BYPASS COMPLETE: Cooldown=${_cooldownEndTime}, Q=$_questionCount, Prophet responses=$_prophetResponseCount');
            
            if (context.mounted) {
              _showSuccessFeedback(context, 'Great! You can now ask the oracle again.');
            }
            
            return true;
          }
          
          return false;
        }
        return false;
      }
      
      // Increment question count
      AppLogger.logInfo(_component, '📊 BEFORE INCREMENT: Q=$_questionCount, AdFreq=$_adFrequency');
      _questionCount++;
      await _saveQuestionCount();
      AppLogger.logInfo(_component, '📊 AFTER INCREMENT: Q=$_questionCount, ShouldShowAd=${_questionCount % _adFrequency == 0}');
      
      // Check if we should show an ad
      if (_questionCount % _adFrequency == 0) {
        if (context.mounted) {
          final result = await _showUnifiedDialog(
            context: context,
            isInCooldown: false,
            questionsAsked: _questionCount,
          );
          
          // If user watched the ad successfully, reset and proceed
          if (result == true) {
            AppLogger.logInfo(_component, '✅ AD REWARD: Both counters reset to 0 (every ${_adFrequency} questions)');
            // CRITICAL: Reset BOTH counters to restart both ad cycles
            _questionCount = 0;
            _prophetResponseCount = 0;
            await _saveQuestionCount();
            await _saveProphetResponseCount();
            AppLogger.logInfo(_component, '💾 AD REWARD SAVED: Q count = $_questionCount, Prophet responses = $_prophetResponseCount');
            
            if (context.mounted) {
              _showSuccessFeedback(context, 'Thank you! Continue with your question.');
            }
            
            return true;
          } else if (result == false) {
            // User explicitly skipped the ad, set cooldown and block this question
            await _setCooldown();
            return false;
          } else {
            // result == null means ad failed to load, allow user to proceed
            return true;
          }
        }
      }
      
      // Always allow the question if no ad was triggered
      return true;
      
    } finally {
      _isProcessingQuestion = false;
    }
  }

  /// Main method to handle prophet response generation
  /// 
  /// This method:
  /// 1. Increments the global prophet response counter
  /// 2. Checks if ad should be shown (every 5 prophet responses)
  /// 3. Shows unified dialog if ad is required
  /// 4. Resets BOTH counters (questions AND prophet responses) if ad is watched
  /// 5. Applies cooldown if ad is skipped
  /// 
  /// Returns true if processing should continue, false if blocked by cooldown
  Future<bool> handleProphetResponse(BuildContext context) async {
    if (!_isInitialized) {
      AppLogger.logWarning(_component, 'Service not initialized, allowing prophet response');
      return true;
    }

    // Prevent concurrent processing
    if (_isProcessingProphetResponse) {
      AppLogger.logWarning(_component, 'Prophet response already being processed, allowing current response');
      return true;
    }

    _isProcessingProphetResponse = true;

    try {
      // Always increment prophet response count first
      _prophetResponseCount++;
      await _saveProphetResponseCount();
      AppLogger.logInfo(_component, '🔮 PROPHET RESPONSE: Count incremented to $_prophetResponseCount');

      // Check if user is in cooldown first
      if (isInCooldown()) {
        final remainingTime = getRemainingCooldownTime();
        AppLogger.logInfo(_component, '❄️ COOLDOWN ACTIVE for prophet response: ${remainingTime?.inMinutes} minutes remaining');
        
        // Show cooldown dialog with option to watch ad
        final result = await _showUnifiedDialog(
          context: context,
          isInCooldown: true,
          remainingCooldownTime: remainingTime,
          questionsAsked: null, // Not relevant for cooldown
        );
        
        if (result == true) {
          // User watched ad to bypass cooldown
          await _clearCooldown();
          // CRITICAL: Reset BOTH counters when ad is watched
          _questionCount = 0;
          _prophetResponseCount = 0;
          await _saveQuestionCount();
          await _saveProphetResponseCount();
          AppLogger.logInfo(_component, '✅ AD REWARD: Both counters reset to 0 (cooldown bypass)');
          
          if (context.mounted) {
            _showSuccessFeedback(context, 'Thank you! The oracle continues...');
          }
          
          return true;
        } else {
          // User chose to stay in cooldown, block this response
          return false;
        }
      } else {
        // Not in cooldown, check if ad should be shown
        if (_prophetResponseCount % _adFrequency == 0) {
          AppLogger.logInfo(_component, '🎬 PROPHET RESPONSE AD: Showing ad after $_prophetResponseCount responses');
          
          final result = await _showUnifiedDialog(
            context: context,
            isInCooldown: false,
            questionsAsked: _prophetResponseCount,
          );
          
          // If user watched the ad successfully, reset both counters and proceed
          if (result == true) {
            AppLogger.logInfo(_component, '✅ AD REWARD: Both counters reset to 0 (every ${_adFrequency} prophet responses)');
            // CRITICAL: Reset BOTH counters to restart both ad cycles
            _questionCount = 0;
            _prophetResponseCount = 0;
            await _saveQuestionCount();
            await _saveProphetResponseCount();
            AppLogger.logInfo(_component, '💾 AD REWARD SAVED: Q count = $_questionCount, Prophet responses = $_prophetResponseCount');
            
            if (context.mounted) {
              _showSuccessFeedback(context, 'Thank you! The oracle continues...');
            }
            
            return true;
          } else if (result == false) {
            // User explicitly skipped the ad, set cooldown and block this response
            await _setCooldown();
            return false;
          } else {
            // result == null means ad failed to load, allow response to proceed
            return true;
          }
        }
      }
      
      // Always allow the response if no ad was triggered
      return true;
      
    } finally {
      _isProcessingProphetResponse = false;
    }
  }
  
  /// Set cooldown period (4 hours from now)
  Future<void> _setCooldown() async {
    _cooldownEndTime = DateTime.now().add(Duration(hours: _cooldownHours));
    await _saveCooldownData();
  }

  /// Clear cooldown period
  Future<void> _clearCooldown() async {
    _cooldownEndTime = null;
    await _saveCooldownData();
    AppLogger.logInfo(_component, '✅ Cooldown cleared');
  }
  
  /// Show unified dialog for both ad display and cooldown scenarios
  Future<bool?> _showUnifiedDialog({
    required BuildContext context,
    required bool isInCooldown,
    Duration? remainingCooldownTime,
    int? questionsAsked,
  }) async {
    AppLogger.logInfo(_component, '🎬 SHOWING UnifiedAdDialog - Cooldown: $isInCooldown, Questions: $questionsAsked, Remaining: $remainingCooldownTime');
    
    // Check if ad is ready
    if (!_adMobService.isRewardedAdReady()) {
      // Try to force reload an ad
      await _adMobService.forceReloadAd();
      
      // Wait a moment for the ad to load
      await Future.delayed(Duration(seconds: 3));
      
      // Check again if ad is ready now
      if (!_adMobService.isRewardedAdReady()) {
        if (isInCooldown) {
          // For cooldown scenario, show message and return false
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ad not available. Please check your internet connection and try again later.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return false;
        } else {
          // For normal ad scenario, allow user to proceed without watching ad
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ad not available right now. You can continue - ad will show later.'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return true; // Allow question without ad
        }
      }
    }
    
    return await UnifiedAdDialog.show(
      context: context,
      questionsAsked: questionsAsked ?? _questionCount,
      adFrequency: _adFrequency,
      isInCooldown: isInCooldown,
      remainingCooldownTime: remainingCooldownTime,
      onShowAd: () async {
        bool adCompleted = false;
        
        // Create a Completer to wait for ad completion
        final completer = Completer<bool>();
        
        await _adMobService.showRewardedAd(
          onUserEarnedReward: () {
            adCompleted = true;
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onAdClosed: () {
            if (!completer.isCompleted) {
              completer.complete(adCompleted);
            }
          },
        );
        
        // Wait for either reward or ad closure
        return await completer.future;
      },
    ).then((result) {
      return result;
    });
  }
  
  /// Show success feedback when user watches an ad
  void _showSuccessFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  /// Reset question count and clear cooldown (for testing or user preference)
  Future<void> resetQuestionCount() async {
    _questionCount = 0;
    _cooldownEndTime = null;
    await _saveQuestionCount();
    await _saveCooldownData();
  }
  
  /// Force reset everything for debugging
  Future<void> debugReset() async {
    _questionCount = 0;
    _cooldownEndTime = null;
    await _saveQuestionCount();
    await _saveCooldownData();
  }
  
  /// Get debug info about the service state
  Map<String, dynamic> getDebugInfo() {
    final adDebugInfo = _adMobService.getDebugInfo();
    return {
      'questionCount': _questionCount,
      'cooldownActive': isInCooldown(),
      'cooldownEndTime': _cooldownEndTime?.toIso8601String(),
      'adFrequency': _adFrequency,
      'questionsUntilNextAd': questionsUntilNextAd,
      'willShowAdOnNextQuestion': willShowAdOnNextQuestion,
      'serviceInitialized': _isInitialized,
      'adService': adDebugInfo,
    };
  }
  
  /// Debug method to test ad loading
  Future<void> debugTestAdLoading() async {
    AppLogger.logInfo(_component, 'DEBUG: Testing ad loading...');
    final debugInfo = getDebugInfo();
    AppLogger.logInfo(_component, 'DEBUG: Current state: $debugInfo');
    
    if (!_adMobService.isRewardedAdReady()) {
      AppLogger.logWarning(_component, 'DEBUG: Ad not ready, attempting reload...');
      await _adMobService.forceReloadAd();
      await Future.delayed(Duration(seconds: 3));
      
      final newDebugInfo = getDebugInfo();
      AppLogger.logInfo(_component, 'DEBUG: State after reload: $newDebugInfo');
    } else {
      AppLogger.logInfo(_component, 'DEBUG: Ad is ready!');
    }
  }
  
  /// Simple debug method to see current state
  void debugPrintCurrentState() {
    final info = getDebugInfo();
    AppLogger.logInfo(_component, '=== DEBUG STATE ===');
    AppLogger.logInfo(_component, 'Question Count: ${info['questionCount']}');
    AppLogger.logInfo(_component, 'Cooldown Active: ${info['cooldownActive']}');
    AppLogger.logInfo(_component, 'Questions Until Next Ad: ${info['questionsUntilNextAd']}');
    AppLogger.logInfo(_component, 'Will Show Ad on Next Question: ${info['willShowAdOnNextQuestion']}');
    AppLogger.logInfo(_component, 'Ad Service Ready: ${info['adService']['adReady']}');
    AppLogger.logInfo(_component, 'Ad Service Initialized: ${info['adService']['isInitialized']}');
    AppLogger.logInfo(_component, '=================');
  }
  
  /// Get current question count
  int get questionCount => _questionCount;
  
  /// Get current prophet response count
  int get prophetResponseCount => _prophetResponseCount;
  
  /// Get questions remaining until next ad
  int get questionsUntilNextAd {
    return _adFrequency - (_questionCount % _adFrequency);
  }
  
  /// Get prophet responses remaining until next ad
  int get prophetResponsesUntilNextAd {
    return _adFrequency - (_prophetResponseCount % _adFrequency);
  }
  
  /// Check if next question will trigger an ad
  bool get willShowAdOnNextQuestion {
    return (_questionCount + 1) % _adFrequency == 0;
  }
  
  /// Check if next prophet response will trigger an ad
  bool get willShowAdOnNextProphetResponse {
    return (_prophetResponseCount + 1) % _adFrequency == 0;
  }
  
  /// Get ad frequency setting
  int get adFrequency => _adFrequency;
  
  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
  
  /// Dispose of resources
  void dispose() {
    _adMobService.dispose();
  }
}
