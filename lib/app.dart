import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'navigation/bottom_nav.dart';

/// SPECTRA — App configuration
/// Calm, predictable, safe design system
class SpectraApp extends StatelessWidget {
  const SpectraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPECTRA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const BottomNavShell(),
    );
  }
}
