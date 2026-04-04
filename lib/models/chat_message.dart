import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'is_user': isUser,
      'is_typing': isTyping,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());
}
