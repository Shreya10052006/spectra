import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/vr_training/vr_training_screen.dart';
import '../screens/speak/speak_screen.dart';
import '../screens/calm_mode/calm_mode_screen.dart';
import '../screens/wearable/wearable_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';

/// SPECTRA — Bottom navigation shell
/// 6 tabs with smooth fade transitions, calm styling
class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;

  // Optimized lazy-loading for demo stability
  Widget _getScreen(int index) {
    switch (index) {
      case 0: return const HomeScreen();
      case 1: return const VRTrainingScreen();
      case 2: return const SpeakScreen();
      case 3: return const CalmModeScreen();
      case 4: return const WearableScreen();
      case 5: return const DashboardScreen();
      default: return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _getScreen(_currentIndex),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.navBackground,
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', isActive: _currentIndex == 0, onTap: () => _switchTab(0)),
                _NavItem(icon: Icons.view_in_ar_rounded, label: 'VR', isActive: _currentIndex == 1, onTap: () => _switchTab(1)),
                _NavItem(icon: Icons.record_voice_over_rounded, label: 'Speak', isActive: _currentIndex == 2, onTap: () => _switchTab(2)),
                _NavItem(icon: Icons.self_improvement_rounded, label: 'Calm', isActive: _currentIndex == 3, onTap: () => _switchTab(3)),
                _NavItem(icon: Icons.watch_rounded, label: 'Wear', isActive: _currentIndex == 4, onTap: () => _switchTab(4)),
                _NavItem(icon: Icons.dashboard_rounded, label: 'Stats', isActive: _currentIndex == 5, onTap: () => _switchTab(5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _switchTab(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: Icon(icon, color: isActive ? AppColors.navActive : AppColors.navInactive, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
