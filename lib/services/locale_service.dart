import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _localeKey = 'selected_locale';
  
  Locale _currentLocale = const Locale('it'); // Default to Italian
  
  Locale get currentLocale => _currentLocale;
  
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('it'), // Italian
  ];
  
  Future<void> loadSavedLocale() async {
    try {
      final savedLocale = await _storage.read(key: _localeKey);
      if (savedLocale != null) {
        _currentLocale = Locale(savedLocale);
        notifyListeners();
      }
    } catch (e) {
      // If there's an error reading, keep the default locale
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
