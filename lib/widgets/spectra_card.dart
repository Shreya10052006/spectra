import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// SPECTRA — Reusable calm card component
/// Rounded corners, soft shadows, generous padding
class SpectraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final double borderRadius;

  const SpectraCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.gradient,
    this.onTap,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? AppColors.surfaceLight) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
