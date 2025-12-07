import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Application Theme Configuration
/// 
/// Centralized theme configuration for the AuPlant IoT application.
/// Defines the Material Design theme with custom colors, typography,
/// and component styles.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      switchTheme: _switchTheme,
      snackBarTheme: _snackBarTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      dividerTheme: _dividerTheme,
      iconTheme: _iconTheme,
      splashColor: AppColors.primaryGreenAlpha10,
      highlightColor: AppColors.primaryGreenAlpha10,
      scaffoldBackgroundColor: AppColors.backgroundLight,
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarThemeDark,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationThemeDark,
      cardTheme: _cardThemeDark,
      switchTheme: _switchTheme,
      snackBarTheme: _snackBarTheme,
      bottomNavigationBarTheme: _bottomNavigationBarThemeDark,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      dividerTheme: _dividerThemeDark,
      iconTheme: _iconTheme,
      splashColor: AppColors.primaryGreenAlpha10,
      highlightColor: AppColors.primaryGreenAlpha10,
      scaffoldBackgroundColor: const Color(0xFF111315),
    );
  }

  /// Light color scheme
  static ColorScheme get _lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.light,
      primary: AppColors.primaryGreen,
      secondary: AppColors.secondaryGreen,
      surface: AppColors.backgroundWhite,
      error: AppColors.error,
      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textLight,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textLight,
    );
  }

  /// Dark color scheme
  static ColorScheme get _darkColorScheme {
    return ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.dark,
      primary: AppColors.primaryGreen,
      secondary: AppColors.secondaryGreen,
      surface: const Color(0xFF1A1C1E),
      error: AppColors.error,
      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textLight,
      onSurface: const Color(0xFFE6E8E6),
      onError: AppColors.textLight,
    );
  }

  /// Text theme configuration
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    );
  }

  /// App bar theme configuration
  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.backgroundWhite,
      foregroundColor: AppColors.textPrimary,
      elevation: 2,
      shadowColor: AppColors.shadowMedium,
      centerTitle: false,
      titleTextStyle: AppTextStyles.appBarTitle,
      iconTheme: const IconThemeData(
        color: AppColors.primaryGreen,
        size: 24,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  static AppBarTheme get _appBarThemeDark {
    return AppBarTheme(
      backgroundColor: const Color(0xFF1A1C1E),
      foregroundColor: const Color(0xFFE6E8E6),
      elevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(color: const Color(0xFFE6E8E6)),
      iconTheme: const IconThemeData(
        color: AppColors.primaryGreen,
        size: 24,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  /// Elevated button theme configuration
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    );
  }

  /// Outlined button theme configuration
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    );
  }

  /// Text button theme configuration
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    );
  }

  /// Input decoration theme configuration
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTextStyles.formLabel,
      hintStyle: AppTextStyles.formHelper,
      errorStyle: AppTextStyles.formError,
      contentPadding: const EdgeInsets.all(16),
    );
  }

  static InputDecorationTheme get _inputDecorationThemeDark {
    return InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF232528),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2B2E31)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2B2E31)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTextStyles.formLabel.copyWith(color: const Color(0xFFCAD0C9)),
      hintStyle: AppTextStyles.formHelper.copyWith(color: const Color(0xFF9AA19A)),
      errorStyle: AppTextStyles.formError,
      contentPadding: const EdgeInsets.all(16),
    );
  }

  /// Card theme configuration
  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.backgroundWhite,
      shadowColor: AppColors.shadowLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static CardThemeData get _cardThemeDark {
    return CardThemeData(
      color: const Color(0xFF1A1C1E),
      shadowColor: Colors.black.withValues(alpha: 0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Switch theme configuration
  static SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.backgroundWhite;
        }
        return AppColors.disabled;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryGreen;
        }
        return AppColors.border;
      }),
    );
  }

  /// Snack bar theme configuration
  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.primaryGreen,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textLight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  /// Bottom navigation bar theme configuration
  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundWhite,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppTextStyles.navigationLabelSelected,
      unselectedLabelStyle: AppTextStyles.navigationLabel,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  static BottomNavigationBarThemeData get _bottomNavigationBarThemeDark {
    return BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1A1C1E),
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: const Color(0xFF8B938C),
      selectedLabelStyle: AppTextStyles.navigationLabelSelected.copyWith(color: AppColors.primaryGreen),
      unselectedLabelStyle: AppTextStyles.navigationLabel.copyWith(color: const Color(0xFF8B938C)),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }

  /// Floating action button theme configuration
  static FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.textLight,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  /// Divider theme configuration
  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    );
  }

  static DividerThemeData get _dividerThemeDark {
    return const DividerThemeData(
      color: Color(0xFF2B2E31),
      thickness: 1,
      space: 1,
    );
  }

  /// Icon theme configuration
  static IconThemeData get _iconTheme {
    return const IconThemeData(
      color: AppColors.primaryGreen,
      size: 24,
    );
  }
}
