import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles anonymous persistent identity for database correlation.
class AuthService {
  static const String _uuidKey = "spectra_user_uuid";
  static String? _currentUserId;

  /// Retrieves the persistent UUID for this device, generating one if it doesn't exist.
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString(_uuidKey);

    if (_currentUserId == null) {
      // Generate a new UUID mathematically
      _currentUserId = _generatePseudoUuid();
      await prefs.setString(_uuidKey, _currentUserId!);
      print("Generated new persistent UUID: $_currentUserId");
    } else {
      print("Loaded persistent UUID: $_currentUserId");
    }
  }

  /// Synchronous access to the UUID. Must call `initialize()` at app start.
  static String get userId {
    if (_currentUserId == null) {
      // Fallback just in case, though initialize should run first.
      return "fallback_anonymous_user";
    }
    return _currentUserId!;
  }

  static String _generatePseudoUuid() {
    final random = Random.secure();
    return List.generate(16, (index) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }
}
