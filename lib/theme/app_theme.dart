
import 'package:flutter/material.dart';
import 'package:mindshelf_note/theme/color_app.dart';

class AppTheme {
  AppTheme._();

  // ================= LIGHT THEME =================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primary,
      fontFamily: 'Roboto',

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
        error: Color(0xFFBA3030),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: const BorderSide(
            color: AppColors.lightDivider,
            width: 0.5,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        hintStyle: const TextStyle(
          color: AppColors.lightSecondaryText,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 22,
      ),

      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightSecondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
        ),
      ),

      dividerColor: AppColors.lightDivider,

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.lightText,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.lightText,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.lightText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.lightText,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: AppColors.lightSecondaryText,
          fontSize: 13,
        ),
        bodySmall: TextStyle(
          color: AppColors.lightSecondaryText,
          fontSize: 11,
        ),
      ),
    );
  }

  // ================= DARK THEME =================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkPrimary,
      fontFamily: 'Roboto',

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkBackground,
        secondary: AppColors.darkPinkLight,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        error: Color(0xFFFF8585),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: const BorderSide(
            color: AppColors.darkDivider,
            width: 0.5,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        hintStyle: const TextStyle(
          color: AppColors.darkSecondaryText,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.darkPrimary,
            width: 1.2,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
        ),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.darkPrimary,
        size: 22,
      ),

      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkBackground,
        elevation: 4,
        shape: CircleBorder(),
      ),

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkSecondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
        ),
      ),

      dividerColor: AppColors.darkDivider,

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.darkText,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.darkText,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.darkText,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: AppColors.darkSecondaryText,
          fontSize: 13,
        ),
        bodySmall: TextStyle(
          color: AppColors.darkSecondaryText,
          fontSize: 11,
        ),
      ),
    );
  }
}
