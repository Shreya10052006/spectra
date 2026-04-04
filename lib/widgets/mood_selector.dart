import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// SPECTRA — Emoji-based mood selector
/// Large tap areas, clear labels, gentle animations
class MoodSelector extends StatefulWidget {
  final Function(int index)? onMoodSelected;

  const MoodSelector({super.key, this.onMoodSelected});

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  int _selectedIndex = -1;

  static const List<_MoodData> _moods = [
    _MoodData('😊', 'Happy', AppColors.moodHappy),
    _MoodData('😌', 'Calm', AppColors.moodCalm),
    _MoodData('😐', 'Okay', AppColors.moodNeutral),
    _MoodData('😟', 'Anxious', AppColors.moodAnxious),
    _MoodData('😰', 'Overwhelmed', AppColors.moodOverwhelmed),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_moods.length, (index) {
        final mood = _moods[index];
        final isSelected = _selectedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            widget.onMoodSelected?.call(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? mood.color.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? mood.color.withOpacity(0.5)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mood.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _MoodData {
  final String emoji;
  final String label;
  final Color color;

  const _MoodData(this.emoji, this.label, this.color);
}
