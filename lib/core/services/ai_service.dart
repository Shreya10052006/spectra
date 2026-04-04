import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../models/chat_message.dart';
import '../../models/user_profile.dart';
import 'auth_service.dart';

class AiService {
  static String get activeBaseUrl => kIsWeb 
      ? 'http://localhost:8000/api/v1' 
      : 'http://10.0.2.2:8000/api/v1';

  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    required UserProfile profile,
    required List<ChatMessage> history,
  }) async {
    try {
        final url = Uri.parse('$activeBaseUrl/chat');
        
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "user_id": AuthService.userId, // ✅ Uses the persistent device UUID
            "user_message": message,
            "user_profile": profile.toMap(),
            "history": history.map((e) => e.toMap()).toList(),
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {
            "response_text": data["response_text"] ?? "I hear you.",
            "suggest_calm_mode": data["suggest_calm_mode"] ?? false,
          };
        } else {
          print("Llama API Error: ${response.statusCode}");
          return {
            "response_text": "I'm having a little trouble connecting right now. Take a deep breath, I'm here.",
            "suggest_calm_mode": false,
          };
        }
    } catch (e) {
      print("Network Error: $e");
      return {
          "response_text": "I seem to be disconnected. Let's take a moment of quiet together.",
          "suggest_calm_mode": false,
        };
    }
  }

  static Future<String> transformTextForTTS({
    required String text,
    required String tone,
  }) async {
    try {
      final url = Uri.parse('$activeBaseUrl/tts-transform');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "text": text,
          "tone": tone,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["generated_text"] ?? text;
      } else {
        print("TTS API Error: ${response.statusCode}");
        return text; // Safe fallback: return raw input if API fails.
      }
    } catch (e) {
      print("TTS Network Error: $e");
      return text; // Safe fallback.
    }
  }
}
