import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/spectra_card.dart';

/// SPECTRA — Speak Screen (TTS Tool)
/// Text input, voice selection, speed slider, playback controls
class SpeakScreen extends StatefulWidget {
  const SpeakScreen({super.key});

  @override
  State<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends State<SpeakScreen> {
  double _speed = 0.5;
  int _selectedVoice = 0;
  bool _isPlaying = false;
  final TextEditingController _textController = TextEditingController();

  final List<_VoiceOption> _voices = [
    _VoiceOption('Calm', Icons.spa_rounded, AppColors.primary),
    _VoiceOption('Warm', Icons.wb_sunny_rounded, AppColors.accent),
    _VoiceOption('Clear', Icons.water_drop_rounded, AppColors.secondary),
  ];

  final List<String> _recentPhrases = [
    'Hello, my name is...',
    'Can you help me please?',
    'I need a moment',
    'Thank you for understanding',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ─── Header ──────────────────────────────────
              Text(
                'Speak',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Express yourself with your voice',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // ─── Text Input ──────────────────────────────
              SpectraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'What would you like to say?',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(minHeight: 120),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: 5,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Type what you\'d like to say...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Voice Selection ─────────────────────────
              Text(
                'Voice',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(_voices.length, (index) {
                  final voice = _voices[index];
                  final isSelected = _selectedVoice == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedVoice = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin:
                            EdgeInsets.only(right: index < 2 ? 10 : 0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? voice.color.withOpacity(0.12)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? voice.color
                                : AppColors.primarySoft,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              voice.icon,
                              color: isSelected
                                  ? voice.color
                                  : AppColors.textHint,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              voice.label,
                              style: TextStyle(
                                color: isSelected
                                    ? voice.color
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // ─── Speed Slider ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Speed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(_speed * 2).toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.snooze_rounded,
                      color: AppColors.textHint, size: 18),
                  Expanded(
                    child: Slider(
                      value: _speed,
                      onChanged: (v) => setState(() => _speed = v),
                    ),
                  ),
                  const Icon(Icons.speed_rounded,
                      color: AppColors.textHint, size: 18),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Play Controls ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: Icons.stop_rounded,
                    onTap: () => setState(() => _isPlaying = false),
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => setState(() => _isPlaying = !_isPlaying),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  _ControlButton(
                    icon: Icons.replay_rounded,
                    onTap: () {},
                    color: AppColors.textHint,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ─── Recent Phrases ──────────────────────────
              Text(
                'Recent Phrases',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_recentPhrases.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SpectraCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    onTap: () {
                      _textController.text = _recentPhrases[index];
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _recentPhrases[index],
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textHint,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primarySoft),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _VoiceOption {
  final String label;
  final IconData icon;
  final Color color;

  _VoiceOption(this.label, this.icon, this.color);
}
