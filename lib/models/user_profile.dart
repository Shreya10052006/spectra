import 'dart:convert';

/// SPECTRA — User Profile Model
/// Collects preferences and sensory comfort for system personalization.
class UserProfile {
  String name;
  String ageGroup;
  String role;
  String noiseSensitivity;
  String socialComfort;
  String communication;
  List<String> triggers;
  List<String> interests;

  UserProfile({
    this.name = '',
    this.ageGroup = '',
    this.role = '',
    this.noiseSensitivity = '',
    this.socialComfort = '',
    this.communication = '',
    this.triggers = const [],
    this.interests = const [],
  });

  /// Factory to create an empty profile.
  factory UserProfile.empty() => UserProfile();

  /// Convert to Map for JSON storage.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age_group': ageGroup,
      'role': role,
      'noise_sensitivity': noiseSensitivity,
      'social_comfort': socialComfort,
      'communication': communication,
      'triggers': triggers,
      'interests': interests,
    };
  }

  /// Create profile from Map.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      ageGroup: map['age_group'] ?? '',
      role: map['role'] ?? '',
      noiseSensitivity: map['noise_sensitivity'] ?? '',
      socialComfort: map['social_comfort'] ?? '',
      communication: map['communication'] ?? '',
      triggers: List<String>.from(map['triggers'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserProfile(name: $name, ageGroup: $ageGroup, role: $role, noise: $noiseSensitivity, social: $socialComfort, comms: $communication, triggers: $triggers, interests: $interests)';
  }
}
