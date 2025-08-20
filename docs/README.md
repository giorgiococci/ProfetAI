# Orakl Documentation

This folder contains comprehensive guides for maintaining and extending the Orakl application.

## 📚 Available Guides

### [Adding a New Prophet](./adding-new-prophet.md)
Complete step-by-step guide for adding new oracle personalities to the app with full localization support.

**What you'll learn:**
- Creating prophet model classes
- Adding localization strings to ARB files
- Updating the prophet helper system
- Regenerating localization files
- Best practices and troubleshooting

### [Adding a New Language](./adding-new-language.md)
Comprehensive guide for adding new language support to the app's internationalization system.

**What you'll learn:**
- Creating new ARB translation files
- Configuring locale support
- Translating prophet personalities
- Testing and validation procedures
- Translation best practices

### [Prophet-Specific Localization](./prophet-specific-localization.md)
Advanced guide for managing prophet-specific content including AI prompts, responses, and personality texts.

**What you'll learn:**
- Prophet-specific JSON localization files
- AI system prompt localization
- Loading messages and feedback texts
- Random visions and fallback responses
- ProphetLocalizationLoader usage

## 🏗️ Architecture Overview

The Orakl app uses a scalable localization architecture:

```
lib/
├── l10n/                          # Localization files
│   ├── app_en.arb                # English translations
│   ├── app_it.arb                # Italian translations
│   ├── app_localizations.dart    # Generated localization class
│   └── app_localizations_*.dart  # Generated locale-specific classes
├── models/                        # Prophet model classes
│   ├── profet.dart               # Base prophet class
│   ├── oracolo_mistico.dart      # Mystic Oracle
│   ├── oracolo_caotico.dart      # Chaotic Oracle
│   └── oracolo_cinico.dart       # Cynical Oracle
└── prophet_localizations.dart     # Prophet localization helper
```

## 🚀 Quick Start

### For New Prophets
1. Follow the [Adding a New Prophet](./adding-new-prophet.md) guide
2. The system is designed to be "nightmare-free" - just add your strings to ARB files and update the helper class
3. Run `flutter gen-l10n` to regenerate localization files

### For New Languages
1. Follow the [Adding a New Language](./adding-new-language.md) guide
2. Create a new ARB file with all required translations
3. Add the locale to `supportedLocales` in main.dart
4. Test thoroughly across all app features

## 🎯 Design Principles

### Scalability
The localization system is designed to scale easily:
- Adding new prophets requires minimal code changes
- New languages can be added without touching business logic
- Prophet personalities are maintained across all languages

### Maintainability
- Clear separation between model classes and localization
- Helper methods provide a clean API for accessing translations
- Comprehensive documentation prevents knowledge loss

### Consistency
- Standardized naming conventions for localization keys
- Consistent prophet personality traits across languages
- Unified approach to handling fallback values

## 🔧 Development Workflow

When extending the app:

1. **Plan First**: Decide what new content you're adding (prophet, language, or feature)
2. **Follow Guides**: Use the appropriate guide from this documentation
3. **Test Thoroughly**: Verify your changes work across all supported languages
4. **Update Docs**: Keep this documentation current with any architectural changes

## 📝 Contributing

When adding new features that require localization:

1. Add strings to **all** existing ARB files
2. Update the appropriate helper classes
3. Regenerate localization files with `flutter gen-l10n`
4. Test in all supported languages
5. Update documentation if you change the architecture

## 🐛 Troubleshooting

Common issues and solutions:

- **ARB validation errors**: Check JSON syntax and avoid invalid key names
- **Missing translations**: Compare ARB files to ensure all keys are present
- **Localization not updating**: Try `flutter clean` and regenerate
- **Prophet personalities lost**: Review translation guidelines in language guide

## 📞 Support

If you encounter issues not covered in these guides:

1. Check the troubleshooting sections in each guide
2. Verify your ARB file syntax with JSON validators
3. Test the localization generation process step by step
4. Review the existing code patterns for similar implementations

---

**Remember**: The goal is to keep the localization system simple and maintainable. When in doubt, follow the existing patterns and conventions established in the current codebase.
