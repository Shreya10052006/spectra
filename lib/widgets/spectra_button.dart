import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// SPECTRA — Rounded button with large tap area
/// Autism-friendly: clear labels, generous sizing, calm feedback
class SpectraButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isSmall;
  final Color? color;

  const SpectraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isSmall = false,
    this.color,
  });

  @override
  State<SpectraButton> createState() => _SpectraButtonState();
}

class _SpectraButtonState extends State<SpectraButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.color ?? AppColors.primary;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              constraints: BoxConstraints(
                minHeight: widget.isSmall ? 44 : 52,
                minWidth: widget.isSmall ? 80 : 120,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isSmall ? 16 : 24,
                vertical: widget.isSmall ? 10 : 14,
              ),
              decoration: BoxDecoration(
                color: widget.isPrimary ? bgColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: widget.isPrimary
                    ? null
                    : Border.all(color: bgColor.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.isPrimary
                          ? AppColors.textOnPrimary
                          : bgColor,
                      size: widget.isSmall ? 18 : 20,
                    ),
                    SizedBox(width: widget.isSmall ? 6 : 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isPrimary
                          ? AppColors.textOnPrimary
                          : bgColor,
                      fontSize: widget.isSmall ? 13 : 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
