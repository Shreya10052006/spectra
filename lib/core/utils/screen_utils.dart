import 'package:flutter/material.dart';

/// SPECTRA — Responsive sizing utilities
class ScreenUtils {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double safeTop;
  static late double safeBottom;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    safeTop = _mediaQueryData.padding.top;
    safeBottom = _mediaQueryData.padding.bottom;
  }

  /// Horizontal padding based on screen width
  static double get horizontalPadding => screenWidth * 0.06;

  /// Standard content padding
  static EdgeInsets get contentPadding => EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      );

  /// Screen padding including safe areas
  static EdgeInsets get safePadding => EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: safeTop + 16,
        bottom: safeBottom + 16,
      );

  /// Greeting based on time of day
  static String getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Good night';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }
}
