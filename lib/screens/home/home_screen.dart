import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/screen_utils.dart';
import '../../widgets/spectra_card.dart';
import '../../widgets/mood_selector.dart';
import '../companion/companion_screen.dart';
import '../communication/tts_screen.dart';
import '../vr_training/vr_training_screen.dart';
import '../calm_mode/calm_mode_screen.dart';
import '../wearable/wearable_screen.dart';
import '../dashboard/user_dashboard_screen.dart';

/// SPECTRA — Home Screen
/// Central navigation control hub featuring a calm grid and subtle mood check-in.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final greeting = ScreenUtils.getTimeGreeting();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Lightweight Header ────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'friend ✨',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.spa_rounded, color: AppColors.primary, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Subtle Mood Check-in ───────────────────────
              Text(
                'How are you feeling?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 12),
              const MoodSelector(), // Kept subtle, no massive card wrapper
              const SizedBox(height: 32),

              // ─── Priority Quick Action (SOS / Grounding) ────
              // This avoids duplicating features already inside the 6-module grid.
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting Grounding Exercise...')),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySoft,
                    borderRadius: BorderRadius.circular(16), // Moderate radius
                    border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.self_improvement_rounded, color: AppColors.secondary, size: 28),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Immediate Grounding",
                            style: TextStyle(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Take a quick breather",
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.secondary, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ─── Core Section: 6-Module Grid ────────────────
              Text(
                'Explore SPECTRA',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95, // Soft, non-aggressive taller rectangles
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _FeatureGridCard(
                    title: "AI Companion",
                    subtitle: "Talk & get support",
                    icon: Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    bgColor: AppColors.primarySoft,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CompanionScreen())),
                  ),
                  _FeatureGridCard(
                    title: "Speech Assistant",
                    subtitle: "Translate to speech",
                    icon: Icons.record_voice_over_rounded,
                    color: AppColors.secondary,
                    bgColor: AppColors.secondarySoft,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TtsScreen())),
                  ),
                  _FeatureGridCard(
                    title: "VR Training",
                    subtitle: "Social practice",
                    icon: Icons.view_in_ar_rounded,
                    color: const Color(0xFF5B8DEF),
                    bgColor: const Color(0xFFEEF4FD),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VRTrainingScreen())),
                  ),
                  _FeatureGridCard(
                    title: "Calm Space",
                    subtitle: "Breathe & relax",
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF9B8EC4),
                    bgColor: AppColors.calm,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CalmModeScreen())),
                  ),
                  _FeatureGridCard(
                    title: "Wearables",
                    subtitle: "Stress tracking",
                    icon: Icons.watch_rounded,
                    color: AppColors.moodAnxious,
                    bgColor: const Color(0xFFFDE8E8),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WearableScreen())),
                  ),
                  _FeatureGridCard(
                    title: "Dashboard",
                    subtitle: "View progress",
                    icon: Icons.bar_chart_rounded,
                    color: const Color(0xFF4A5568),
                    bgColor: const Color(0xFFEDF2F7),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserDashboardScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$moduleName is currently under construction.')),
    );
  }
}

class _FeatureGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _FeatureGridCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Moderate, clean radius per prompt
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle, // Soft circle for the icon
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.8),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
