import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// Centralized frontend dispatch system to pipe structured events
/// safely to FastAPI, without directly exposing or communicating with Firestore.
class BackendAnalyticsService {
  // Base root for the FastAPI instance
  static String get _apiRoot => kIsWeb 
      ? "http://localhost:8000/api/v1" 
      : "http://10.0.2.2:8000/api/v1";

  static Future<void> _silentPost(String route, Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse("$_apiRoot/track/$route");
      final body = jsonEncode({
        "user_id": AuthService.userId,
        "timestamp": DateTime.now().toIso8601String(),
        ...payload,
      });

      // Strict 3-second timeout protection
      await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      // ✅ FAILURE HANDLING - Fail Silently
      // "app MUST NOT crash, fallback silently, no UI freeze"
      print("SILENT ANALYTICS ERROR on $route: $e");
    }
  }

  static Future<void> logWearableEvent({
    required int heartRate,
    required String eventType, 
    required String userResponse
  }) async {
    await _silentPost("wearable", {
      "heart_rate": heartRate,
      "event_type": eventType,
      "user_response": userResponse,
    });
  }

  static Future<void> logVRSession({
    required String scenario,
    required String difficulty,
    required String stimulation,
    required bool completion,
    required double responseTimeAvg,
    required int hesitationCount,
  }) async {
    await _silentPost("vr", {
      "scenario": scenario,
      "difficulty": difficulty,
      "stimulation": stimulation,
      "completion": completion,
      "response_time_avg": responseTimeAvg,
      "hesitation_count": hesitationCount,
    });
  }

  static Future<void> logCalmSession({
    required int durationSeconds,
    required String triggerSource,
    required bool completed,
  }) async {
    await _silentPost("calm", {
      "duration_seconds": durationSeconds,
      "trigger_source": triggerSource,
      "completed": completed,
    });
  }

  /// Extracts the intelligent dashboard summary from the backend securely.
  static Future<Map<String, dynamic>?> getDashboardSummary() async {
    try {
      final uri = Uri.parse("$_apiRoot/dashboard/${AuthService.userId}");
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["data"];
      }
    } catch (e) {
      print("[CRITICAL] Failed to fetch User Dashboard: $e");
    }
    
    // Explicit null forces the UI to render the "empty fallback" state gracefully
    return null; 
  }
}
