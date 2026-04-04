import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/spectra_card.dart';
import '../../core/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../core/services/backend_analytics_service.dart';

/// SPECTRA — VR Training Screen
/// Social scenarios, difficulty selector, progress
class VRTrainingScreen extends StatefulWidget {
  const VRTrainingScreen({super.key});

  @override
  State<VRTrainingScreen> createState() => _VRTrainingScreenState();
}

class _VRTrainingScreenState extends State<VRTrainingScreen> {
  int _selectedDifficulty = 0;
  final List<String> _difficulties = ['Easy', 'Medium', 'Advanced'];

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
                'Social Training',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Practice social scenarios in a safe space',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // ─── Hero Card ───────────────────────────────
              SpectraCard(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5B8DEF), Color(0xFF9B8EC4)],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.view_in_ar_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Virtual Reality Training',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Immersive social practice with guided scenarios',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Difficulty Selector ─────────────────────
              Text(
                'Difficulty Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(3, (index) {
                  final isSelected = _selectedDifficulty == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedDifficulty = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.only(
                          right: index < 2 ? 10 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primarySoft,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _difficulties[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // ─── Scenarios ───────────────────────────────
              Text(
                'Available Scenarios',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              _ScenarioCard(
                icon: Icons.meeting_room_rounded,
                title: 'Meeting Someone New',
                description: 'Practice introducing yourself in a calm, supportive setting',
                color: AppColors.moodHappy,
                progress: 0.0,
                onTap: () => _simulateFlutterUnityLaunch(context),
              ),
              const SizedBox(height: 12),
              _ScenarioCard(
                icon: Icons.restaurant_rounded,
                title: 'Ordering at a Restaurant',
                description: 'Navigate a restaurant interaction at your own pace',
                color: AppColors.moodCalm,
                progress: 0.0,
              ),
              const SizedBox(height: 12),
              _ScenarioCard(
                icon: Icons.groups_rounded,
                title: 'Joining a Group Conversation',
                description: 'Learn comfortable ways to enter group discussions',
                color: AppColors.moodNeutral,
                progress: 0.0,
              ),
              const SizedBox(height: 12),
              _ScenarioCard(
                icon: Icons.shopping_cart_rounded,
                title: 'Shopping Interaction',
                description: 'Practice asking for help in a store',
                color: AppColors.moodAnxious,
                progress: 0.0,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateFlutterUnityLaunch(BuildContext context) {
    print("---------------------------------------------------");
    print("[FLUTTER] Launching VR View...");
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    String jsonProfile = jsonEncode(profile.toMap());
    
    print("[FLUTTER -> UNITY] Executing PostMessage...");
    print("unityWidgetController.postMessage('VR_Managers', 'ApplyUserProfile', '$jsonProfile');");
    
    // In final implementation, this transitions layout to a UnityWidget
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('VR Environment Loading: Applying ${profile.noiseSensitivity} Profile...'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
      )
    );
    
    // Log intent to start scenario
    BackendAnalyticsService.logVRSession(
      scenario: "Meeting Someone New", 
      difficulty: _difficulties[_selectedDifficulty], 
      stimulation: profile.noiseSensitivity, 
      completion: false, // In real integration, we log true when Unity replies "SessionEnd"
      responseTimeAvg: 0.0, 
      hesitationCount: 0
    );

    print("---------------------------------------------------");
  }
}

class _ScenarioCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final double progress;
  final VoidCallback? onTap;

  const _ScenarioCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SpectraCard(
        child: Row(
          children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (progress > 0) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.primarySoft,
                      color: AppColors.primary,
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
            size: 24,
          ),
        ],
      ),
    ),
  );
}
}
