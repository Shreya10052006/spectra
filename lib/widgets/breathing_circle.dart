import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// SPECTRA — Breathing circle animation for calm mode
/// Smooth expand/contract with slow transitions
class BreathingCircle extends StatefulWidget {
  final double size;
  final Duration breathDuration;

  const BreathingCircle({
    super.key,
    this.size = 220,
    this.breathDuration = const Duration(milliseconds: 4000),
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  String _breathPhase = 'Breathe in';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.breathDuration,
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (mounted) {
        setState(() {
          if (status == AnimationStatus.forward) {
            _breathPhase = 'Breathe in';
          } else if (status == AnimationStatus.reverse) {
            _breathPhase = 'Breathe out';
          }
        });
      }
    });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: widget.size * _scaleAnimation.value,
                      height: widget.size * _scaleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary
                            .withOpacity(_opacityAnimation.value * 0.15),
                      ),
                    ),
                    // Middle ring
                    Container(
                      width: widget.size * 0.8 * _scaleAnimation.value,
                      height: widget.size * 0.8 * _scaleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary
                            .withOpacity(_opacityAnimation.value * 0.25),
                      ),
                    ),
                    // Inner circle
                    Container(
                      width: widget.size * 0.6 * _scaleAnimation.value,
                      height: widget.size * 0.6 * _scaleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary
                                .withOpacity(_opacityAnimation.value),
                            AppColors.primaryLight
                                .withOpacity(_opacityAnimation.value * 0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.self_improvement_rounded,
                          color: AppColors.textOnPrimary
                              .withOpacity(_opacityAnimation.value + 0.2),
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: Text(
            _breathPhase,
            key: ValueKey(_breathPhase),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper animated builder
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
