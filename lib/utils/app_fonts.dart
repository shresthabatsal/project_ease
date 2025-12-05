import 'package:flutter/material.dart';

class AppFonts {
  static double screenWidth = 400; // default fallback width

  static void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
  }

  static double get title {
    if (screenWidth > 600) return 40; // tablet
    return 28; // phone
  }

  static double get subtitle {
    if (screenWidth > 600) return 20; // tablet
    return 16; // phone
  }

  static double get body {
    if (screenWidth > 600) return 18;
    return 14;
  }
}