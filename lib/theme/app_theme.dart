import 'package:flutter/material.dart';

class AppTheme {
  // Soft, calm colors with light tones
  static const Color primaryLight = Color(0xFFE8F4F8); // Very light blue
  static const Color secondaryLight = Color(0xFFF5E6F8); // Very light purple
  static const Color accentLight = Color(0xFFFFF4E6); // Very light orange
  static const Color backgroundLight = Color(0xFFF8F9FA); // Off-white
  static const Color cardBackground = Color(0xFFFAFBFC); // Slightly lighter
  
  // Glass effect colors
  static const Color glassWhite = Color(0xFFFFFFFF);
  static const Color glassBorder = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B7280);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Gradient backgrounds
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F4F8),
      Color(0xFFF5E6F8),
      Color(0xFFFFF4E6),
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8F9FA),
    ],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: backgroundLight,
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textBlack),
        titleTextStyle: TextStyle(
          color: textBlack,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textBlack,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textBlack,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textBlack,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textGray,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textGray,
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: textBlack,
        size: 24,
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: glassWhite.withOpacity(0.3),
          foregroundColor: textBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: glassBorder,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassWhite.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: glassBorder,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: glassBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: glassBorder,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: glassWhite.withOpacity(0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: glassBorder,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
