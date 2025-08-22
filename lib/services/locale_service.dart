import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui' as ui;

class LocaleService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _localeKey = 'selected_locale';
  
  // Singleton pattern
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();
  
  Locale _currentLocale = _getSystemLocaleOrDefault(); // Default to system locale or English
  
  Locale get currentLocale => _currentLocale;
  
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('it'), // Italian
  ];
  
  /// Gets the system locale if supported, otherwise returns English as default
  static Locale _getSystemLocaleOrDefault() {
    // Get the system locale
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    
    // Check if the system locale is supported
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }
    
    // If system locale is not supported, default to English
    return const Locale('en');
  }
  
  Future<void> loadSavedLocale() async {
    try {
      final savedLocale = await _storage.read(key: _localeKey);
      if (savedLocale != null) {
        _currentLocale = Locale(savedLocale);
      } else {
        // If no saved locale, use system locale or default to English
        _currentLocale = _getSystemLocaleOrDefault();
      }
      notifyListeners();
    } catch (e) {
      // If there's an error reading, use system locale or default to English
      _currentLocale = _getSystemLocaleOrDefault();
      notifyListeners();
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    if (supportedLocales.contains(locale) && _currentLocale != locale) {
      _currentLocale = locale;
      
      try {
        await _storage.write(key: _localeKey, value: locale.languageCode);
      } catch (e) {
        // Handle storage error gracefully
      }
      
      notifyListeners();
    }
  }
  
  /// Resets the locale to system default (or English if system locale is not supported)
  Future<void> resetToSystemLocale() async {
    final systemLocale = _getSystemLocaleOrDefault();
    await setLocale(systemLocale);
  }
  
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'it':
        return 'Italiano';
      default:
        return languageCode.toUpperCase();
    }
  }
  
  String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'it':
        return '🇮🇹';
      default:
        return '🌐';
    }
  }
}
