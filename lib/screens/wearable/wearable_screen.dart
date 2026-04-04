import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';
import '../../core/theme/app_colors.dart';
import '../../core/providers/wearable_provider.dart';

class WearableScreen extends StatelessWidget {
  const WearableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wearableState = Provider.of<WearableProvider>(context);

    // Compute an elegant transition color based on HR
    final currentHR = wearableState.currentHeartRate;
    final isStressed = wearableState.isStressActive;
    
    // Smooth transition from calm teal to a warm (but not sharp red) pastel tone
    final targetColor = isStressed ? const Color(0xFFE89A9A) : AppColors.primary;
    final bgColor = isStressed ? const Color(0xFFFDE8E8) : AppColors.primarySoft;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Wearable Monitor",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // 1. Live Numeric Pulse Display
            _buildLivePulse(currentHR, targetColor, bgColor),
            
            const SizedBox(height: 60),

            // 2. Smooth Fluid Graph
            Expanded(
              child: _buildSmoothGraph(wearableState.heartRateHistory, targetColor),
            ),
            
            const SizedBox(height: 48),

            // 3. Demo Controls
            _buildDemoControls(context, wearableState),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePulse(double hr, Color pulseColor, Color bgColor) {
    return Column(
      children: [
        Text(
          "Current Heart Rate",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: pulseColor.withOpacity(0.15),
                blurRadius: 40,
                spreadRadius: 10,
              )
            ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_rounded, color: pulseColor, size: 36),
              const SizedBox(height: 8),
              Text(
                hr.toInt().toString(),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  color: pulseColor,
                  height: 1.0,
                ),
              ),
              const Text(
                "BPM",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmoothGraph(Queue<double> history, Color strokeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Trends",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CustomPaint(
                painter: _SmoothGraphPainter(
                  history: history.toList(),
                  lineColor: strokeColor,
                ),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoControls(BuildContext context, WearableProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => provider.triggerStressSpike(),
              icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
              label: const Text("Simulate Spike"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.moodAnxious, // The soft pastel peach
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => provider.resetSimulation(),
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 20),
              label: const Text("Reset Normal"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A highly optimized custom painter that draws a smooth Spline curve
/// instead of jagged lines. Absolutely no grids or labels to keep it non-clinical.
class _SmoothGraphPainter extends CustomPainter {
  final List<double> history;
  final Color lineColor;

  _SmoothGraphPainter({required this.history, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Map heart rate values (approx 50-150) to the canvas height
    const double minDomain = 50.0;
    const double maxDomain = 140.0;
    
    // Horizontal spacing between data points
    final double stepX = size.width / (history.length > 1 ? history.length - 1 : 1);

    // Initial point
    final double startY = _normalizeCoord(history[0], minDomain, maxDomain, size.height);
    path.moveTo(0, startY);

    // Use quadratic bezier smoothing for a fluid, non-jagged line
    for (int i = 0; i < history.length - 1; i++) {
      final double x1 = i * stepX;
      final double y1 = _normalizeCoord(history[i], minDomain, maxDomain, size.height);
      
      final double x2 = (i + 1) * stepX;
      final double y2 = _normalizeCoord(history[i + 1], minDomain, maxDomain, size.height);

      // Midpoint to curve smoothly
      final double midX = (x1 + x2) / 2;
      path.quadraticBezierTo(x1, y1, midX, (y1 + y2) / 2);
      
      if (i == history.length - 2) {
        path.lineTo(x2, y2); // Final connection
      }
    }

    canvas.drawPath(path, paint);
  }

  double _normalizeCoord(double value, double min, double max, double height) {
    // Clamp
    final double clamped = value.clamp(min, max);
    // Normalize to 0-1
    final double normalized = (clamped - min) / (max - min);
    // Invert because canvas Y goes down
    return height - (normalized * height);
  }

  @override
  bool shouldRepaint(covariant _SmoothGraphPainter oldDelegate) {
    return true; // We repaint on every tick
  }
}
