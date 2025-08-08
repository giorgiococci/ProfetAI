import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../l10n/app_localizations.dart';
import 'locale_service.dart';

class UserProfileService {
  static const String _profileKey = 'user_profile';
  static const String _profileBackupKey = 'user_profile_backup';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Singleton pattern
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  UserProfile? _currentProfile;

  UserProfile? get currentProfile => _currentProfile;

  Future<void> loadProfile() async {
    print('UserProfileService: Loading user profile...');
    try {
      // Try FlutterSecureStorage first
      final profileJson = await _storage.read(key: _profileKey);
      print('UserProfileService: Secure storage profile: ${profileJson != null ? profileJson.substring(0, math.min(100, profileJson.length)) : "null"}...');
      
      if (profileJson != null) {
        try {
          final Map<String, dynamic> profileMap = jsonDecode(profileJson);
          _currentProfile = UserProfile.fromJson(profileMap);
          print('UserProfileService: ✅ Profile loaded from secure storage successfully');
          return;
        } catch (e) {
          print('UserProfileService: ❌ Error parsing secure storage profile: $e');
        }
      }
      
      // If secure storage failed, try SharedPreferences backup
      print('UserProfileService: Trying backup storage...');
      final prefs = await SharedPreferences.getInstance();
      final backupProfileJson = prefs.getString(_profileBackupKey);
      print('UserProfileService: Backup storage profile: ${backupProfileJson != null ? backupProfileJson.substring(0, math.min(100, backupProfileJson.length)) : "null"}...');
      
      if (backupProfileJson != null) {
        try {
          final Map<String, dynamic> profileMap = jsonDecode(backupProfileJson);
          _currentProfile = UserProfile.fromJson(profileMap);
          print('UserProfileService: ✅ Profile loaded from backup storage successfully');
          return;
        } catch (e) {
          print('UserProfileService: ❌ Error parsing backup storage profile: $e');
        }
      }
      
      // If both failed, create empty profile
      print('UserProfileService: No valid profile found, creating empty profile');
      _currentProfile = const UserProfile();
    } catch (e) {
      print('UserProfileService: ❌ General error loading profile: $e');
      // If there's an error loading the profile, start with an empty profile
      _currentProfile = const UserProfile();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    print('UserProfileService: Saving user profile...');
    
    final profileJson = jsonEncode(profile.toJson());
    bool secureStorageSuccess = false;
    bool sharedPrefsSuccess = false;
    
    // Try to save in FlutterSecureStorage
    try {
      await _storage.write(key: _profileKey, value: profileJson);
      
      // Verify the write
      final verification = await _storage.read(key: _profileKey);
      if (verification == profileJson) {
        print('UserProfileService: ✅ Secure storage write successful');
        secureStorageSuccess = true;
      } else {
        print('UserProfileService: ❌ Secure storage verification failed');
      }
    } catch (e) {
      print('UserProfileService: ❌ Secure storage write failed: $e');
    }
    
    // Try to save in SharedPreferences as backup
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileBackupKey, profileJson);
      
      // Verify the backup write
      final backupVerification = prefs.getString(_profileBackupKey);
      if (backupVerification == profileJson) {
        print('UserProfileService: ✅ Backup storage write successful');
        sharedPrefsSuccess = true;
      } else {
        print('UserProfileService: ❌ Backup storage verification failed');
      }
    } catch (e) {
      print('UserProfileService: ❌ Backup storage write failed: $e');
    }
    
    // Ensure at least one storage method worked
    if (!secureStorageSuccess && !sharedPrefsSuccess) {
      print('UserProfileService: 🚨 CRITICAL ERROR - Both storage methods failed!');
      throw Exception('Failed to persist user profile in both storage methods');
    }
    
    _currentProfile = profile;
    print('UserProfileService: ✅ Profile saved successfully (Secure: $secureStorageSuccess, Backup: $sharedPrefsSuccess)');
    
    // Auto-update app locale if user has selected a preferred language
    try {
      await _syncProfileLanguageWithAppLocale(profile);
    } catch (e) {
      print('UserProfileService: ⚠️ Error syncing language preference: $e');
    }
  }

  /// Automatically updates the app locale based on user's preferred language
  Future<void> _syncProfileLanguageWithAppLocale(UserProfile profile) async {
    if (profile.languages.isNotEmpty) {
      try {
        final localeService = LocaleService();
        await localeService.loadSavedLocale();
        
        final preferredLanguage = profile.languages.first;
        final preferredLocale = Locale(preferredLanguage);
        
        // Only change if it's different from current and supported
        if (LocaleService.supportedLocales.contains(preferredLocale) &&
            localeService.currentLocale != preferredLocale) {
          await localeService.setLocale(preferredLocale);
        }
      } catch (e) {
        // Silently handle locale update errors to not affect profile saving
      }
    }
  }

  Future<void> clearProfile() async {
    print('UserProfileService: Clearing user profile...');
    
    try {
      await _storage.delete(key: _profileKey);
      print('UserProfileService: ✅ Secure storage cleared');
    } catch (e) {
      print('UserProfileService: ❌ Error clearing secure storage: $e');
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileBackupKey);
      print('UserProfileService: ✅ Backup storage cleared');
    } catch (e) {
      print('UserProfileService: ❌ Error clearing backup storage: $e');
    }
    
    _currentProfile = const UserProfile();
    print('UserProfileService: ✅ Profile cleared successfully');
  }

  /// Set favorite prophet for the current user
  Future<void> setFavoriteProphet(String? prophetType) async {
    if (_currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(
        favoriteProphet: prophetType?.isEmpty == true ? null : prophetType,
      );
      await saveProfile(updatedProfile);
    }
  }

  /// Get the current favorite prophet
  String? getFavoriteProphet() {
    return _currentProfile?.favoriteProphet;
  }

  /// Check if a prophet is the favorite
  bool isFavoriteProphet(String prophetType) {
    return _currentProfile?.favoriteProphet == prophetType;
  }

  /// Debug method to check profile storage status
  Future<Map<String, dynamic>> getProfileStorageStatus() async {
    final status = <String, dynamic>{};
    
    try {
      final secureProfileJson = await _storage.read(key: _profileKey);
      status['secureStorage'] = {
        'hasData': secureProfileJson != null,
        'dataLength': secureProfileJson?.length ?? 0,
        'preview': secureProfileJson != null ? secureProfileJson.substring(0, math.min(100, secureProfileJson.length)) : null,
      };
    } catch (e) {
      status['secureStorage'] = {
        'error': e.toString(),
        'hasData': false,
      };
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupProfileJson = prefs.getString(_profileBackupKey);
      status['backupStorage'] = {
        'hasData': backupProfileJson != null,
        'dataLength': backupProfileJson?.length ?? 0,
        'preview': backupProfileJson != null ? backupProfileJson.substring(0, math.min(100, backupProfileJson.length)) : null,
      };
    } catch (e) {
      status['backupStorage'] = {
        'error': e.toString(),
        'hasData': false,
      };
    }
    
    status['currentProfile'] = {
      'isLoaded': _currentProfile != null,
      'name': _currentProfile?.name,
      'favoriteProphet': _currentProfile?.favoriteProphet,
      'lifeFocusAreas': _currentProfile?.lifeFocusAreas,
      'lifeStage': _currentProfile?.lifeStage,
    };
    
    return status;
  }

  // Static data for countries (commonly used ones)
  static List<Country> getCountries() {
    return const [
      Country(code: 'AD', name: 'Andorra'),
      Country(code: 'AE', name: 'United Arab Emirates'),
      Country(code: 'AF', name: 'Afghanistan'),
      Country(code: 'AG', name: 'Antigua and Barbuda'),
      Country(code: 'AI', name: 'Anguilla'),
      Country(code: 'AL', name: 'Albania'),
      Country(code: 'AM', name: 'Armenia'),
      Country(code: 'AO', name: 'Angola'),
      Country(code: 'AQ', name: 'Antarctica'),
      Country(code: 'AR', name: 'Argentina'),
      Country(code: 'AS', name: 'American Samoa'),
      Country(code: 'AT', name: 'Austria'),
      Country(code: 'AU', name: 'Australia'),
      Country(code: 'AW', name: 'Aruba'),
      Country(code: 'AX', name: 'Åland Islands'),
      Country(code: 'AZ', name: 'Azerbaijan'),
      Country(code: 'BA', name: 'Bosnia and Herzegovina'),
      Country(code: 'BB', name: 'Barbados'),
      Country(code: 'BD', name: 'Bangladesh'),
      Country(code: 'BE', name: 'Belgium'),
      Country(code: 'BF', name: 'Burkina Faso'),
      Country(code: 'BG', name: 'Bulgaria'),
      Country(code: 'BH', name: 'Bahrain'),
      Country(code: 'BI', name: 'Burundi'),
      Country(code: 'BJ', name: 'Benin'),
      Country(code: 'BL', name: 'Saint Barthélemy'),
      Country(code: 'BM', name: 'Bermuda'),
      Country(code: 'BN', name: 'Brunei'),
      Country(code: 'BO', name: 'Bolivia'),
      Country(code: 'BQ', name: 'Caribbean Netherlands'),
      Country(code: 'BR', name: 'Brazil'),
      Country(code: 'BS', name: 'Bahamas'),
      Country(code: 'BT', name: 'Bhutan'),
      Country(code: 'BV', name: 'Bouvet Island'),
      Country(code: 'BW', name: 'Botswana'),
      Country(code: 'BY', name: 'Belarus'),
      Country(code: 'BZ', name: 'Belize'),
      Country(code: 'CA', name: 'Canada'),
      Country(code: 'CC', name: 'Cocos (Keeling) Islands'),
      Country(code: 'CD', name: 'Democratic Republic of the Congo'),
      Country(code: 'CF', name: 'Central African Republic'),
      Country(code: 'CG', name: 'Republic of the Congo'),
      Country(code: 'CH', name: 'Switzerland'),
      Country(code: 'CI', name: 'Ivory Coast'),
      Country(code: 'CK', name: 'Cook Islands'),
      Country(code: 'CL', name: 'Chile'),
      Country(code: 'CM', name: 'Cameroon'),
      Country(code: 'CN', name: 'China'),
      Country(code: 'CO', name: 'Colombia'),
      Country(code: 'CR', name: 'Costa Rica'),
      Country(code: 'CU', name: 'Cuba'),
      Country(code: 'CV', name: 'Cape Verde'),
      Country(code: 'CW', name: 'Curaçao'),
      Country(code: 'CX', name: 'Christmas Island'),
      Country(code: 'CY', name: 'Cyprus'),
      Country(code: 'CZ', name: 'Czech Republic'),
      Country(code: 'DE', name: 'Germany'),
      Country(code: 'DJ', name: 'Djibouti'),
      Country(code: 'DK', name: 'Denmark'),
      Country(code: 'DM', name: 'Dominica'),
      Country(code: 'DO', name: 'Dominican Republic'),
      Country(code: 'DZ', name: 'Algeria'),
      Country(code: 'EC', name: 'Ecuador'),
      Country(code: 'EE', name: 'Estonia'),
      Country(code: 'EG', name: 'Egypt'),
      Country(code: 'EH', name: 'Western Sahara'),
      Country(code: 'ER', name: 'Eritrea'),
      Country(code: 'ES', name: 'Spain'),
      Country(code: 'ET', name: 'Ethiopia'),
      Country(code: 'FI', name: 'Finland'),
      Country(code: 'FJ', name: 'Fiji'),
      Country(code: 'FK', name: 'Falkland Islands'),
      Country(code: 'FM', name: 'Micronesia'),
      Country(code: 'FO', name: 'Faroe Islands'),
      Country(code: 'FR', name: 'France'),
      Country(code: 'GA', name: 'Gabon'),
      Country(code: 'GB', name: 'United Kingdom'),
      Country(code: 'GD', name: 'Grenada'),
      Country(code: 'GE', name: 'Georgia'),
      Country(code: 'GF', name: 'French Guiana'),
      Country(code: 'GG', name: 'Guernsey'),
      Country(code: 'GH', name: 'Ghana'),
      Country(code: 'GI', name: 'Gibraltar'),
      Country(code: 'GL', name: 'Greenland'),
      Country(code: 'GM', name: 'Gambia'),
      Country(code: 'GN', name: 'Guinea'),
      Country(code: 'GP', name: 'Guadeloupe'),
      Country(code: 'GQ', name: 'Equatorial Guinea'),
      Country(code: 'GR', name: 'Greece'),
      Country(code: 'GS', name: 'South Georgia and the South Sandwich Islands'),
      Country(code: 'GT', name: 'Guatemala'),
      Country(code: 'GU', name: 'Guam'),
      Country(code: 'GW', name: 'Guinea-Bissau'),
      Country(code: 'GY', name: 'Guyana'),
      Country(code: 'HK', name: 'Hong Kong'),
      Country(code: 'HM', name: 'Heard Island and McDonald Islands'),
      Country(code: 'HN', name: 'Honduras'),
      Country(code: 'HR', name: 'Croatia'),
      Country(code: 'HT', name: 'Haiti'),
      Country(code: 'HU', name: 'Hungary'),
      Country(code: 'ID', name: 'Indonesia'),
      Country(code: 'IE', name: 'Ireland'),
      Country(code: 'IL', name: 'Israel'),
      Country(code: 'IM', name: 'Isle of Man'),
      Country(code: 'IN', name: 'India'),
      Country(code: 'IO', name: 'British Indian Ocean Territory'),
      Country(code: 'IQ', name: 'Iraq'),
      Country(code: 'IR', name: 'Iran'),
      Country(code: 'IS', name: 'Iceland'),
      Country(code: 'IT', name: 'Italy'),
      Country(code: 'JE', name: 'Jersey'),
      Country(code: 'JM', name: 'Jamaica'),
      Country(code: 'JO', name: 'Jordan'),
      Country(code: 'JP', name: 'Japan'),
      Country(code: 'KE', name: 'Kenya'),
      Country(code: 'KG', name: 'Kyrgyzstan'),
      Country(code: 'KH', name: 'Cambodia'),
      Country(code: 'KI', name: 'Kiribati'),
      Country(code: 'KM', name: 'Comoros'),
      Country(code: 'KN', name: 'Saint Kitts and Nevis'),
      Country(code: 'KP', name: 'North Korea'),
      Country(code: 'KR', name: 'South Korea'),
      Country(code: 'KW', name: 'Kuwait'),
      Country(code: 'KY', name: 'Cayman Islands'),
      Country(code: 'KZ', name: 'Kazakhstan'),
      Country(code: 'LA', name: 'Laos'),
      Country(code: 'LB', name: 'Lebanon'),
      Country(code: 'LC', name: 'Saint Lucia'),
      Country(code: 'LI', name: 'Liechtenstein'),
      Country(code: 'LK', name: 'Sri Lanka'),
      Country(code: 'LR', name: 'Liberia'),
      Country(code: 'LS', name: 'Lesotho'),
      Country(code: 'LT', name: 'Lithuania'),
      Country(code: 'LU', name: 'Luxembourg'),
      Country(code: 'LV', name: 'Latvia'),
      Country(code: 'LY', name: 'Libya'),
      Country(code: 'MA', name: 'Morocco'),
      Country(code: 'MC', name: 'Monaco'),
      Country(code: 'MD', name: 'Moldova'),
      Country(code: 'ME', name: 'Montenegro'),
      Country(code: 'MF', name: 'Saint Martin'),
      Country(code: 'MG', name: 'Madagascar'),
      Country(code: 'MH', name: 'Marshall Islands'),
      Country(code: 'MK', name: 'North Macedonia'),
      Country(code: 'ML', name: 'Mali'),
      Country(code: 'MM', name: 'Myanmar'),
      Country(code: 'MN', name: 'Mongolia'),
      Country(code: 'MO', name: 'Macau'),
      Country(code: 'MP', name: 'Northern Mariana Islands'),
      Country(code: 'MQ', name: 'Martinique'),
      Country(code: 'MR', name: 'Mauritania'),
      Country(code: 'MS', name: 'Montserrat'),
      Country(code: 'MT', name: 'Malta'),
      Country(code: 'MU', name: 'Mauritius'),
      Country(code: 'MV', name: 'Maldives'),
      Country(code: 'MW', name: 'Malawi'),
      Country(code: 'MX', name: 'Mexico'),
      Country(code: 'MY', name: 'Malaysia'),
      Country(code: 'MZ', name: 'Mozambique'),
      Country(code: 'NA', name: 'Namibia'),
      Country(code: 'NC', name: 'New Caledonia'),
      Country(code: 'NE', name: 'Niger'),
      Country(code: 'NF', name: 'Norfolk Island'),
      Country(code: 'NG', name: 'Nigeria'),
      Country(code: 'NI', name: 'Nicaragua'),
      Country(code: 'NL', name: 'Netherlands'),
      Country(code: 'NO', name: 'Norway'),
      Country(code: 'NP', name: 'Nepal'),
      Country(code: 'NR', name: 'Nauru'),
      Country(code: 'NU', name: 'Niue'),
      Country(code: 'NZ', name: 'New Zealand'),
      Country(code: 'OM', name: 'Oman'),
      Country(code: 'PA', name: 'Panama'),
      Country(code: 'PE', name: 'Peru'),
      Country(code: 'PF', name: 'French Polynesia'),
      Country(code: 'PG', name: 'Papua New Guinea'),
      Country(code: 'PH', name: 'Philippines'),
      Country(code: 'PK', name: 'Pakistan'),
      Country(code: 'PL', name: 'Poland'),
      Country(code: 'PM', name: 'Saint Pierre and Miquelon'),
      Country(code: 'PN', name: 'Pitcairn'),
      Country(code: 'PR', name: 'Puerto Rico'),
      Country(code: 'PS', name: 'Palestine'),
      Country(code: 'PT', name: 'Portugal'),
      Country(code: 'PW', name: 'Palau'),
      Country(code: 'PY', name: 'Paraguay'),
      Country(code: 'QA', name: 'Qatar'),
      Country(code: 'RE', name: 'Réunion'),
      Country(code: 'RO', name: 'Romania'),
      Country(code: 'RS', name: 'Serbia'),
      Country(code: 'RU', name: 'Russia'),
      Country(code: 'RW', name: 'Rwanda'),
      Country(code: 'SA', name: 'Saudi Arabia'),
      Country(code: 'SB', name: 'Solomon Islands'),
      Country(code: 'SC', name: 'Seychelles'),
      Country(code: 'SD', name: 'Sudan'),
      Country(code: 'SE', name: 'Sweden'),
      Country(code: 'SG', name: 'Singapore'),
      Country(code: 'SH', name: 'Saint Helena'),
      Country(code: 'SI', name: 'Slovenia'),
      Country(code: 'SJ', name: 'Svalbard and Jan Mayen'),
      Country(code: 'SK', name: 'Slovakia'),
      Country(code: 'SL', name: 'Sierra Leone'),
      Country(code: 'SM', name: 'San Marino'),
      Country(code: 'SN', name: 'Senegal'),
      Country(code: 'SO', name: 'Somalia'),
      Country(code: 'SR', name: 'Suriname'),
      Country(code: 'SS', name: 'South Sudan'),
      Country(code: 'ST', name: 'São Tomé and Príncipe'),
      Country(code: 'SV', name: 'El Salvador'),
      Country(code: 'SX', name: 'Sint Maarten'),
      Country(code: 'SY', name: 'Syria'),
      Country(code: 'SZ', name: 'Eswatini'),
      Country(code: 'TC', name: 'Turks and Caicos Islands'),
      Country(code: 'TD', name: 'Chad'),
      Country(code: 'TF', name: 'French Southern Territories'),
      Country(code: 'TG', name: 'Togo'),
      Country(code: 'TH', name: 'Thailand'),
      Country(code: 'TJ', name: 'Tajikistan'),
      Country(code: 'TK', name: 'Tokelau'),
      Country(code: 'TL', name: 'East Timor'),
      Country(code: 'TM', name: 'Turkmenistan'),
      Country(code: 'TN', name: 'Tunisia'),
      Country(code: 'TO', name: 'Tonga'),
      Country(code: 'TR', name: 'Turkey'),
      Country(code: 'TT', name: 'Trinidad and Tobago'),
      Country(code: 'TV', name: 'Tuvalu'),
      Country(code: 'TW', name: 'Taiwan'),
      Country(code: 'TZ', name: 'Tanzania'),
      Country(code: 'UA', name: 'Ukraine'),
      Country(code: 'UG', name: 'Uganda'),
      Country(code: 'UM', name: 'United States Minor Outlying Islands'),
      Country(code: 'US', name: 'United States'),
      Country(code: 'UY', name: 'Uruguay'),
      Country(code: 'UZ', name: 'Uzbekistan'),
      Country(code: 'VA', name: 'Vatican City'),
      Country(code: 'VC', name: 'Saint Vincent and the Grenadines'),
      Country(code: 'VE', name: 'Venezuela'),
      Country(code: 'VG', name: 'British Virgin Islands'),
      Country(code: 'VI', name: 'United States Virgin Islands'),
      Country(code: 'VN', name: 'Vietnam'),
      Country(code: 'VU', name: 'Vanuatu'),
      Country(code: 'WF', name: 'Wallis and Futuna'),
      Country(code: 'WS', name: 'Samoa'),
      Country(code: 'YE', name: 'Yemen'),
      Country(code: 'YT', name: 'Mayotte'),
      Country(code: 'ZA', name: 'South Africa'),
      Country(code: 'ZM', name: 'Zambia'),
      Country(code: 'ZW', name: 'Zimbabwe'),
    ];
  }

  // Static methods for getting available options without localization
  static List<AppLanguage> getAppLanguages() {
    return const [
      AppLanguage(
        code: 'en',
        name: 'English',
        localizedKey: 'languageEnglish',
      ),
      AppLanguage(
        code: 'it',
        name: 'Italiano',
        localizedKey: 'languageItalian',
      ),
    ];
  }

  static List<Interest> getInterests() {
    return const [
      Interest(key: 'spirituality', localizedKey: 'interestSpirituality'),
      Interest(key: 'meditation', localizedKey: 'interestMeditation'),
      Interest(key: 'philosophy', localizedKey: 'interestPhilosophy'),
      Interest(key: 'mysticism', localizedKey: 'interestMysticism'),
      Interest(key: 'divination', localizedKey: 'interestDivination'),
      Interest(key: 'wisdom', localizedKey: 'interestWisdom'),
      Interest(key: 'dreams', localizedKey: 'interestDreams'),
      Interest(key: 'tarot', localizedKey: 'interestTarot'),
      Interest(key: 'astrology', localizedKey: 'interestAstrology'),
      Interest(key: 'numerology', localizedKey: 'interestNumerology'),
    ];
  }

  // Available languages based on localization files
  static List<AppLanguage> getAvailableLanguages(AppLocalizations l10n) {
    return [
      AppLanguage(
        code: 'en',
        name: 'English',
        localizedKey: l10n.languageEnglish,
      ),
      AppLanguage(
        code: 'it',
        name: 'Italiano',
        localizedKey: l10n.languageItalian,
      ),
    ];
  }

  // Available interests
  static List<Interest> getAvailableInterests(AppLocalizations l10n) {
    return [
      Interest(key: 'spirituality', localizedKey: l10n.interestSpirituality),
      Interest(key: 'meditation', localizedKey: l10n.interestMeditation),
      Interest(key: 'philosophy', localizedKey: l10n.interestPhilosophy),
      Interest(key: 'mysticism', localizedKey: l10n.interestMysticism),
      Interest(key: 'divination', localizedKey: l10n.interestDivination),
      Interest(key: 'wisdom', localizedKey: l10n.interestWisdom),
      Interest(key: 'dreams', localizedKey: l10n.interestDreams),
      Interest(key: 'tarot', localizedKey: l10n.interestTarot),
      Interest(key: 'astrology', localizedKey: l10n.interestAstrology),
      Interest(key: 'numerology', localizedKey: l10n.interestNumerology),
    ];
  }
}
