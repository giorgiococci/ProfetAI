class UserProfile {
  final String? name;
  final String? country;
  final Gender? gender;
  final List<String> languages;
  final List<String> interests;
  final String? favoriteProphet; // Added favorite prophet field

  const UserProfile({
    this.name,
    this.country,
    this.gender,
    this.languages = const [],
    this.interests = const [],
    this.favoriteProphet,
  });

  UserProfile copyWith({
    String? name,
    String? country,
    Gender? gender,
    List<String>? languages,
    List<String>? interests,
    String? favoriteProphet,
  }) {
    return UserProfile(
      name: name ?? this.name,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      favoriteProphet: favoriteProphet ?? this.favoriteProphet,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'gender': gender?.toString(),
      'languages': languages,
      'interests': interests,
      'favoriteProphet': favoriteProphet,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String?,
      country: json['country'] as String?,
      gender: json['gender'] != null ? Gender.values.firstWhere(
        (e) => e.toString() == json['gender'],
        orElse: () => Gender.preferNotToSay,
      ) : null,
      languages: List<String>.from(json['languages'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      favoriteProphet: json['favoriteProphet'] as String?,
    );
  }

  @override
  String toString() {
    return 'UserProfile(name: $name, country: $country, gender: $gender, languages: $languages, interests: $interests, favoriteProphet: $favoriteProphet)';
  }
}

enum Gender {
  male,
  female,
  nonBinary,
  preferNotToSay,
}

class Country {
  final String code;
  final String name;

  const Country({
    required this.code,
    required this.name,
  });

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && other.code == code && other.name == name;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode;
}

class AppLanguage {
  final String code;
  final String name;
  final String localizedKey;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.localizedKey,
  });

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppLanguage && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

class Interest {
  final String key;
  final String localizedKey;

  const Interest({
    required this.key,
    required this.localizedKey,
  });

  @override
  String toString() => key;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Interest && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}
