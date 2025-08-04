# AdMob Integration Architecture

## Overview

This document describes the complete AdMob rewarded ad integration system implemented in ProfetAI, including the critical race condition fix that ensures proper reward functionality.

## System Architecture

### Core Components

1. **QuestionAdService** (`lib/services/question_ad_service.dart`)
   - Central orchestrator for question counting and ad triggering
   - Manages cooldown bypass logic
   - Handles async coordination between AdMob callbacks

2. **AdMobService** (`lib/services/admob_service.dart`)
   - Google AdMob SDK wrapper
   - Manages ad loading and display lifecycle
   - Provides callback interfaces for ad completion

3. **UnifiedAdDialog** (`lib/widgets/dialogs/unified_ad_dialog.dart`)
   - Single dialog component for all ad scenarios
   - Handles both regular ads and cooldown bypass
   - Manages loading states and user feedback

## Business Logic

### Question Counting System

- Users can ask 5 questions for free
- After 5 questions, they must watch a rewarded ad to continue
- Watching an ad resets the question count to 0
- Alternative: 4-hour cooldown period bypasses ad requirement

### Cooldown Bypass Logic

- Users can bypass ads by waiting 4 hours
- Cooldown timer starts after the 5th question
- If cooldown has expired, users can ask questions without ads
- Cooldown resets when ads are watched

## Critical Race Condition Fix

### The Problem

Initially, the system suffered from a race condition where:

1. `AdMobService.showRewardedAd()` would return immediately when the ad started displaying
2. The `onShowAd` callback in `QuestionAdService` would complete before the user finished watching
3. This caused the dialog to return `false` (no reward) even if the user completed the ad
4. Result: "When I watch the ADV, then I try to do a question, and appears again the ADV alert with the same countdown"

### The Solution: Completer Pattern

We implemented Dart's `Completer<bool>` pattern to properly coordinate async callbacks:

```dart
import 'dart:async';

// In QuestionAdService.onShowAd()
final Completer<bool> adCompleter = Completer<bool>();

AdMobService.instance.showRewardedAd(
  onUserEarnedReward: () {
    if (!adCompleter.isCompleted) {
      adCompleter.complete(true);  // User earned reward
    }
  },
  onAdClosed: () {
    if (!adCompleter.isCompleted) {
      adCompleter.complete(false); // Ad closed without reward
    }
  },
);

// Wait for actual ad completion
return await adCompleter.future;
```

### Why This Works

1. The `Completer` waits for either `onUserEarnedReward` or `onAdClosed` to fire
2. Only when one of these callbacks completes does the method return a result
3. This ensures we know the actual outcome of the ad viewing session
4. Race condition eliminated: we wait for completion, not just ad start

## Implementation Details

### QuestionAdService Key Methods

#### `handleUserQuestion()`

- Checks current question count
- Determines if ad is required
- Manages cooldown logic
- Increments question count on success

#### `onShowAd()`

- Creates `Completer<bool>` for async coordination
- Calls `AdMobService.showRewardedAd()` with proper callbacks
- Waits for ad completion before returning result
- Resets question count on successful reward

#### `_checkCooldownExpiry()`

- Validates 4-hour cooldown period
- Returns `true` if cooldown has expired
- Allows bypassing ads when cooldown is complete

### AdMobService Integration

#### `showRewardedAd()`

- Sets up `FullScreenContentCallback` for ad lifecycle
- Handles `onUserEarnedReward` for successful completions
- Handles `onAdDismissedFullScreenContent` for all closures
- Preloads next ad after current ad disposal

#### Callback Timing

- `onAdShowedFullScreenContent`: Ad starts displaying
- `onUserEarnedReward`: User successfully watches complete ad
- `onAdDismissedFullScreenContent`: Ad is closed (reward or no reward)

### UnifiedAdDialog Interface

#### `_handleAdDisplay()`

- Shows loading spinner during ad preparation
- Calls `QuestionAdService.onShowAd()`
- Waits for `Completer` result
- Returns boolean indicating success/failure

## Error Handling

### Ad Loading Failures

- `AdMobService` logs warnings when ads fail to load
- System gracefully degrades to cooldown-only mode
- Users are informed when ads are unavailable

### Network Issues

- Ad failures trigger cooldown bypass checks
- Users can continue if cooldown has expired
- System attempts to reload ads in background

### Callback Failures

- `Completer` ensures callbacks always resolve
- Timeout protection prevents infinite waiting
- Error states properly propagate to UI

## Testing Strategy

### Manual Testing Scenarios

1. **Normal Flow**: Ask 5 questions → watch ad → continue asking
2. **Ad Completion**: Verify question count resets after successful ad
3. **Ad Cancellation**: Verify question count unchanged after ad cancel
4. **Cooldown Bypass**: Wait 4 hours → verify ad bypass works
5. **Race Condition**: Rapidly interact during ad display

### Debug Logging

Production code uses `AppLogger` for structured logging:

- Question count changes
- Cooldown calculations
- Ad request/completion events
- Error conditions

## Migration Notes

### Removed Components

- `RewardedAdDialog`: Legacy dialog removed to eliminate dual-dialog conflicts
- Excessive debug `print()` statements: Cleaned for production

### Added Dependencies

- `dart:async`: Required for `Completer` pattern
- Enhanced error handling throughout ad flow

## Performance Considerations

### Memory Management

- Ads properly disposed after viewing
- Preloading managed by AdMob SDK
- No memory leaks in callback chains

### User Experience

- Loading states prevent UI confusion
- Clear messaging about ad requirements
- Smooth transitions between states

## Future Enhancements

### Potential Improvements

1. **Ad Variety**: Multiple ad types (interstitial, banner)
2. **Reward Multipliers**: Different rewards for different ad types
3. **Analytics**: Detailed ad performance tracking
4. **A/B Testing**: Different cooldown periods or question limits

### Maintenance Notes

- Monitor AdMob SDK updates for breaking changes
- Review callback timing if SDK behavior changes
- Consider migrating to newer async patterns as Dart evolves

## Troubleshooting

### Common Issues

1. **"Ad dialog appears twice"**: Check for dual dialog implementations
2. **"Rewards not working"**: Verify `Completer` pattern implementation
3. **"Questions not resetting"**: Confirm `onUserEarnedReward` callback firing

### Debug Steps

1. Enable `AppLogger` debug level
2. Check ad loading success in logs
3. Verify callback sequence in ad flow
4. Test cooldown calculations manually

---

*This documentation reflects the system state after the successful race condition fix implemented in January 2025.*
