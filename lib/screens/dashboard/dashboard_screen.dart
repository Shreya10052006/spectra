import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/spectra_card.dart';

/// SPECTRA — Dashboard Screen
/// Weekly mood, usage stats, achievements, settings
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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

              // Header
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Dashboard',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Your wellness journey', style: Theme.of(context).textTheme.bodyMedium),
                ]),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primarySoft)),
                  child: const Icon(Icons.settings_rounded, color: AppColors.textSecondary, size: 22),
                ),
              ]),
              const SizedBox(height: 24),

              // Profile Summary
              SpectraCard(
                gradient: AppColors.greenGradient,
                child: Row(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Welcome back!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('You\'re making great progress 🌟',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.85))),
                  ])),
                ]),
              ),
              const SizedBox(height: 20),

              // Weekly Mood
              Text('Weekly Mood', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SpectraCard(
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _DayMood(day: 'Mon', emoji: '😊', isToday: false),
                    _DayMood(day: 'Tue', emoji: '😌', isToday: false),
                    _DayMood(day: 'Wed', emoji: '😐', isToday: false),
                    _DayMood(day: 'Thu', emoji: '😊', isToday: false),
                    _DayMood(day: 'Fri', emoji: '😌', isToday: false),
                    _DayMood(day: 'Sat', emoji: '😊', isToday: false),
                    _DayMood(day: 'Sun', emoji: '✨', isToday: true),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),

              // Usage Stats
              Text('Usage Stats', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatCard(icon: Icons.chat_rounded, label: 'Conversations', value: '12', color: AppColors.primary, bgColor: AppColors.primarySoft)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.self_improvement_rounded, label: 'Calm Sessions', value: '8', color: AppColors.secondary, bgColor: AppColors.secondarySoft)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatCard(icon: Icons.record_voice_over_rounded, label: 'Spoken Words', value: '156', color: AppColors.accent, bgColor: AppColors.accentLight)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.view_in_ar_rounded, label: 'VR Scenarios', value: '0', color: AppColors.calmDark, bgColor: AppColors.calm)),
              ]),
              const SizedBox(height: 20),

              // Achievements
              Text('Achievements', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SpectraCard(
                child: Column(children: [
                  _AchievementRow(icon: Icons.emoji_events_rounded, title: 'First Conversation', subtitle: 'Started your first chat', color: AppColors.accent, unlocked: true),
                  Divider(color: AppColors.primarySoft, height: 24),
                  _AchievementRow(icon: Icons.spa_rounded, title: 'Calm Explorer', subtitle: 'Complete 5 calm sessions', color: AppColors.secondary, unlocked: false),
                  Divider(color: AppColors.primarySoft, height: 24),
                  _AchievementRow(icon: Icons.star_rounded, title: 'Week Streak', subtitle: 'Use SPECTRA for 7 days', color: AppColors.primary, unlocked: false),
                ]),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayMood extends StatelessWidget {
  final String day;
  final String emoji;
  final bool isToday;

  const _DayMood({required this.day, required this.emoji, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(day, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isToday ? AppColors.primary : AppColors.textHint)),
      const SizedBox(height: 8),
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isToday ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
      ),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return SpectraCard(
      color: bgColor,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool unlocked;

  const _AchievementRow({required this.icon, required this.title, required this.subtitle, required this.color, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: unlocked ? color.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: unlocked ? color : AppColors.textHint, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: unlocked ? AppColors.textPrimary : AppColors.textHint)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ])),
      if (unlocked) Icon(Icons.check_circle_rounded, color: color, size: 22) else Icon(Icons.lock_rounded, color: AppColors.textHint.withOpacity(0.4), size: 20),
    ]);
  }
}
