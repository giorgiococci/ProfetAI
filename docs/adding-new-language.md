# Adding a New Language - Step by Step Guide

This guide explains how to add a new language to the ProfetAI app's localization system.

## Overview

The ProfetAI app uses a dual localization system:

1. **Flutter i18n with ARB files** for UI text (buttons, labels, titles)
2. **Prophet-specific JSON files** for AI prompts and responses

Currently supported languages are:
- English (en)
- Italian (it)

Adding a new language involves:
- Creating new ARB files for UI text
- Creating prophet-specific JSON files for AI content
- Updating configuration
- Testing the complete localization system

## Step 1: Create New ARB File

Create a new ARB file for your language in the `lib/l10n/` directory.

### Example: Adding Spanish (es)

Create `lib/l10n/app_es.arb`:

```json
{
  "@@locale": "es",
  "appTitle": "Orakl",
  "@appTitle": {
    "description": "Application title"
  },
  
  "selectYourOracle": "SELECCIONA TU ORÁCULO",
  "@selectYourOracle": {
    "description": "Title for oracle selection screen"
  },
  
  "everyOracleUniquePersonality": "Cada oráculo tiene su personalidad única",
  "@everyOracleUniquePersonality": {
    "description": "Subtitle for oracle selection screen"
  }
}
```

### Required Sections to Translate

Your new ARB file must include translations for all these sections:

#### 1. Basic UI Elements
- `appTitle`, `selectYourOracle`, `everyOracleUniquePersonality`
- `askTheOracle`, `listenToOracle`
- `ok`, `yes`, `no`

#### 2. Question and Response Interface
- `enterQuestionPlaceholder`, `enterQuestionFirst`
- `oracleResponds`, `visionOf`
- `positiveResponse`, `negativeResponse`, `funnyResponse`

#### 3. AI Status Screen
- `aiStatus`, `aiServiceStatus`, `configurationStatus`
- `aiServiceOperational`, `aiServiceNotAvailable`
- `configured`, `notConfigured`, `aiAvailable`
- `endpoint`, `apiKey`, `deployment`, `aiEnabled`

#### 4. Loading and Error Messages
- `loadingProphetsFromUniverse`
- `initializationError`, `failedToInitializeApp`
- `runtimeLogsCleared`, `debugInfoCopied`

#### 5. Prophet-Specific Strings
For each prophet (Mystic, Chaotic, Cynical), translate:
- `prophetMysticName`, `prophetMysticDescription`, `prophetMysticLocation`
- `prophetMysticLoadingMessage`
- `prophetMysticPositiveFeedback`, `prophetMysticNegativeFeedback`, `prophetMysticFunnyFeedback`

Repeat the pattern for `Chaotic` and `Cynical` prophets.

## Step 2: Update l10n.yaml Configuration

The `l10n.yaml` file automatically detects new ARB files, so no changes are typically needed. However, verify your configuration:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

## Step 3: Update Supported Locales

Edit `lib/main.dart` to add the new locale to `supportedLocales`:

```dart
return MaterialApp(
  title: 'Orakl',
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en', ''), // English
    Locale('it', ''), // Italian
    Locale('es', ''), // Spanish - Add your new locale here
  ],
  // ... rest of app configuration
);
```

## Step 4: Generate Localization Files

Run the Flutter localization generation command:

```bash
flutter gen-l10n
```

This will:
- Generate `app_localizations_es.dart` with Spanish translations
- Update the main `app_localizations.dart` file
- Create necessary delegate classes

## Step 5: Test the New Language

### Manual Testing
1. Change your device/simulator language to the new language
2. Restart the app
3. Verify all text appears in the correct language
4. Test all screens and functionality

### Programmatic Testing
You can test specific locales in your app by setting the locale explicitly:

```dart
MaterialApp(
  locale: const Locale('es', ''), // Force Spanish for testing
  // ... rest of configuration
);
```

## Step 6: Handle Missing Translations

### Fallback Strategy
Flutter will automatically fall back to the template language (English) if a translation is missing. However, it's best practice to provide complete translations.

### Validation
Check for missing translations by:

1. Running `flutter gen-l10n` and checking for warnings
2. Testing the app thoroughly in the new language
3. Using translation validation tools if available

## Translation Guidelines

### 1. Maintain Context
- Keep the `@description` metadata for each string
- Understand the context where the text appears
- Consider character limits for UI elements

### 2. Prophet Personalities
When translating prophet strings, maintain their distinct personalities:

- **Mystic Oracle**: Mystical, cosmic, spiritual tone
- **Chaotic Oracle**: Unpredictable, playful, confused tone  
- **Cynical Oracle**: Pessimistic, sarcastic, disillusioned tone

### 3. Placeholders
Some strings contain placeholders like `{oracleName}`. Keep these exactly as they are:

```json
"enterQuestionPlaceholder": "Haz tu pregunta a {oracleName}...",
```

### 4. Special Characters
Be careful with:
- Newline characters: `\\n`
- Quotes: Use proper escaping `\"`
- Unicode characters: Ensure proper encoding

## Example: Complete Spanish Prophet Translation

```json
{
  "prophetMysticName": "Oráculo Místico",
  "prophetMysticDescription": "El Oráculo Místico te espera",
  "prophetMysticLocation": "TEMPLO DE VISIONES",
  "prophetMysticLoadingMessage": "El Oráculo Místico está consultando las energías cósmicas...",
  "prophetMysticPositiveFeedback": "Las estrellas han guiado mi alma",
  "prophetMysticNegativeFeedback": "Las brumas cósmicas han velado la verdad",
  "prophetMysticFunnyFeedback": "Los vientos místicos han traído confusión, pero también sonrisas",

  "prophetChaoticName": "Oráculo Caótico",
  "prophetChaoticDescription": "El caos te llama... tal vez",
  "prophetChaoticLocation": "DIMENSIÓN DEL CAOS",
  "prophetChaoticLoadingMessage": "El Oráculo Caótico está... espera, ¿qué estaba haciendo?",
  "prophetChaoticPositiveFeedback": "¡El caos me ha sonreído! ¿O tal vez fue indigestión?",
  "prophetChaoticNegativeFeedback": "Incluso el caos está confundido por esta visión",
  "prophetChaoticFunnyFeedback": "¡Entendí todo y nada, perfectamente caótico!",

  "prophetCynicalName": "Oráculo Cínico",
  "prophetCynicalDescription": "La realidad es decepcionante, como siempre",
  "prophetCynicalLocation": "TORRE DE LA DESILUSIÓN",
  "prophetCynicalLoadingMessage": "El Oráculo Cínico está pensando a regañadientes...",
  "prophetCynicalPositiveFeedback": "Bueno, no fue tan terrible como esperaba",
  "prophetCynicalNegativeFeedback": "Como esperaba, otra decepción",
  "prophetCynicalFunnyFeedback": "Al menos la confusión fue entretenida"
}
```

## Troubleshooting

### Common Issues

#### 1. ARB File Syntax Errors
- Validate JSON syntax using online validators
- Ensure all strings have proper escape characters
- Check that all metadata blocks are correctly formatted

#### 2. Missing Translations
- Compare your ARB file with `app_en.arb` to ensure all keys are present
- Use diff tools to identify missing entries

#### 3. Locale Not Loading
- Verify the locale code is correct (e.g., 'es' for Spanish, 'fr' for French)
- Check that the locale is added to `supportedLocales` in main.dart
- Restart the app after adding the new locale

#### 4. Regeneration Issues
If `flutter gen-l10n` fails:
- Run `flutter clean`
- Delete generated files in `lib/l10n/`
- Run `flutter pub get`
- Try `flutter gen-l10n` again

### Validation Checklist

Before considering a new language complete:

- [ ] All strings from template file are translated
- [ ] Prophet personalities are maintained in translation
- [ ] Placeholders are preserved correctly
- [ ] JSON syntax is valid
- [ ] Locale is added to supportedLocales
- [ ] App runs without localization errors
- [ ] All screens display correctly in new language
- [ ] Loading messages work properly
- [ ] Feedback messages match prophet personalities

## Best Practices

### 1. Translation Quality
- Use native speakers when possible
- Consider cultural context and local expressions
- Maintain consistency in terminology throughout the app

### 2. File Organization
- Keep ARB files organized and well-commented
- Use consistent naming patterns
- Group related translations together

### 3. Maintenance
- Update all language files when adding new features
- Keep translations synchronized across all languages
- Regular review and updates of existing translations

## Summary

Adding a new language requires:

1. ✅ Create new ARB file with complete translations
2. ✅ Add locale to supportedLocales in main.dart
3. ✅ Run `flutter gen-l10n` to generate code
4. ✅ Test thoroughly in the new language
5. ✅ Validate all prophet personalities are maintained
6. ✅ Ensure all UI elements work correctly

Following this process ensures your new language integrates seamlessly with the existing localization system!
