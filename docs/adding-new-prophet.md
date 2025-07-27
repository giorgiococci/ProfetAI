# Adding a New Prophet - Step by Step Guide

This guide explains how to add a new prophet to the ProfetAI app with full localization support.

## Overview

The prophet localization system is designed to be scalable and maintainable. When adding a new prophet, you'll need to:

1. Create the prophet model class
2. Create prophet-specific localization files
3. Add basic UI localization strings to ARB files
4. Update the helper classes
5. Regenerate localization files

## Step 1: Create the Prophet Model Class

Create a new file in `lib/models/` for your prophet (e.g., `oracolo_nuovo.dart`):

```dart
import 'package:flutter/material.dart';
import 'profet.dart';
import '../utils/app_logger.dart';
import '../l10n/prophet_localization_loader.dart';

class OracoloNuovo extends Profet {
  const OracoloNuovo() : super(
    name: 'Oracolo Nuovo',
    description: 'L\'Oracolo Nuovo ti attende',
    location: 'REGNO DELLA SAGGEZZA',
    primaryColor: const Color(0xFF4CAF50), // Green
    secondaryColor: const Color(0xFF8BC34A), // Light green
    backgroundGradient: const [
      Color(0xFF1B5E20), // Dark green
      Color(0xFF2E7D32), // Medium green
      Color(0xFF388E3C), // Light green
    ],
    icon: Icons.psychology,
    backgroundImagePath: 'assets/images/backgrounds/new_prophet_background.png',
    profetImagePath: 'assets/images/prophets/new_prophet.png',
  );

  @override
  String get aiSystemPrompt => '''
You are the New Oracle, a prophet with [describe personality].
[Add your specific prompt here - this is the fallback]
''';

  @override
  String get aiLoadingMessage => 'The New Oracle is thinking...';

  // Localized AI system prompt method
  Future<String> getLocalizedAISystemPrompt(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getAISystemPrompt(context, 'new');
    } catch (e) {
      AppLogger.logWarning('OracoloNuovo', 'Failed to load localized AI prompt: $e');
      return aiSystemPrompt; // Fallback to hardcoded prompt
    }
  }

  // Localized loading message method
  Future<String> getLocalizedLoadingMessage(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getAILoadingMessage(context, 'new');
    } catch (e) {
      AppLogger.logWarning('OracoloNuovo', 'Failed to load localized loading message: $e');
      return aiLoadingMessage; // Fallback to hardcoded message
    }
  }

  // Override feedback texts with new prophet-themed messages
  @override
  String getPositiveFeedbackText() => 'The wisdom flows through me';
  
  @override
  String getNegativeFeedbackText() => 'The path remains shrouded';
  
  @override
  String getFunnyFeedbackText() => 'Even oracles can be surprised!';

  // Localized feedback methods
  Future<String> getLocalizedFeedbackText(BuildContext context, String feedbackType) async {
    try {
      return await ProphetLocalizationLoader.getFeedbackText(context, 'new', feedbackType);
    } catch (e) {
      AppLogger.logWarning('OracoloNuovo', 'Failed to load localized feedback: $e');
      switch (feedbackType.toLowerCase()) {
        case 'positive': return getPositiveFeedbackText();
        case 'negative': return getNegativeFeedbackText();
        case 'funny': return getFunnyFeedbackText();
        default: return getPositiveFeedbackText();
      }
    }
  }

  @override
  List<String> getRandomVisions() {
    return [
      "The future holds new wisdom for you...",
      "Ancient knowledge reveals itself slowly...",
      "The path ahead is illuminated by understanding...",
    ];
  }

  // Localized random visions method
  Future<List<String>> getLocalizedRandomVisions(BuildContext context) async {
    try {
      return await ProphetLocalizationLoader.getRandomVisions(context, 'new');
    } catch (e) {
      AppLogger.logWarning('OracoloNuovo', 'Failed to load localized visions: $e');
      return getRandomVisions(); // Fallback to hardcoded visions
    }
  }

  @override
  String getPersonalizedResponse(String question) {
    AppLogger.logInfo('OracoloNuovo', '=== getPersonalizedResponse (fallback) called ===');
    AppLogger.logInfo('OracoloNuovo', 'Question: $question');
    
    final response = 'The New Oracle contemplates your question deeply...';
    AppLogger.logInfo('OracoloNuovo', 'Fallback response: $response');
    return response;
  }

  // Localized fallback response method
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    try {
      return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'new');
    } catch (e) {
      AppLogger.logWarning('OracoloNuovo', 'Failed to load localized fallback response: $e');
      return getPersonalizedResponse(question); // Fallback to hardcoded responses
    }
  }
}
```

## Step 2: Create Prophet-Specific Localization Files

Create a new folder for your prophet's localization files:

```bash
mkdir lib/l10n/prophets/new_prophet
```

### Create Italian Localization File

Create `lib/l10n/prophets/new_prophet/new_prophet_it.json`:

```json
{
  "@@locale": "it",
  "aiSystemPrompt": "Sei l'Oracolo Nuovo, un profeta di saggezza moderna.\\nIl tuo scopo è fornire consigli saggi e illuminanti.\\n\\nLe tue caratteristiche:\\n- Parli con tono saggio ma accessibile\\n- Offri consigli pratici con profondità spirituale\\n- Le tue risposte sono equilibrate e rassicuranti\\n- Menzioni spesso la crescita personale e la comprensione\\n- Mantieni un'aura di saggezza contemporanea\\n- Rispondi sempre in italiano\\n\\nFormato delle risposte:\\n- Lunghezza: 2-3 frasi massimo\\n- Stile: Saggio e inspirante\\n- Contenuto: Consigli pratici con tocco spirituale\\n\\nEvita:\\n- Previsioni specifiche\\n- Consigli medici o legali\\n- Eccessiva complessità\\n- Linguaggio troppo antico",
  "@aiSystemPrompt": {
    "description": "AI system prompt for the New Oracle in Italian"
  },
  
  "aiLoadingMessage": "L'Oracolo Nuovo sta contemplando i misteri...",
  "@aiLoadingMessage": {
    "description": "Loading message when New Oracle AI is thinking"
  },
  
  "positiveFeedbackText": "La saggezza scorre attraverso di me",
  "@positiveFeedbackText": {
    "description": "Positive feedback text for New Oracle"
  },
  
  "negativeFeedbackText": "Il sentiero rimane velato",
  "@negativeFeedbackText": {
    "description": "Negative feedback text for New Oracle"
  },
  
  "funnyFeedbackText": "Anche gli oracoli possono essere sorpresi!",
  "@funnyFeedbackText": {
    "description": "Funny feedback text for New Oracle"
  },
  
  "randomVisions": [
    "Il futuro porta nuova saggezza per te...",
    "L'antica conoscenza si rivela lentamente...",
    "Il cammino davanti è illuminato dalla comprensione...",
    "Le energie dell'universo convergono verso nuove opportunità...",
    "La crescita personale è il tuo destino manifesto...",
    "I semi della saggezza stanno germogliando nella tua vita..."
  ],
  "@randomVisions": {
    "description": "Array of random visions for when no specific question is asked"
  },
  
  "fallbackResponses": [
    "🔮 L'Oracolo Nuovo contempla profondamente la tua domanda... La saggezza moderna suggerisce di guardare dentro te stesso per trovare la risposta che già possiedi. La crescita viene dall'interno.",
    "✨ I tempi moderni richiedono saggezza antica... La verità è che ogni sfida è un'opportunità di crescita. Abbraccia il cambiamento con fiducia nel tuo potenziale.",
    "🌟 La tua domanda tocca corde profonde dell'esistenza... Ricorda che la vera illuminazione nasce quando unisci saggezza antica e comprensione moderna. Trova il tuo equilibrio."
  ],
  "@fallbackResponses": {
    "description": "Array of fallback responses when AI is not available"
  }
}
```

### Create English Localization File

Create `lib/l10n/prophets/new_prophet/new_prophet_en.json`:

```json
{
  "@@locale": "en",
  "aiSystemPrompt": "You are the New Oracle, a prophet of modern wisdom.\\nYour purpose is to provide wise and enlightening advice.\\n\\nYour characteristics:\\n- You speak with a wise but accessible tone\\n- You offer practical advice with spiritual depth\\n- Your responses are balanced and reassuring\\n- You often mention personal growth and understanding\\n- You maintain an aura of contemporary wisdom\\n- You always respond in English\\n\\nResponse format:\\n- Length: 2-3 sentences maximum\\n- Style: Wise and inspiring\\n- Content: Practical advice with spiritual touch\\n\\nAvoid:\\n- Specific predictions\\n- Medical or legal advice\\n- Excessive complexity\\n- Overly ancient language",
  "@aiSystemPrompt": {
    "description": "AI system prompt for the New Oracle in English"
  },
  
  "aiLoadingMessage": "The New Oracle is contemplating the mysteries...",
  "@aiLoadingMessage": {
    "description": "Loading message when New Oracle AI is thinking"
  },
  
  "positiveFeedbackText": "The wisdom flows through me",
  "@positiveFeedbackText": {
    "description": "Positive feedback text for New Oracle"
  },
  
  "negativeFeedbackText": "The path remains shrouded",
  "@negativeFeedbackText": {
    "description": "Negative feedback text for New Oracle"
  },
  
  "funnyFeedbackText": "Even oracles can be surprised!",
  "@funnyFeedbackText": {
    "description": "Funny feedback text for New Oracle"
  },
  
  "randomVisions": [
    "The future holds new wisdom for you...",
    "Ancient knowledge reveals itself slowly...",
    "The path ahead is illuminated by understanding...",
    "The universe's energies converge toward new opportunities...",
    "Personal growth is your manifest destiny...",
    "Seeds of wisdom are sprouting in your life..."
  ],
  "@randomVisions": {
    "description": "Array of random visions for when no specific question is asked"
  },
  
  "fallbackResponses": [
    "🔮 The New Oracle contemplates your question deeply... Modern wisdom suggests looking within yourself to find the answer you already possess. Growth comes from within.",
    "✨ Modern times require ancient wisdom... The truth is that every challenge is an opportunity for growth. Embrace change with confidence in your potential.",
    "🌟 Your question touches deep chords of existence... Remember that true enlightenment comes when you unite ancient wisdom with modern understanding. Find your balance."
  ],
  "@fallbackResponses": {
    "description": "Array of fallback responses when AI is not available"
  }
}
```

## Step 3: Add Basic UI Localization Strings to ARB Files

### English ARB File (`lib/l10n/app_en.arb`)

Add these entries to the English ARB file:

```json
{
  "prophetNewName": "New Oracle",
  "@prophetNewName": {
    "description": "Name of the New Oracle prophet"
  },
  
  "prophetNewDescription": "The New Oracle awaits your questions",
  "@prophetNewDescription": {
    "description": "Description of the New Oracle"
  },
  
  "prophetNewLocation": "REALM OF WISDOM",
  "@prophetNewLocation": {
    "description": "Location title for New Oracle"
  },
  
  "prophetNewLoadingMessage": "The New Oracle is contemplating the mysteries...",
  "@prophetNewLoadingMessage": {
    "description": "Loading message when New Oracle is thinking"
  },
  
  "prophetNewPositiveFeedback": "The wisdom flows through me",
  "@prophetNewPositiveFeedback": {
    "description": "Positive feedback for New Oracle"
  },
  
  "prophetNewNegativeFeedback": "The path remains shrouded",
  "@prophetNewNegativeFeedback": {
    "description": "Negative feedback for New Oracle"
  },
  
  "prophetNewFunnyFeedback": "Even oracles can be surprised!",
  "@prophetNewFunnyFeedback": {
    "description": "Funny feedback for New Oracle"
  }
}
```

### Italian ARB File (`lib/l10n/app_it.arb`)

Add the corresponding Italian translations:

```json
{
  "prophetNewName": "Oracolo Nuovo",
  "@prophetNewName": {
    "description": "Name of the New Oracle prophet"
  },
  
  "prophetNewDescription": "L'Oracolo Nuovo attende le tue domande",
  "@prophetNewDescription": {
    "description": "Description of the New Oracle"
  },
  
  "prophetNewLocation": "REGNO DELLA SAGGEZZA",
  "@prophetNewLocation": {
    "description": "Location title for New Oracle"
  },
  
  "prophetNewLoadingMessage": "L'Oracolo Nuovo sta contemplando i misteri...",
  "@prophetNewLoadingMessage": {
    "description": "Loading message when New Oracle is thinking"
  },
  
  "prophetNewPositiveFeedback": "La saggezza scorre attraverso di me",
  "@prophetNewPositiveFeedback": {
    "description": "Positive feedback for New Oracle"
  },
  
  "prophetNewNegativeFeedback": "Il sentiero rimane velato",
  "@prophetNewNegativeFeedback": {
    "description": "Negative feedback for New Oracle"
  },
  
  "prophetNewFunnyFeedback": "Anche gli oracoli possono essere sorpresi!",
  "@prophetNewFunnyFeedback": {
    "description": "Funny feedback for New Oracle"
  }
}
```

## Step 3: Update the Prophet Localizations Helper

Edit `lib/prophet_localizations.dart` and add the new prophet to each method:

### In `getName()` method:
```dart
case 'oracolo_nuovo':
case 'new':
  return l10n.prophetNewName;
```

### In `getDescription()` method:
```dart
case 'oracolo_nuovo':
case 'new':
  return l10n.prophetNewDescription;
```

### In `getLocation()` method:
```dart
case 'oracolo_nuovo':
case 'new':
  return l10n.prophetNewLocation;
```

### In `getLoadingMessage()` method:
```dart
case 'oracolo_nuovo':
case 'new':
  return l10n.prophetNewLoadingMessage;
```

### In `getFeedback()` method:
```dart
case 'oracolo_nuovo':
case 'new':
  switch (feedbackType.toLowerCase()) {
    case 'positive':
      return l10n.prophetNewPositiveFeedback;
    case 'negative':
      return l10n.prophetNewNegativeFeedback;
    case 'funny':
      return l10n.prophetNewFunnyFeedback;
    default:
      return l10n.prophetNewPositiveFeedback;
  }
```

## Step 4: Regenerate Localization Files

Run the Flutter localization generation command:

```bash
flutter gen-l10n
```

This will automatically generate the new getters (`prophetNewName`, `prophetNewDescription`, etc.) in the `AppLocalizations` class.

## Step 5: Update Prophet Manager

Add your new prophet to the `ProfetManager` class in `lib/models/profet_manager.dart`:

```dart
static final List<Profet> _prophets = [
  OracoloMistico(),
  OracoloCaotico(),
  OracoloCinico(),
  OracoloNuovo(), // Add your new prophet here
];
```

## Step 6: Use Localized Strings in UI

When displaying prophet information in your UI, use the helper methods:

```dart
// In your widget
String prophetName = ProphetLocalizations.getName(context, 'oracolo_nuovo');
String prophetDescription = ProphetLocalizations.getDescription(context, 'new');
String loadingMessage = ProphetLocalizations.getLoadingMessage(context, 'new');
```

## Best Practices

### 1. Naming Convention
- Use `prophet[Name][Property]` format for ARB keys
- Examples: `prophetMysticName`, `prophetChaoticDescription`, `prophetCynicalLoadingMessage`

### 2. Prophet Type Identifiers
- Support both Italian class names (`oracolo_mistico`) and English short names (`mystic`)
- Always use lowercase comparison in switch statements

### 3. Fallback Values
- Always provide fallback values in the helper methods
- Use meaningful default messages that won't break the UI

### 4. Testing
- Test the new prophet in both languages
- Verify all strings display correctly
- Check loading messages and feedback work properly

## Troubleshooting

### ARB Validation Errors
- Ensure all keys are valid Dart method names (camelCase, no underscores at start)
- Don't use comment entries like `"_comment": "..."`
- Verify JSON syntax is correct

### Missing Getters
- If `flutter gen-l10n` doesn't generate expected getters, check ARB file syntax
- Ensure both `app_en.arb` and `app_it.arb` have matching keys
- Try `flutter clean` and regenerate if needed

### Localization Not Working
- Verify the import path in `prophet_localizations.dart` is correct
- Check that `AppLocalizations.of(context)` is not null
- Ensure the context has access to localization delegates

## Summary

Adding a new prophet involves:
1. ✅ Create prophet model class with localized methods
2. ✅ Create prophet-specific JSON localization files
3. ✅ Add basic UI strings to both ARB files
4. ✅ Update ProphetLocalizationLoader helper
5. ✅ Update ProphetLocalizations helper class methods
6. ✅ Run `flutter gen-l10n`
7. ✅ Update prophet manager
8. ✅ Use localized strings in UI

Following this process ensures your new prophet will work seamlessly with both the basic and advanced localization systems!
