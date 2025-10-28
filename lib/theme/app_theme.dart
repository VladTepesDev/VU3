import 'package:flutter/material.dart';

class AppTheme {
  // Pure grayscale background colors
  static const Color backgroundStart = Color(0xFFF0F0F0);
  static const Color backgroundEnd = Color(0xFFE0E0E0);

  // Glass surface colors - pure white/gray only
  static const Color glassWhite = Color(0xFFFFFFFF);
  static const Color glassGray = Color(0xFFF5F5F5);

  // Text colors - pure black, gray, white only
  static const Color textBlack = Color(0xFF000000);
  static const Color textDarkGray = Color(0xFF333333);
  static const Color textGray = Color(0xFF888888);
  static const Color textLightGray = Color(0xFFCCCCCC);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Border colors - white and light gray
  static const Color borderWhite = Color(0xFFFFFFFF);
  static const Color borderGray = Color(0xFFDDDDDD);

  // Shadows
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x0D000000);
  
  // Subtle colorful shadows for bubble elements (different colors per page)
  static const Color bubbleShadowBlue = Color(0x3064B5F6);    // Soft blue - 19% opacity
  static const Color bubbleShadowGreen = Color(0x3081C784);   // Soft green - 19% opacity
  static const Color bubbleShadowRed = Color(0x30EF5350);     // Soft red - 19% opacity
  static const Color bubbleShadowPurple = Color(0x30AB47BC);  // Soft purple - 19% opacity

  // Accent colors for statistics and charts
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color backgroundDark = Color(0xFF2C2C2C);
  static const Color backgroundLight = Color(0xFF3A3A3A);

  // Pure grayscale gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0F0F0),
      Color(0xFFE0E0E0),
    ],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: textBlack,
      scaffoldBackgroundColor: backgroundStart,

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
          color: textDarkGray,
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
      
      iconTheme: const IconThemeData(
        color: textBlack,
        size: 24,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: glassWhite.withValues(alpha: 0.3),
          foregroundColor: textBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: borderWhite,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassWhite.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: borderWhite,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: borderWhite,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: borderWhite,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      
      cardTheme: CardThemeData(
        color: glassWhite.withValues(alpha: 0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: borderWhite,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
