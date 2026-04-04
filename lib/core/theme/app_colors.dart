import 'package:flutter/material.dart';

/// SPECTRA — Autism-friendly color palette
/// Soft blues, light greens, warm neutral tones
/// No harsh reds or bright flashing colors
class AppColors {
  AppColors._();

  // ─── Primary (Soft Blue) ────────────────────────────────
  static const Color primary = Color(0xFF5B8DEF);
  static const Color primaryLight = Color(0xFFA8C8F0);
  static const Color primarySoft = Color(0xFFD6E4FA);
  static const Color primaryDark = Color(0xFF3A6BC5);

  // ─── Secondary (Light Green) ────────────────────────────
  static const Color secondary = Color(0xFF7BC47F);
  static const Color secondaryLight = Color(0xFFB8E6BB);
  static const Color secondarySoft = Color(0xFFDFF5E1);
  static const Color secondaryDark = Color(0xFF5A9E5E);

  // ─── Surfaces & Backgrounds ─────────────────────────────
  static const Color background = Color(0xFFFAFAF7);
  static const Color surface = Color(0xFFF7F5F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x0A000000);

  // ─── Text ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF636B83);
  static const Color textHint = Color(0xFFA0A7B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Accent & States ───────────────────────────────────
  static const Color accent = Color(0xFFF0C987);
  static const Color accentLight = Color(0xFFFAE8C8);
  static const Color calm = Color(0xFFE8E4F0);
  static const Color calmDark = Color(0xFFB8B0CC);
  static const Color error = Color(0xFFD4837A);
  static const Color errorLight = Color(0xFFF2D4D0);
  static const Color success = Color(0xFF7BC47F);

  // ─── Navigation ─────────────────────────────────────────
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navActive = Color(0xFF5B8DEF);
  static const Color navInactive = Color(0xFFB0B8C8);

  // ─── Mood Colors ────────────────────────────────────────
  static const Color moodHappy = Color(0xFFF0C987);
  static const Color moodCalm = Color(0xFF7BC47F);
  static const Color moodNeutral = Color(0xFFA8C8F0);
  static const Color moodAnxious = Color(0xFFE8C5A0);
  static const Color moodOverwhelmed = Color(0xFFD4A0B8);

  // ─── Gradients ──────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B8DEF), Color(0xFF7BA8F7)],
  );

  static const LinearGradient calmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7F5F2), Color(0xFFE8E4F0)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFAFAF7), Color(0xFFF0EDE8)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7BC47F), Color(0xFF9BD49E)],
  );
}
