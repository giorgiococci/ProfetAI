# Onboarding System Implementation - Technical Reference

## Overview
This document describes the comprehensive onboarding system implementation for ProfetAI, including localization fixes, feature removals, persistence debugging, and prophet name localization across all onboarding screens.

## Onboarding System Overview

### Architecture
The onboarding system is implemented as a PageView-based flow consisting of 3 screens managed by the `OnboardingFlow` widget. The system uses FlutterSecureStorage for persistence and integrates with the app's dual-layer localization system.

### Screen Flow
1. **Welcome Screen** (`OnboardingWelcomeScreen`)
   - App introduction and mystical branding
   - Preview of 3 example oracles with localized names
   - "Begin Journey" or "Skip" options

2. **Features Screen** (`OnboardingFeaturesScreen`) 
   - Showcase of app capabilities:
     - Personalized Predictions
     - Random Visions  
     - Vision Book
     - Unique Themes
   - "Continue" or "Skip" options

3. **Personalization Screen** (`OnboardingPersonalizationScreen`)
   - Optional user personalization:
     - Name input
     - Life focus areas selection (up to 3)
     - Life stage selection
     - Preferred oracle selection (top 5 oracles with localized names)
   - "Enter the Mystical Realm" completion button

### Storage & Persistence
**Storage Backend**: FlutterSecureStorage
**Key Used**: `onboarding_completed`
**Value**: `'true'` when completed

**Storage Location**:
- **Android**: Android Keystore system
- **iOS**: iOS Keychain
- **Windows**: Windows Credential Store  
- **Data**: Encrypted and secure across app reinstalls

**Persistence Logic**:
- Checked on app startup in `main.dart`
- Set to `true` when user completes flow or skips
- Persists across app sessions and device restarts
- Can be reset via debug settings for testing

**Related Services**:
- `OnboardingService`: Handles completion state persistence
- `UserProfileService`: Saves personalization data to separate storage
- Both services use FlutterSecureStorage with different keys

### Localization Integration
**UI Text**: Loaded from ARB files (`app_en.arb`, `app_it.arb`)
**Prophet Content**: Loaded from JSON files (`lib/l10n/prophets/*/prophet_*.json`)

**Dynamic Content**:
- Prophet names, descriptions, and locations are loaded asynchronously
- FutureBuilder widgets handle loading states
- Automatic fallback to English if localization fails
- Graceful fallback to hardcoded names if JSON loading fails

## Implementation Summary

### Phase 1: Italian Localization Corrections
**Issue**: Incorrect Italian translations in ARB files
**Files Modified**:
- `lib/l10n/app_it.arb`

**Changes**:
- Fixed "guidanza" → "guida" (guidance)
- Corrected life stage descriptions from overly literal translations to natural Italian

### Phase 2: Guidance Style System Removal
**Issue**: Client requested removal of guidance style collection feature
**Files Modified**:
- `lib/models/user_profile.dart` - Removed `guidanceStyle` field entirely
- `lib/screens/onboarding/onboarding_personalization_screen.dart` - Removed UI components
- All dependent classes updated to match new UserProfile signature

**Technical Details**:
- Removed from constructor, copyWith, toJson, fromJson, toString methods
- Updated all callers to use new 2-parameter model (lifeFocusAreas, lifeStage only)

### Phase 3: Onboarding Persistence Debugging
**Issue**: Onboarding appeared every app launch despite completion
**Files Modified**:
- `lib/services/onboarding_service.dart` - Added debug logging and reset functionality
- `lib/screens/profile/settings_screen.dart` - Added debug reset option

**Technical Solution**:
- Confirmed FlutterSecureStorage persistence was working correctly
- Added debug tools to manually reset onboarding for testing
- Verified proper completion flow through logging

### Phase 4: Prophet Name Localization System
**Issue**: Prophet names displayed in Italian even when UI language was English
**Root Cause**: Hardcoded `oracle.name` usage instead of localized names from JSON files

**Files Modified**:
- `lib/l10n/prophet_localization_loader.dart` - Enhanced with new methods
- `lib/screens/onboarding/onboarding_welcome_screen.dart` - Converted to async localization
- `lib/screens/onboarding/onboarding_personalization_screen.dart` - Converted to async localization

### Phase 5: Storage Reliability and Race Condition Fix
**Issue**: Onboarding completion was inconsistent, and user preferences were lost after app restart
**Root Causes**: 
1. FlutterSecureStorage reliability issues on Windows (especially in debug/release builds)
2. Race condition between profile saving and onboarding completion
3. Silent error handling prevented detection of storage failures

**Files Modified**:
- `lib/services/onboarding_service.dart` - Implemented dual-storage approach with SharedPreferences backup
- `lib/services/user_profile_service.dart` - Enhanced with dual-storage reliability
- `lib/screens/onboarding/onboarding_flow.dart` - Fixed race conditions and error handling
- `lib/screens/onboarding/onboarding_personalization_screen.dart` - Made completion process awaitable

**Technical Solutions**:
1. **Dual Storage Architecture**: Both services now use FlutterSecureStorage as primary + SharedPreferences as backup
2. **Comprehensive Logging**: Added detailed logging for all storage operations with success/failure tracking
3. **Verification System**: Each write operation is immediately verified to ensure persistence
4. **Race Condition Fix**: Onboarding completion now properly awaits all storage operations
5. **Error Handling**: Replaced silent error handling with proper exception throwing and user feedback
6. **Storage Status Debug**: Added `getStorageStatus()` methods for debugging storage states

### Phase 6: Prophet Selection Integration Fix
**Issue**: Selected prophet in onboarding wasn't being set as favorite in home screen
**Root Cause**: Mismatch between prophet type identifiers - onboarding used enum names (`mistico`, `caotico`) while main app expected English strings (`mystic`, `chaotic`)

**Files Modified**:
- `lib/screens/onboarding/onboarding_personalization_screen.dart` - Added prophet type mapping function

**Technical Solution**:
- Added `_profetTypeToEnglishString()` method to convert ProfetType enums to proper English strings
- Updated oracle selection ID generation to use English prophet type strings
- Ensures selected prophet persists correctly and displays as favorite in home screen

## Technical Architecture

### Prophet Localization System
The app uses a dual-layer localization system:

1. **ARB Files** (`lib/l10n/app_*.arb`): UI text and labels
2. **JSON Files** (`lib/l10n/prophets/*/prophet_*.json`): Prophet-specific content

**Prophet JSON Structure**:
```
lib/l10n/prophets/
├── chaotic_prophet/
│   ├── chaotic_prophet_en.json
│   └── chaotic_prophet_it.json
├── cynical_prophet/
│   ├── cynical_prophet_en.json
│   └── cynical_prophet_it.json
├── mystic_prophet/
│   ├── mystic_prophet_en.json
│   └── mystic_prophet_it.json
└── roaster_prophet/
    ├── roaster_prophet_en.json
    └── roaster_prophet_it.json
```

### ProphetLocalizationLoader Enhancement
**New Methods Added**:
```dart
static Future<String> getProphetName(BuildContext context, String prophetType)
static Future<String> getProphetDescription(BuildContext context, String prophetType)
static Future<String> getProphetLocation(BuildContext context, String prophetType)
```

**Key Features**:
- Automatic locale detection via `Localizations.localeOf(context)`
- Fallback to English if localization fails
- Caching mechanism for performance
- Error handling with default values

### Async Widget Implementation
Both onboarding screens were converted to use async widgets for prophet localization:

**Welcome Screen** (`onboarding_welcome_screen.dart`):
- `_buildOracleExamplesAsync(BuildContext context)` - FutureBuilder-based widget
- `_loadOracleWidgets(BuildContext context, List<dynamic> oracles)` - Async data loader
- Loading states with placeholder widgets

**Personalization Screen** (`onboarding_personalization_screen.dart`):
- `_buildOracleSelectionsAsync()` - FutureBuilder-based widget  
- `_buildOracleSelectionLoading()` - Loading state widget
- Graceful fallback to original names if localization fails

## Critical Bug Fix

### Prophet Type Mapping Issue
**Problem**: ProphetLocalizationLoader was receiving enum names (`mistico`, `caotico`, `cinico`) instead of proper prophet types (`mystic_prophet`, `chaotic_prophet`, `cynical_prophet`).

**Root Cause**: 
```dart
// WRONG - was using enum name
oracleType.name  // Returns "mistico", "caotico", etc.

// CORRECT - using prophet's type property  
oracle.type     // Returns "mystic_prophet", "chaotic_prophet", etc.
```

**Solution**: Updated `_buildOracleSelectionsAsync()` in personalization screen to use `oracle.type` instead of `oracleType.name`.

## Error Patterns Debugged

### Asset Loading Errors
**Symptoms**: 
```
Unable to load asset: "lib/l10n/prophets/mistico/mistico_en.json"
```

**Analysis**: The `_getProphetFolderName()` method was correctly mapping types, but wrong types were being passed.

**Resolution**: Fixed at source by using correct prophet type identifiers.

## Testing Approach

1. **Language Switching**: Verified both English and Italian display correct prophet names
2. **Onboarding Flow**: Complete flow testing with all personalization options
3. **Persistence**: Confirmed onboarding doesn't repeat after completion
4. **Error Handling**: Tested fallback behavior when localization fails
5. **Loading States**: Verified smooth UX during async name loading

## Future Maintenance Notes

### When Adding New Prophets:
1. Create prophet folder in `lib/l10n/prophets/new_prophet/`
2. Add JSON files for each supported language
3. Ensure prophet class returns correct `type` property
4. Update `ProfetManager` enum and mappings

### When Adding New Languages:
1. Add new ARB file (`app_[locale].arb`)
2. Create corresponding JSON files for each prophet
3. Test complete onboarding flow in new language

### Debugging Localization Issues:
1. Check prophet `type` property matches folder names
2. Verify JSON file structure and content
3. Enable logging in `ProphetLocalizationLoader` if needed
4. Test async widget loading states

## Performance Considerations

- Prophet localization uses caching to avoid repeated JSON loading
- FutureBuilder widgets minimize UI rebuilds
- Graceful fallback ensures app never breaks on localization failure
- Loading states provide smooth user experience

## Files Summary

**Core Modified Files**:
- `lib/models/user_profile.dart` - Simplified model
- `lib/services/onboarding_service.dart` - Enhanced with dual-storage reliability and comprehensive logging
- `lib/services/user_profile_service.dart` - Enhanced with dual-storage reliability and comprehensive logging
- `lib/l10n/prophet_localization_loader.dart` - Enhanced with new methods
- `lib/screens/onboarding/onboarding_welcome_screen.dart` - Async localization
- `lib/screens/onboarding/onboarding_personalization_screen.dart` - Async localization and awaitable completion
- `lib/screens/onboarding/onboarding_flow.dart` - Fixed race conditions and error handling
- `lib/l10n/app_it.arb` - Italian corrections

**Supporting Files**:
- All prophet JSON localization files (verified structure)
- Settings screen (debug functionality)

---
*Document Created: August 8, 2025*  
*Implementation Status: Complete and Tested*
