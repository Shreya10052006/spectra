import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';
import '../utils/app_keys.dart';

/// SPECTRA — Profile Provider
/// Manages the user profile state and persists it locally.
class ProfileProvider with ChangeNotifier {
  UserProfile _profile = UserProfile.empty();
  bool _isLoading = true;
  bool _onboardingComplete = false;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;
  bool get onboardingComplete => _onboardingComplete;

  ProfileProvider() {
    _loadProfile();
  }

  /// Initialize: Load existing profile and onboarding status.
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingComplete = prefs.getBool(AppKeys.onboardingComplete) ?? false;
    final profileJson = prefs.getString(AppKeys.userProfile);
    if (profileJson != null) {
      _profile = UserProfile.fromJson(profileJson);
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Update the current profile draft.
  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
  }

  /// Complete onboarding: Persist profile and navigation flag.
  Future<void> completeOnboarding() async {
    // 1. Synchronously set the state and notify listeners for immediate routing
    _onboardingComplete = true;
    notifyListeners();

    // 2. Perform async local storage in the background
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppKeys.onboardingComplete, true);
      await prefs.setString(AppKeys.userProfile, _profile.toJson());
      debugPrint("SPECTRA SUCCESS: Onboarding marked as complete in storage.");
    } catch (e) {
      debugPrint("SPECTRA ERROR: Failed to save shared preferences: $e");
    }
  }

  /// Reset profile (for testing/debug).
  Future<void> resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppKeys.userProfile);
    await prefs.setBool(AppKeys.onboardingComplete, false);
    _profile = UserProfile.empty();
    _onboardingComplete = false;
    notifyListeners();
  }
}
