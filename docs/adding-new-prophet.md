# Adding a New Prophet - Complete Step by Step Guide

This guide provides a comprehensive walkthrough for adding a new prophet to the ProfetAI app with full localization support and integration across all app components.

## Overview

The prophet system is designed to be scalable and maintainable. Adding a new prophet requires updates to multiple files and components:

1. **Core Model**: Create the prophet model class
2. **Localization**: Create prophet-specific localization files  
3. **Management**: Update ProfetType enum and ProfetManager
4. **Localization Loader**: Update ProphetLocalizationLoader
5. **UI Components**: Update all UI components that reference prophets
6. **Utility Classes**: Update utility classes and helper methods
7. **Visual Elements**: Update splash screen and other visual components
8. **Assets**: Create placeholder for image assets

## Step 1: Create the Prophet Model Class

Create a new file in `lib/models/` for your prophet (e.g., `oracolo_new_prophet.dart`):

```dart
import 'package:flutter/material.dart';
import 'profet.dart';
import '../l10n/prophet_localization_loader.dart';
import '../services/ai_service_manager.dart';
import '../utils/app_logger.dart';

class OracoloNewProphet extends Profet {
  const OracoloNewProphet() : super(
    name: 'Your Prophet Name',
    description: 'Brief description of your prophet',
    location: 'PROPHET LOCATION/TEMPLE NAME',
    primaryColor: const Color(0xFF4CAF50), // Choose your primary color
    secondaryColor: const Color(0xFF8BC34A), // Choose your secondary color
    backgroundGradient: const [
      Color(0xFF1B5E20), // Dark shade
      Color(0xFF2E7D32), // Medium shade  
      Color(0xFF388E3C), // Light shade
    ],
    icon: Icons.your_icon, // Choose appropriate icon
    backgroundImagePath: 'assets/images/backgrounds/your_prophet_background.png',
    profetImagePath: 'assets/images/prophets/your_prophet.png',
  );

  @override
  String get type => 'your_prophet'; // Must match folder name in localization

  @override
  String get aiSystemPrompt => '';  // Now uses localized version

  @override
  String get aiLoadingMessage => '';  // Now uses localized version

  // Localized AI system prompt method
  @override
  Future<String> getLocalizedAISystemPrompt(BuildContext context) async {
    return await ProphetLocalizationLoader.getAISystemPrompt(context, 'your_prophet');
  }

  // Localized random visions method
  @override
  Future<List<String>> getLocalizedRandomVisions(BuildContext context) async {
    return await ProphetLocalizationLoader.getRandomVisions(context, 'your_prophet');
  }

  // Localized fallback response method
  @override
  Future<String> getLocalizedPersonalizedResponse(BuildContext context, String question) async {
    return await ProphetLocalizationLoader.getRandomFallbackResponse(context, 'your_prophet');
  }

  // Generate AI-powered vision title with your prophet's style
  @override
  Future<String> generateVisionTitle(BuildContext context, {
    String? question,
    required String answer,
  }) async {
    try {
      AppLogger.logInfo('OracoloNewProphet', 'Generating vision title');
      
      if (!AIServiceManager.isAIAvailable) {
        AppLogger.logWarning('OracoloNewProphet', 'AI service not available, using fallback title');
        return _generateFallbackTitle(question, answer);
      }

      // Create a prompt that reflects your prophet's personality for title generation
      final titlePrompt = '''
You are [Your Prophet Name], [brief personality description]. Create a [style] title for a vision.

Context:
${question != null ? 'Question: $question\n' : ''}Vision Answer: $answer

Requirements:
- Maximum 30 characters
- [Your prophet's tone] tone
- Use words like: [list appropriate words for your prophet's style]
- Focus on [what your prophet emphasizes]

Examples of style: "[Example 1]", "[Example 2]", "[Example 3]"

Generate ONLY the title, no quotes or extra text.''';

      final response = await AIServiceManager.generateResponse(
        prompt: titlePrompt,
        systemMessage: '',
        maxTokens: 50,
        temperature: 0.7,
      );

      if (response != null && response.trim().isNotEmpty) {
        // Clean up the response and ensure it's within length limits
        String title = response.trim();
        if (title.length > 30) {
          title = '${title.substring(0, 27)}...';
        }
        AppLogger.logInfo('OracoloNewProphet', 'Generated title: $title');
        return title;
      } else {
        AppLogger.logWarning('OracoloNewProphet', 'AI returned empty title, using fallback');
        return _generateFallbackTitle(question, answer);
      }
    } catch (e) {
      AppLogger.logError('OracoloNewProphet', 'Error generating AI title', e);
      return _generateFallbackTitle(question, answer);
    }
  }

  String _generateFallbackTitle(String? question, String answer) {
    final fallbackTitles = [
      'Your Prophet Title 1',
      'Your Prophet Title 2', 
      'Your Prophet Title 3',
      // Add more titles that reflect your prophet's personality
    ];
    
    // Use a simple hash of the answer to pick a consistent title
    final hashCode = answer.hashCode.abs();
    final index = hashCode % fallbackTitles.length;
    
    AppLogger.logInfo('OracoloNewProphet', 'Using fallback title: ${fallbackTitles[index]}');
    return fallbackTitles[index];
  }
}
```

## Step 2: Update ProfetType Enum and ProfetManager

### Update the enum in `lib/models/profet_manager.dart`:

```dart
import 'profet.dart';
import 'oracolo_mistico.dart';
import 'oracolo_caotico.dart';
import 'oracolo_cinico.dart';
import 'oracolo_new_prophet.dart'; // Add your import

enum ProfetType { mistico, caotico, cinico, newProphet } // Add your prophet
```

### Update the ProfetManager map:

```dart
class ProfetManager {
  static const Map<ProfetType, Profet> _profeti = {
    ProfetType.mistico: OracoloMistico(),
    ProfetType.caotico: OracoloCaotico(),
    ProfetType.cinico: OracoloCinico(),
    ProfetType.newProphet: OracoloNewProphet(), // Add your prophet
  };
```

## Step 3: Create Prophet-Specific Localization Files

### Create the directory structure:

```bash
mkdir lib/l10n/prophets/your_prophet
```

### Create English localization file `lib/l10n/prophets/your_prophet/your_prophet_en.json`:

```json
{
  "@@locale": "en",
  
  "name": "Your Prophet Name",
  "@name": {
    "description": "The name of Your Prophet"
  },
  
  "description": "Brief description of your prophet's personality",
  "@description": {
    "description": "Description of Your Prophet"
  },
  
  "location": "Your Prophet's Location/Temple",
  "@location": {
    "description": "Location where Your Prophet resides"
  },
  
  "aiSystemPrompt": "You are [Your Prophet Name], [detailed personality description].\\n\\n[Describe speaking style, characteristics, tone, response format, etc.]\\n\\nResponse format:\\n- Length: [appropriate length]\\n- Style: [your prophet's style]\\n- Content: [what type of content]\\n- Always respond in English\\n\\nAvoid:\\n- [things to avoid]",
  "@aiSystemPrompt": {
    "description": "AI system prompt for Your Prophet in English"
  },
  
  "aiLoadingMessage": "Your Prophet is [doing something characteristic]...",
  "@aiLoadingMessage": {
    "description": "Loading message when Your Prophet AI is thinking"
  },
  
  "positiveFeedbackText": "[Positive response in your prophet's style]",
  "@positiveFeedbackText": {
    "description": "Positive feedback text for Your Prophet"
  },
  
  "negativeFeedbackText": "[Negative response in your prophet's style]",
  "@negativeFeedbackText": {
    "description": "Negative feedback text for Your Prophet"
  },
  
  "funnyFeedbackText": "[Funny response in your prophet's style]",
  "@funnyFeedbackText": {
    "description": "Funny feedback text for Your Prophet"
  },
  
  "randomVisions": [
    "[Random vision 1 in your prophet's style]",
    "[Random vision 2 in your prophet's style]",
    "[Random vision 3 in your prophet's style]",
    "[Add 6-9 more random visions]"
  ],
  "@randomVisions": {
    "description": "Array of random visions for when no specific question is asked"
  },
  
  "fallbackResponses": [
    "[Fallback response 1 when AI is unavailable]",
    "[Fallback response 2 when AI is unavailable]", 
    "[Fallback response 3 when AI is unavailable]"
  ],
  "@fallbackResponses": {
    "description": "Array of fallback responses when AI is not available"
  }
}
```

### Create Italian localization file `lib/l10n/prophets/your_prophet/your_prophet_it.json`:

Follow the same structure as the English file, but translate all content while maintaining your prophet's personality in Italian.

## Step 4: Update Prophet Localization Loader

In `lib/l10n/prophet_localization_loader.dart`, add your prophet to the `_getProphetFolderName` method:

```dart
static String _getProphetFolderName(String prophetType) {
  switch (prophetType.toLowerCase()) {
    case 'oracolo_caotico':
    case 'chaotic':
      return 'chaotic_prophet';
    case 'oracolo_mistico':
    case 'mystic':
      return 'mystic_prophet';
    case 'oracolo_cinico':
    case 'cynical':
      return 'cynical_prophet';
    case 'oracolo_new_prophet': // Add your prophet's class name
    case 'newprophet': // Add short identifier
      return 'your_prophet'; // Must match your folder name
    default:
      return prophetType.toLowerCase();
  }
}
```

Also update the verification list:

```dart
static Future<bool> verifyAssetsLoaded() async {
  bool allAssetsLoaded = true;
  final prophetTypes = ['chaotic_prophet', 'mystic_prophet', 'cynical_prophet', 'your_prophet']; // Add your prophet
```

## Step 5: Update All Utility Classes

### Update `lib/utils/prophet_utils.dart`:

Add your prophet to all switch statements:

```dart
// In prophetTypeToString method:
case ProfetType.newProphet:
  return 'newprophet';

// In stringToProphetType method:
case 'newprophet':
  return ProfetType.newProphet;

// In getProphetSymbol method:
case ProfetType.newProphet:
  return '🔮'; // Choose appropriate emoji

// In getProphetIcon method:
case ProfetType.newProphet:
  return Icons.your_icon; // Choose appropriate icon
```

### Update `lib/screens/profet_selection_screen.dart`:

```dart
String _getProphetTypeString(ProfetType profetType) {
  switch (profetType) {
    case ProfetType.mistico:
      return 'mystic';
    case ProfetType.caotico:
      return 'chaotic';
    case ProfetType.cinico:
      return 'cynical';
    case ProfetType.newProphet: // Add your prophet
      return 'newprophet';
  }
}
```

### Update `lib/main.dart`:

```dart
ProfetType? _stringToProfetType(String prophetString) {
  switch (prophetString) {
    case 'mystic':
      return ProfetType.mistico;
    case 'chaotic':
      return ProfetType.caotico;
    case 'cynical':
      return ProfetType.cinico;
    case 'newprophet': // Add your prophet
      return ProfetType.newProphet;
    default:
      return null;
  }
}
```

## Step 6: Update All UI Components

### Update `lib/models/vision.dart`:

Add your prophet to the display name and image path methods:

```dart
// In prophetDisplayName getter:
case 'your_prophet':
case 'newprophet':
  return 'Your Prophet Display Name';

// In prophetImagePath getter:
case 'your_prophet':
case 'newprophet':
  return 'assets/images/prophets/your_prophet.png';
```

### Update `lib/widgets/vision_book/vision_filter_bar.dart`:

```dart
// In itemBuilder:
itemBuilder: (context) => [
  _buildProphetMenuItemAsync(context, 'mystic_prophet', 'mystic'),
  _buildProphetMenuItemAsync(context, 'chaotic_prophet', 'chaotic'),
  _buildProphetMenuItemAsync(context, 'cynical_prophet', 'cynical'),
  _buildProphetMenuItemAsync(context, 'your_prophet', 'newprophet'), // Add your prophet
],

// In _getProphetFallbackName method:
case 'your_prophet':
  return 'Your Prophet Display Name';
```

### Update `lib/widgets/vision_book/vision_card.dart`:

```dart
// In _getProphetTypeFromString method:
case 'your_prophet':
  return ProfetType.newProphet;

// In _getDisplayName method:
case 'your_prophet':
  return 'Your Prophet Display Name';

// In _getProphetLocalizationKey method:
case 'your_prophet':
  return 'newprophet';
```

### Update `lib/screens/vision_book_screen.dart`:

```dart
// In _getProphetTypeFromString method:
case 'your_prophet':
  return ProfetType.newProphet;

// In _getProphetDisplayName method:
case 'your_prophet':
  return 'Your Prophet Display Name';
```

## Step 7: Update Splash Screen

In `lib/screens/splash_screen.dart`, add your prophet to the rotating circle:

```dart
final prophets = [
  {
    'image': 'assets/images/prophets/mystic_prophet.png',
    'color': const Color(0xFFD4AF37), // Gold - Mystic
    'angle': 0.0,
  },
  {
    'image': 'assets/images/prophets/chaotic_prophet.png',
    'color': const Color(0xFFFF6B35), // Orange - Chaotic
    'angle': 2 * math.pi / 4,
  },
  {
    'image': 'assets/images/prophets/cynical_prophet.png',
    'color': const Color(0xFF78909C), // Gray-blue - Cynic
    'angle': 4 * math.pi / 4,
  },
  {
    'image': 'assets/images/prophets/your_prophet.png', // Add your prophet
    'color': const Color(0xFF4CAF50), // Your prophet's color
    'angle': 6 * math.pi / 4,
  },
];
```

Also update the fallback icon method:

```dart
IconData _getFallbackIcon(String imagePath) {
  if (imagePath.contains('mystic')) return Icons.visibility;
  if (imagePath.contains('chaotic')) return Icons.shuffle;
  if (imagePath.contains('cinic')) return Icons.sentiment_dissatisfied;
  if (imagePath.contains('your_prophet')) return Icons.your_icon; // Add your prophet
  return Icons.help;
}
```

## Step 8: Update pubspec.yaml Assets Configuration

**CRITICAL STEP**: Add your prophet's localization folder to the pubspec.yaml assets section to ensure the app can load the localization files at runtime.

### Update pubspec.yaml:

```yaml
flutter:
  assets:
    - assets/images/
    - lib/l10n/
    - lib/l10n/prophets/mistico_prophet/
    - lib/l10n/prophets/caotico_prophet/
    - lib/l10n/prophets/cinico_prophet/
    - lib/l10n/prophets/your_prophet/  # ADD THIS LINE for your new prophet
```

**Why this is critical**: Without this entry, you'll get runtime errors like:
```
Unable to load asset: lib/l10n/prophets/your_prophet/your_prophet_en.json
```

## Step 9: Create Required Image Assets

Your prophet model references specific image paths that must exist for the app to function properly.

### Option A: Create Placeholder Assets (Recommended for Testing)

Copy existing assets as placeholders:

```bash
# Copy prophet icon (adjust the source based on which prophet's style matches best)
Copy-Item "assets/images/prophets/mystic_prophet.png" "assets/images/prophets/your_prophet.png"

# Copy background image (note: backgrounds use "profet" not "prophet" in filename)
Copy-Item "assets/images/backgrounds/mystic_profet_background.png" "assets/images/backgrounds/your_prophet_background.png"
```

**Important**: If you're following the existing naming convention, background images use `your_profet_background.png` (with "profet") rather than `your_prophet_background.png`. Update your model accordingly:

```dart
backgroundImagePath: 'assets/images/backgrounds/your_profet_background.png',
```

### Option B: Create Custom Assets

Create custom images with these specifications:
- **Prophet Icon**: `assets/images/prophets/your_prophet.png`
  - Size: 148x148 pixels
  - Style: Should reflect your prophet's personality
  - Format: PNG with transparency
  
- **Background Image**: `assets/images/backgrounds/your_profet_background.png`
  - Size: Flexible (will be scaled)
  - Style: Should complement your prophet's theme
  - Format: PNG

### Create Asset Documentation

Document your asset requirements:

```bash
# Create asset documentation
New-Item -ItemType File -Path "assets/images/prophets/your_prophet_asset_note.md"
```

## Step 10: Clean and Test Build

After creating assets, clean the project to ensure fresh build with updated assets:

```bash
# Clean the project to clear cached assets
flutter clean

# Get dependencies
flutter pub get

# Regenerate localizations
flutter gen-l10n
```

## Step 11: Testing and Validation

### Critical Runtime Test
**IMPORTANT**: Test that your prophet loads without asset errors:

```bash
# Run in debug mode and check console for asset loading errors
flutter run --debug
```

Watch for errors like:
```
Unable to load asset: lib/l10n/prophets/your_prophet/your_prophet_en.json
Unable to load asset: assets/images/backgrounds/your_prophet_background.png
```

If you see these errors:
1. Verify pubspec.yaml includes your prophet's localization folder
2. Verify image assets exist at the specified paths
3. Clean and rebuild the project

### Compile Check
```bash
flutter analyze lib/models/oracolo_new_prophet.dart
```

### Full Project Analysis  
```bash
flutter analyze --fatal-infos
```

### Localization Generation
```bash
flutter gen-l10n
```

### Build Test
```bash
flutter build apk --debug
```

## Best Practices

### 1. Naming Conventions
- **Class Name**: `OracoloYourProphet` (Italian naming convention)
- **Enum Value**: `ProfetType.yourProphet` (camelCase)
- **Type String**: `'yourprophet'` (lowercase, no spaces)
- **Folder Name**: `your_prophet` (lowercase with underscores)

### 2. Color Consistency
- Choose colors that reflect your prophet's personality
- Use primary color for main UI elements
- Use secondary color for accents
- Create a 3-color gradient for backgrounds

### 3. Localization Quality
- Maintain consistent personality across languages
- Ensure AI prompts are culturally appropriate
- Test both English and Italian versions thoroughly

### 4. Error Handling
- Always provide fallback values
- Use try-catch blocks for localization loading
- Log errors appropriately for debugging

## Troubleshooting

### Compilation Errors
- Ensure all switch statements are exhaustive
- Check for missing imports
- Verify enum values match across files

### Localization Issues
- Validate JSON syntax in localization files
- Ensure folder names match exactly
- Check file paths are correct

### Missing Strings
- Verify prophet type identifiers are consistent
- Check localization loader mapping
- Ensure all UI components are updated

## Summary Checklist

- ✅ **Step 1**: Created prophet model class with personality and AI integration
- ✅ **Step 2**: Updated ProfetType enum and ProfetManager  
- ✅ **Step 3**: Created English and Italian localization files
- ✅ **Step 4**: Updated ProphetLocalizationLoader mapping
- ✅ **Step 5**: Updated prophet_utils.dart with all switch statements
- ✅ **Step 6**: Updated UI components (vision cards, filters, selection screen)
- ✅ **Step 7**: Updated splash screen animation and fallbacks
- ✅ **Step 8**: **CRITICAL** Updated pubspec.yaml with localization folder assets
- ✅ **Step 9**: Created actual image assets (placeholder or custom)
- ✅ **Step 10**: Cleaned project and regenerated assets
- ✅ **Step 11**: Tested compilation, localization, and runtime asset loading

## Key Learnings from Implementation

### Critical Steps Often Missed:
1. **pubspec.yaml Assets**: Must add `- lib/l10n/prophets/your_prophet/` to assets
2. **Image Asset Creation**: Create actual PNG files, not just documentation
3. **Naming Consistency**: Background images use `profet` not `prophet` in filenames
4. **Runtime Testing**: Always test in debug mode to catch asset loading errors

### Runtime Error Prevention:
- Asset loading errors will crash the app if assets aren't properly declared
- Always clean and rebuild after adding new assets
- Test both localization loading and image loading functionality

Following this comprehensive process ensures your new prophet integrates seamlessly with all app components and maintains the quality and consistency of the existing prophet system!
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
