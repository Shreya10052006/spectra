import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/ai_service.dart';

class TtsScreen extends StatefulWidget {
  const TtsScreen({super.key});

  @override
  State<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends State<TtsScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  
  final FlutterTts _flutterTts = FlutterTts();
  
  String _selectedTone = 'Neutral';
  bool _isGenerating = false;
  bool _isPlaying = false;
  
  final List<String> _tones = ['Neutral', 'Friendly', 'Formal'];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.4); // Slightly slower for clarity
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      setState(() => _isPlaying = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      setState(() => _isPlaying = false);
      print("TTS Error: \$msg");
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _generateTranslation() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    final String transformedText = await AiService.transformTextForTTS(
      text: text,
      tone: _selectedTone,
    );

    setState(() {
      _outputController.text = transformedText;
      _isGenerating = false;
    });
  }

  Future<void> _speak() async {
    final text = _outputController.text.trim();
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Speech Assistant",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Tone Selector ──────────────────────────────────
              Text(
                "Select Tone",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                children: _tones.map((tone) => Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedTone = tone);
                      // Auto-regenerate on tone switch if input exists
                      if (_inputController.text.isNotEmpty && _outputController.text.isNotEmpty) {
                        _generateTranslation();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTone == tone ? AppColors.primary : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedTone == tone ? AppColors.primary : AppColors.primarySoft,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tone,
                          style: TextStyle(
                            color: _selectedTone == tone ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              
              // ─── Input Area ───────────────────────────────────
              Text(
                "What do you want to say?",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: TextField(
                  controller: _inputController,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(
                    hintText: "Type a short phrase (e.g. 'give coffee')...",
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // ─── Generate Button ────────────────────────────────
              ElevatedButton(
                onPressed: _isGenerating ? null : _generateTranslation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isGenerating 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Transform Phrasing", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              
              const SizedBox(height: 32),
              const Divider(color: AppColors.primarySoft),
              const SizedBox(height: 16),

              // ─── Output Area ──────────────────────────────────
              Text(
                "Final Generated Output (You can edit)",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: _isPlaying ? AppColors.primarySoft.withOpacity(0.4) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isPlaying ? AppColors.primary : Colors.transparent, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: TextField(
                  controller: _outputController,
                  maxLines: 4,
                  minLines: 2,
                  style: const TextStyle(fontSize: 18, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: "Your transformed sentence will appear here...",
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── TTS Controls ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isPlaying ? null : _speak,
                      icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                      label: const Text("Speak", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: !_isPlaying ? null : _stop,
                      icon: const Icon(Icons.stop_circle_rounded, color: Colors.white),
                      label: const Text("Stop", style: TextStyle(color: Colors.white, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.moodAnxious,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
