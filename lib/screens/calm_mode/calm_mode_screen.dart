import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/services/backend_analytics_service.dart';

class CalmModeScreen extends StatefulWidget {
  const CalmModeScreen({super.key});

  @override
  State<CalmModeScreen> createState() => _CalmModeScreenState();
}

class _CalmModeScreenState extends State<CalmModeScreen> with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  
  late AnimationController _waveController;
  late AnimationController _breathController;
  late AnimationController _gradientController;

  double _volume = 0.25;
  double _screenOpacity = 0.0;
  final math.Random _random = math.Random();

  bool _isMuted = false;
  bool _showBreathing = true;
  int _groundingStep = 0; // 0 = hidden, 1 = 5 things, up to 5
  
  late DateTime _sessionStart;

  final List<String> _groundingPrompts = [
    "",
    "Name 5 things you can see",
    "Name 4 things you can feel",
    "Name 3 things you can hear",
    "Name 2 things you can smell",
    "Name 1 thing you can taste",
  ];

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();

    // 1. Audio Setup
    _audioPlayer = AudioPlayer();
    _initAudio();

    // Fade-in entry transition
    Future.microtask(() {
      if (mounted) setState(() => _screenOpacity = 1.0);
    });

    // 2. Wave Motion (Very Slow, 20 seconds)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 3. Breathing Motion (Naturalized ~5s with 2-5% variance)
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _naturalizeBreathingSpeed();
          _breathController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _naturalizeBreathingSpeed();
          _breathController.forward();
        }
      });
    _breathController.forward();

    // 4. Gradient Color Shift (Very Slow, 15 seconds)
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  void _naturalizeBreathingSpeed() {
    // Introduce 2-4% variability to avoid perfectly uniform synthetic loops
    final variance = -150 + _random.nextInt(300);
    _breathController.duration = Duration(milliseconds: 5000 + variance);
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset('assets/audio/ocean_waves.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setVolume(_volume); // Soft 25% start
      _audioPlayer.play();
    } catch (e) {
      print("Error loading calm mode audio: $e");
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _breathController.dispose();
    _gradientController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startExit() {
    // Analytics Dispatch
    final duration = DateTime.now().difference(_sessionStart).inSeconds;
    BackendAnalyticsService.logCalmSession(
      durationSeconds: duration, 
      triggerSource: "user_navigated", 
      completed: duration > 10,
    );

    // Smooth fade-out before exiting
    setState(() => _screenOpacity = 0.0);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _audioPlayer.setVolume(_isMuted ? 0.0 : _volume);
    });
  }

  void _toggleBreathing() {
    setState(() => _showBreathing = !_showBreathing);
  }

  void _toggleGrounding() {
    setState(() {
      if (_groundingStep == 0) {
        _groundingStep = 1; // Start
      } else if (_groundingStep < 5) {
        _groundingStep++; // Next step
      } else {
        _groundingStep = 0; // Hide
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _screenOpacity,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Base Animated Gradient
            _buildAnimatedGradient(),

            // 2. Overlay Wave & Light Motion (Depth)
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _OceanEnvironmentPainter(
                    animationValue: _waveController.value,
                    color: Colors.white.withOpacity(0.06),
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // 3. Center Content (Orb + Subtle Grounding)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showBreathing) _buildBreathingOrb(),
                  const SizedBox(height: 48),
                  if (_groundingStep > 0) _buildGroundingPrompt(),
                ],
              ),
            ),

            // 4. Controls (Bottom)
            _buildMinimalControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedGradient() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFF4B79A1), const Color(0xFF283E51), _gradientController.value)!,
                Color.lerp(const Color(0xFF283E51), const Color(0xFF4B79A1), _gradientController.value)!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroundingPrompt() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      child: Text(
        _groundingPrompts[_groundingStep],
        key: ValueKey<int>(_groundingStep),
        style: TextStyle(
          color: Colors.white.withOpacity(0.45), // Subtle, not an overlay
          fontSize: 18,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBreathingOrb() {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        // Curved mapping for softer, natural breathing feel
        final curvedValue = Curves.easeInOutSine.transform(_breathController.value);
        final size = 180.0 + (curvedValue * 120.0); // 180 to 300
        final opacity = 0.2 + (curvedValue * 0.35); // 0.2 to 0.55

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(opacity * 0.4),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(opacity * 0.2),
                blurRadius: 40 + (curvedValue * 40),
                spreadRadius: 10 + (curvedValue * 20),
              )
            ],
          ),
          child: Center(
            child: AnimatedOpacity(
              opacity: 0.3 + (curvedValue * 0.4), // Soft fade out/in, stays subtle
              duration: const Duration(milliseconds: 300),
              child: Text(
                _breathController.status == AnimationStatus.forward || _breathController.value == 0.0
                    ? "Breathe in"
                    : "Breathe out",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w300, // Very soft weight
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimalControls() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Exit
              IconButton(
                onPressed: _startExit,
                icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 28),
              ),
              
              Row(
                children: [
                  // Minimal Volume Slider
                  if (!_isMuted)
                    SizedBox(
                      width: 70,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        ),
                        child: Slider(
                          value: _volume,
                          min: 0.0,
                          max: 1.0,
                          activeColor: Colors.white54,
                          inactiveColor: Colors.white12,
                          onChanged: (val) {
                            setState(() {
                              _volume = val;
                              _audioPlayer.setVolume(val);
                            });
                          },
                        ),
                      ),
                    ),
                  
                  // Mute Toggle
                  IconButton(
                    onPressed: _toggleMute,
                    icon: Icon(
                      _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: Colors.white60,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 4),
                  
                  // Grounding Toggle
                  TextButton.icon(
                    onPressed: _toggleGrounding,
                    icon: const Icon(Icons.psychology_rounded, color: Colors.white70),
                    label: Text(
                      _groundingStep == 0 ? "Need guidance?" : "Next",
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

/// A Custom Painter that draws full-environment light shafts and ocean waves
class _OceanEnvironmentPainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0 (repeating)
  final Color color;

  _OceanEnvironmentPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle vertical light shafts (depth distortion)
    final lightRayPaint = Paint()
      ..color = Colors.white.withOpacity(color.opacity * 0.4) // very faint
      ..style = PaintingStyle.fill;
      
    final rayPath1 = Path()
      ..moveTo(size.width * 0.1 + math.sin(animationValue * 2 * math.pi) * 80, 0)
      ..lineTo(size.width * 0.35 + math.sin(animationValue * 2 * math.pi) * 80, 0)
      ..lineTo(size.width * 0.55 + math.sin(animationValue * 2 * math.pi + math.pi) * 120, size.height)
      ..lineTo(size.width * 0.05 + math.sin(animationValue * 2 * math.pi + math.pi) * 120, size.height)
      ..close();
    canvas.drawPath(rayPath1, lightRayPaint);

    final rayPath2 = Path()
      ..moveTo(size.width * 0.6 + math.cos(animationValue * 2 * math.pi) * 100, 0)
      ..lineTo(size.width * 0.95 + math.cos(animationValue * 2 * math.pi) * 100, 0)
      ..lineTo(size.width * 0.8 + math.cos(animationValue * 2 * math.pi + math.pi/2) * 150, size.height)
      ..lineTo(size.width * 0.3 + math.cos(animationValue * 2 * math.pi + math.pi/2) * 150, size.height)
      ..close();
    canvas.drawPath(rayPath2, lightRayPaint);

    // 2. Draw traditional horizontal overlapping bottom waves
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final paintDarker = Paint()
      ..color = color.withOpacity(color.opacity * 1.5)
      ..style = PaintingStyle.fill;

    _drawWave(canvas, size, paint, amplitude: 30, frequency: 1.5, phaseOffset: animationValue * 4 * math.pi, heightPct: 0.6);
    _drawWave(canvas, size, paintDarker, amplitude: 45, frequency: 1.0, phaseOffset: (animationValue * 3 * math.pi) + math.pi/4, heightPct: 0.7);
    _drawWave(canvas, size, paint, amplitude: 25, frequency: 2.0, phaseOffset: (animationValue * 5 * math.pi) + math.pi/2, heightPct: 0.85);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, {
    required double amplitude,
    required double frequency,
    required double phaseOffset,
    required double heightPct,
  }) {
    final path = Path();
    final double midHeight = size.height * heightPct;

    path.moveTo(0, size.height);
    path.lineTo(0, midHeight);

    // Generate the sine wave points across the screen
    for (double i = 0; i <= size.width; i++) {
      // Normalizing horizontal pos to 0..2pi * freq
      final normalizedX = (i / size.width) * 2 * math.pi * frequency;
      final y = midHeight + math.sin(normalizedX + phaseOffset) * amplitude;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OceanEnvironmentPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
