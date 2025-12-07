import 'package:flutter/material.dart';

/// Application Color Palette
/// 
/// Centralized color definitions for the AuPlant IoT application.
/// All colors used throughout the app should be defined here to maintain
/// consistency and enable easy theming changes.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary brand colors
  static const Color primaryGreen = Color(0xFF2D5A27);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF7CB342);
  static const Color darkGreen = Color(0xFF4A7C59);

  // Background colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundWhite = Colors.white;
  static const Color backgroundGray = Color(0xFFE5E5E5);
  // Dark palette tokens
  static const Color backgroundDark = Color(0xFF111315);
  static const Color surfaceDark = Color(0xFF1A1C1E);
  static const Color borderDark = Color(0xFF2B2E31);

  // Text colors
  static const Color textPrimary = Color(0xFF2D5A27);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textLight = Colors.white;
  static const Color textOnDark = Color(0xFFE6E8E6);
  static const Color textMutedOnDark = Color(0xFF8B938C);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color errorContainerDark = Color(0xFF2B1F21);
  static const Color onErrorContainerDark = Color(0xFFFFB4AB);

  // Sensor specific colors
  static const Color humidity = Color(0xFF4CAF50);
  static const Color humidityBackground = Color(0xFFE8F5E8);
  static const Color light = Color(0xFFFF9800);
  static const Color lightBackground = Color(0xFFFFF3E0);
  static const Color temperature = Color(0xFF2196F3);
  static const Color temperatureBackground = Color(0xFFE3F2FD);
  static const Color soil = Color(0xFF8D6E63);
  static const Color soilBackground = Color(0xFFF3E5F5);

  // Border and divider colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE5E5E5);

  // Shadow colors
  static const Color shadow = Color(0x14000000);
  static const Color shadowDark = Color(0x29000000);

  // Online/Offline status
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFFF44336);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lightGreen, darkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [backgroundWhite, backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Alpha variations
  static Color get primaryGreenAlpha10 => primaryGreen.withValues(alpha: 0.1);
  static Color get primaryGreenAlpha30 => primaryGreen.withValues(alpha: 0.3);
  static Color get primaryGreenAlpha70 => primaryGreen.withValues(alpha: 0.7);
  static Color get shadowLight => Colors.black.withValues(alpha: 0.05);
  static Color get shadowMedium => Colors.black.withValues(alpha: 0.1);
  static Color get shadowHeavy => Colors.black.withValues(alpha: 0.2);
}
