import 'package:flutter/material.dart';

class AppFonts {
  static double _screenWidth = 400; // fallback

  static void init(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
  }

  static bool get isTablet => _screenWidth >= 600;

  // Title
  static double get titleLarge => isTablet ? 44 : 28;
  static double get titleMedium => isTablet ? 36 : 22;
  static double get titleSmall => isTablet ? 30 : 18;

  // Body
  static double get bodyLarge => isTablet ? 22 : 16;
  static double get bodyMedium => isTablet ? 20 : 14;
  static double get bodySmall => isTablet ? 18 : 12;

  // Label
  static double get labelLarge => isTablet ? 18 : 14;
  static double get labelMedium => isTablet ? 16 : 12;
  static double get labelSmall => isTablet ? 14 : 10;
}