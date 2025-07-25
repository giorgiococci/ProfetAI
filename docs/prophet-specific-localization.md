# Prophet-Specific Localization System

This guide explains how to use and manage the prophet-specific localization system for AI prompts, responses, and personality content.

## Overview

Each prophet has its own dedicated localization files containing:

- **AI System Prompts**: The personality instructions for the AI
- **Loading Messages**: What users see while AI is thinking
- **Feedback Texts**: Prophet-specific responses to user feedback
- **Random Visions**: Pre-made responses for vision requests
- **Fallback Responses**: Responses when AI is unavailable

## File Structure

```
lib/l10n/prophets/
├── chaotic_prophet/
│   ├── chaotic_prophet_en.json
│   └── chaotic_prophet_it.json
├── mystic_prophet/
│   ├── mystic_prophet_en.json
│   └── mystic_prophet_it.json
└── cynical_prophet/
    ├── cynical_prophet_en.json
    └── cynical_prophet_it.json
```

## JSON File Format

Each prophet localization file follows this structure:

```json
{
  "@@locale": "en",
  "aiSystemPrompt": "You are the [Prophet Name]...",
  "@aiSystemPrompt": {
    "description": "AI system prompt for [Prophet Name] in [Language]"
  },
  
  "aiLoadingMessage": "The [Prophet Name] is thinking...",
  "@aiLoadingMessage": {
    "description": "Loading message when [Prophet Name] AI is thinking"
  },
  
  "positiveFeedbackText": "Great vision!",
  "@positiveFeedbackText": {
    "description": "Positive feedback text for [Prophet Name]"
  },
  
  "negativeFeedbackText": "The vision was unclear",
  "@negativeFeedbackText": {
    "description": "Negative feedback text for [Prophet Name]"
  },
  
  "funnyFeedbackText": "That was amusing!",
  "@funnyFeedbackText": {
    "description": "Funny feedback text for [Prophet Name]"
  },
  
  "randomVisions": [
    "Vision 1...",
    "Vision 2...",
    "Vision 3..."
  ],
  "@randomVisions": {
    "description": "Array of random visions for when no specific question is asked"
  },
  
  "fallbackResponses": [
    "Fallback response 1...",
    "Fallback response 2...",
    "Fallback response 3..."
  ],
  "@fallbackResponses": {
    "description": "Array of fallback responses when AI is not available"
  }
}
```

## Using the Localization Loader

### Loading Prophet Content

```dart
import '../l10n/prophet_localization_loader.dart';

// Get AI system prompt for current locale
String prompt = await ProphetLocalizationLoader.getAISystemPrompt(context, 'chaotic');

// Get loading message
String loading = await ProphetLocalizationLoader.getAILoadingMessage(context, 'mystic');

// Get feedback text
String feedback = await ProphetLocalizationLoader.getFeedbackText(context, 'cynical', 'positive');

// Get random visions
List<String> visions = await ProphetLocalizationLoader.getRandomVisions(context, 'chaotic');

// Get fallback responses
List<String> responses = await ProphetLocalizationLoader.getFallbackResponses(context, 'mystic');

// Get a random fallback response
String response = await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'cynical');
```

### Prophet Type Identifiers

The system supports multiple identifiers for each prophet:

- **Chaotic Prophet**: `'chaotic'`, `'oracolo_caotico'`
- **Mystic Prophet**: `'mystic'`, `'oracolo_mistico'`
- **Cynical Prophet**: `'cynical'`, `'oracolo_cinico'`

### Prophet Class Integration

Update your prophet classes to use localized content:

```dart
class OracoloCaotico extends Profet {
  // ... existing constructor ...

  // Add localized methods
  Future<String> getLocalizedAISystemPrompt(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getAISystemPrompt(context, 'chaotic');
    } catch (e) {
      return aiSystemPrompt; // Fallback to hardcoded prompt
    }
  }

  Future<String> getLocalizedLoadingMessage(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getAILoadingMessage(context, 'chaotic');
    } catch (e) {
      return aiLoadingMessage; // Fallback to hardcoded message
    }
  }

  Future<String> getLocalizedFeedbackText(BuildContext context, String feedbackType) async {
    try {
      return await ProphetLocalizationLoader.getFeedbackText(context, 'chaotic', feedbackType);
    } catch (e) {
      // Fallback to hardcoded messages
      switch (feedbackType.toLowerCase()) {
        case 'positive': return getPositiveFeedbackText();
        case 'negative': return getNegativeFeedbackText();
        case 'funny': return getFunnyFeedbackText();
        default: return getPositiveFeedbackText();
      }
    }
  }
}
```

## Adding a New Prophet's Localization

### 1. Create Prophet Folder

```bash
mkdir lib/l10n/prophets/new_prophet
```

### 2. Create Localization Files

Create `new_prophet_en.json` and `new_prophet_it.json` with the required structure.

### 3. Update ProphetLocalizationLoader

Add the new prophet to the `_getProphetFolderName` method:

```dart
static String _getProphetFolderName(String prophetType) {
  switch (prophetType.toLowerCase()) {
    case 'oracolo_nuovo':
    case 'new':
      return 'new_prophet';
    // ... existing cases ...
    default:
      return prophetType.toLowerCase();
  }
}
```

### 4. Update Prophet Class

Add the localized methods to your new prophet class following the pattern above.

## Adding a New Language

### 1. Create New Language Files

For each existing prophet, create a new localization file:

```bash
# Example: Adding Spanish (es)
touch lib/l10n/prophets/chaotic_prophet/chaotic_prophet_es.json
touch lib/l10n/prophets/mystic_prophet/mystic_prophet_es.json
touch lib/l10n/prophets/cynical_prophet/cynical_prophet_es.json
```

### 2. Translate Content

Copy the structure from an existing language file and translate all content while maintaining the prophet's personality.

### 3. Test the New Language

The system will automatically detect and load the new language files when the app locale changes.

## Content Guidelines

### AI System Prompts

- **Length**: Comprehensive but concise (200-400 words)
- **Structure**: Clear personality description, characteristics, response format, and restrictions
- **Personality**: Must be distinct and consistent across languages
- **Language**: Specify the response language in the prompt

### Loading Messages

- **Style**: Match the prophet's personality
- **Length**: One sentence
- **Tone**: Engaging and character-appropriate

### Feedback Texts

- **Positive**: Enthusiastic and prophet-specific
- **Negative**: Disappointed but not offensive
- **Funny**: Humorous and character-appropriate

### Random Visions

- **Quantity**: 8-12 different visions
- **Style**: Match prophet's personality perfectly
- **Content**: Entertaining and engaging
- **Variety**: Different topics and approaches

### Fallback Responses

- **Quantity**: 3-5 different responses
- **Purpose**: Used when AI is unavailable
- **Style**: Maintain prophet personality even without AI
- **Helpful**: Still provide some entertainment value

## Best Practices

### 1. Personality Consistency

Ensure the prophet's personality is consistent across:
- All content types (prompts, messages, visions)
- All languages
- All situations (AI available or not)

### 2. Cultural Adaptation

When translating:
- Adapt cultural references appropriately
- Maintain the core personality while allowing for cultural nuances
- Keep humor and jokes relevant to the target culture

### 3. Fallback Strategy

Always provide fallbacks:
- Hardcoded content in prophet classes
- Error handling in async methods
- Graceful degradation when files are missing

### 4. Testing

Test thoroughly:
- All languages with all prophets
- Missing file scenarios
- Network unavailable scenarios
- App restart after language changes

## Troubleshooting

### File Not Loading

```dart
// Check if file exists and is properly formatted
List<String> locales = await ProphetLocalizationLoader.getAvailableLocales('chaotic');
print('Available locales: $locales');
```

### Cache Issues

```dart
// Clear cache if needed
ProphetLocalizationLoader.clearCache();
```

### Missing Translations

The system gracefully falls back to:
1. Hardcoded content in prophet classes
2. Empty strings or default messages
3. Error logging for debugging

## Performance Considerations

- **Caching**: Files are cached after first load
- **Lazy Loading**: Content is loaded only when needed
- **Memory**: JSON files are small and cached efficiently
- **Startup**: No impact on app startup time

This system provides a scalable, maintainable approach to prophet localization that keeps personality content organized and easy to manage!
