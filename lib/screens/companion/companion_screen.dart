import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/profile_provider.dart';
import '../../models/chat_message.dart';
import '../../core/services/ai_service.dart';
import '../calm_mode/calm_mode_screen.dart';

class CompanionScreen extends StatefulWidget {
  final Map<String, dynamic>? initialContext;
  const CompanionScreen({super.key, this.initialContext});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ── STT State ──────────────────────────────────────────────
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  // ── Pulse animation for mic button ──────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm here to listen. How are you feeling today?",
      isUser: false,
    )
  ];
  bool _showCalmModePrompt = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the mic listening state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.stop(); // Start paused, only run when listening

    // Initialize STT engine
    _initSpeech();

    // Check for stress event deep-link context
    if (widget.initialContext != null &&
        widget.initialContext!["context"] == "stress_event") {
      final String systemPrompt =
          widget.initialContext!["message"] ?? "";
      if (systemPrompt.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleSubmitted(systemPrompt, isSystemOverlay: true);
        });
      }
    }
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        _onSpeechError(error.errorMsg);
      },
      onStatus: (status) {
        // When the STT engine stops listening (user paused speaking),
        // auto-submit whatever was captured.
        if (status == SpeechToText.notListeningStatus && _isListening) {
          _stopListeningAndSend();
        }
      },
    );
    setState(() {});
  }

  // ── Mic Toggle ──────────────────────────────────────────────
  Future<void> _toggleListening() async {
    if (_isListening) {
      _stopListeningAndSend();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      _showSpeechError("Mic access isn't available on this device.");
      return;
    }

    setState(() => _isListening = true);
    _pulseController.repeat(reverse: true);

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: "en_US",
    );
  }

  Future<void> _stopListeningAndSend() async {
    if (!_isListening) return;
    await _speech.stop();

    setState(() => _isListening = false);
    _pulseController.stop();
    _pulseController.reset();

    final captured = _textController.text.trim();
    if (captured.isNotEmpty) {
      // Small delay so UI reflects the final recognized text first
      await Future.delayed(const Duration(milliseconds: 200));
      _handleSubmitted(captured);
    }
  }

  void _onSpeechError(String errorMsg) {
    if (!mounted) return;
    setState(() => _isListening = false);
    _pulseController.stop();
    _pulseController.reset();
    _showSpeechError(
        "I couldn't hear clearly. Would you like to try again?");
  }

  void _showSpeechError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.secondarySoft,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Chat Logic ──────────────────────────────────────────────
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text,
      {bool isSystemOverlay = false}) async {
    if (text.trim().isEmpty) return;

    if (!isSystemOverlay) {
      _textController.clear();
      setState(() {
        _messages.add(ChatMessage(text: text, isUser: true));
        _messages.add(ChatMessage(
            text: "Thinking...", isUser: false, isTyping: true));
        _showCalmModePrompt = false;
      });
    } else {
      setState(() {
        _messages.add(ChatMessage(
            text: "Thinking...", isUser: false, isTyping: true));
      });
    }

    _scrollToBottom();

    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    final history = _messages.where((m) => !m.isTyping).toList();
    final contextHistory = history.length > 4
        ? history.sublist(history.length - 4)
        : history.toList();

    final response = await AiService.sendMessage(
      message: text,
      profile: profile,
      history: contextHistory,
    );

    setState(() {
      _messages.removeLast(); // remove typing indicator
      _messages
          .add(ChatMessage(text: response["response_text"], isUser: false));
      if (response["suggest_calm_mode"] == true) {
        _showCalmModePrompt = true;
      }
    });

    _scrollToBottom();
  }

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "SPECTRA Companion",
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_showCalmModePrompt) _buildCalmModePrompt(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 24),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _buildMessageBubble(_messages[index]),
              ),
            ),
            // STT listening indicator bar
            if (_isListening) _buildListeningIndicator(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      color: AppColors.primarySoft.withOpacity(0.4),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            "Listening… speak naturally",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalmModePrompt() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.spa_rounded,
              color: AppColors.secondary, size: 28),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "You seem overwhelmed. Would you like to take a break?",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CalmModeScreen()),
              );
              setState(() => _showCalmModePrompt = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Yes, let's rest",
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = message.isUser;
    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser
                ? const Radius.circular(0)
                : const Radius.circular(20),
            bottomLeft: !isUser
                ? const Radius.circular(0)
                : const Radius.circular(20),
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0x0A000000), // Colors.black.withOpacity(0.04)
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: message.isTyping
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: 8),
                  Text("Thinking...",
                      style:
                          TextStyle(color: AppColors.textSecondary)),
                ],
              )
            : Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          const BoxShadow(
            color: Color(0x0D000000), // Colors.black.withOpacity(0.05)
            offset: Offset(0, -4),
            blurRadius: 16,
          )
        ],
      ),
      child: Row(
        children: [
          // ── Animated Mic Button ──────────────────────────────
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening ? _pulseAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isListening
                          ? AppColors.primary
                          : AppColors.primarySoft,
                      shape: BoxShape.circle,
                      boxShadow: _isListening
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _isListening
                          ? Colors.white
                          : AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // ── Text Input ───────────────────────────────────────
          Expanded(
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.send,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                hintText: _isListening
                    ? "Listening..."
                    : "Type something gently...",
                hintStyle: TextStyle(
                  color: _isListening
                      ? AppColors.primary.withOpacity(0.6)
                      : AppColors.textSecondary.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Send Button ──────────────────────────────────────
          GestureDetector(
            onTap: () => _handleSubmitted(_textController.text),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
