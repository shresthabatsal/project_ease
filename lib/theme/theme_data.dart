import 'package:flutter/material.dart';
import 'package:project_ease/theme/app_colors.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    fontFamily: "Montserrat",
    useMaterial3: true,

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: "Montserrat",
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    // Text Field Theme
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),

      floatingLabelStyle: const TextStyle(color: AppColors.primary),
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: "Montserrat",
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Colors.black,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: const IconThemeData(size: 30),
      unselectedIconTheme: const IconThemeData(size: 30),
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      elevation: 20,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}