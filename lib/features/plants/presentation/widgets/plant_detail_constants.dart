import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';

/// Plant Detail Constants
/// 
/// Constants specific to plant detail view components.
/// Contains styling, sizing, and layout values used across
/// plant detail widgets.
class PlantDetailConstants {
  // Private constructor to prevent instantiation
  PlantDetailConstants._();

  // App Bar
  static const double appBarHeight = 200.0;
  static const double appBarExpandedHeight = 300.0;
  static const double appBarCollapsedHeight = 120.0;
  
  // Card dimensions
  static const double cardHeight = 140.0;
  static const double cardWidth = 180.0;
  
  // Spacing (using UIConstants)
  static const double spacingXS = UIConstants.spacingXS;
  static const double spacingS = UIConstants.spacingS;
  static const double spacingM = UIConstants.spacingM;
  static const double spacingL = UIConstants.spacingL;
  static const double spacingXL = UIConstants.spacingXL;
  static const double spacingXXL = UIConstants.spacingXXL;
  static const double sectionSpacing = UIConstants.spacingXXL;
  static const double cardSpacing = UIConstants.spacingL;
  static const double itemSpacing = UIConstants.spacingM;
  
  // Padding
  static const double sectionPadding = UIConstants.paddingL;
  static const double cardPadding = UIConstants.paddingM;
  static const double itemPadding = UIConstants.paddingS;
  
  // Border radius
  static const double cardRadius = UIConstants.radiusM;
  static const double buttonRadius = UIConstants.radiusL;
  
  // Icon sizes
  static const double iconSizeSmall = UIConstants.iconM;
  static const double iconSizeMedium = UIConstants.iconL;
  static const double iconSizeLarge = UIConstants.iconXL;
  static const double iconSizeM = UIConstants.iconM;
  static const double iconSizeL = UIConstants.iconL;
  static const double iconSizeXL = UIConstants.iconXL;
  
  // Colors
  static const Color backgroundColor = AppColors.backgroundLight;
  static const Color cardBackgroundColor = AppColors.backgroundWhite;
  static const Color cardBackground = AppColors.backgroundWhite;
  static const Color primaryColor = AppColors.primaryGreen;
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color textColor = AppColors.textPrimary;
  static const Color textTertiary = AppColors.textTertiary;
  static const Color secondaryTextColor = AppColors.textSecondary;
  static const Color borderColor = AppColors.border;
  static const Color shadowColor = AppColors.shadow;
  static const Color successColor = AppColors.success;
  static const Color errorColor = AppColors.error;
  static const Color humidityColor = AppColors.humidity;
  static const Color humidityBackground = AppColors.humidityBackground;
  static const Color lightColor = AppColors.light;
  static const Color lightBackground = AppColors.lightBackground;
  
  // Text styles - using getters since TextStyle is not const
  static TextStyle get titleStyle => AppTextStyles.titleMedium;
  static TextStyle get subtitleStyle => AppTextStyles.bodyMedium;
  static TextStyle get bodyStyle => AppTextStyles.bodySmall;
  static TextStyle get captionStyle => AppTextStyles.labelSmall;
  static TextStyle get titleMedium => AppTextStyles.titleMedium;
  static TextStyle get titleSmall => AppTextStyles.titleSmall;
  static TextStyle get titleLarge => AppTextStyles.titleLarge;
  static TextStyle get bodyMedium => AppTextStyles.bodyMedium;
  static TextStyle get bodySmall => AppTextStyles.bodySmall;
  static TextStyle get labelMedium => AppTextStyles.labelMedium;
  static TextStyle get successText => AppTextStyles.bodySmall.copyWith(color: AppColors.success);
  static TextStyle get errorText => AppTextStyles.bodySmall.copyWith(color: AppColors.error);
  
  // Button styles
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: UIConstants.paddingL,
    vertical: UIConstants.paddingM,
  );
  
  // Button dimensions
  static const double buttonHeight = 48.0;
  
  // Button style getters
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
  );
  
  static ButtonStyle get disabledButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.disabled,
    foregroundColor: AppColors.textSecondary,
    elevation: 0,
    padding: buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
  );
  
  // Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackgroundColor,
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow: [
      BoxShadow(
        color: shadowColor,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration get controlItemDecoration => BoxDecoration(
    color: cardBackgroundColor,
    borderRadius: BorderRadius.circular(UIConstants.radiusM),
    border: Border.all(color: borderColor),
  );
  
  static BoxDecoration get chartPlaceholderDecoration => BoxDecoration(
    color: AppColors.backgroundGray,
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: borderColor),
  );
  
  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  
  // Connection indicator
  static const double connectionIndicatorSize = 12.0;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  static const Duration animationFast = Duration(milliseconds: 150);
  
  // Chart dimensions
  static const double chartHeight = 200.0;
  static const double chartWidth = double.infinity;
  
  // Control section
  static const double controlButtonSize = 60.0;
  static const double controlIconSize = 24.0;
  
  // Status indicators
  static const double statusIndicatorSize = 12.0;
  static const double statusIndicatorRadius = 6.0;
  
  // Sensor card specific
  static const double sensorCardMinHeight = 120.0;
  static const double sensorValueFontSize = 24.0;
  static const double sensorLabelFontSize = 14.0;
  
  // Thresholds
  static const double minSliderValue = 0.0;
  static const double maxSliderValue = 100.0;
  static const double sliderDivisions = 20.0;
  
  // Layout breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  
  // Grid layout
  static const int mobileGridColumns = 1;
  static const int tabletGridColumns = 2;
  static const int desktopGridColumns = 3;
  
  // Responsive spacing
  static const double responsiveSpacingFactor = 1.2;
  
  // Loading states
  static const double loadingIndicatorSize = 24.0;
  static const Duration loadingAnimationDuration = Duration(milliseconds: 800);
  
  // Error states
  static const double errorIconSize = 48.0;
  static const EdgeInsets errorPadding = EdgeInsets.all(UIConstants.paddingXXL);
  
  // Empty states
  static const double emptyStateIconSize = 64.0;
  static const EdgeInsets emptyStatePadding = EdgeInsets.all(UIConstants.paddingXXL);
  
  // Time period button styling
  static BoxDecoration timePeriodButtonDecoration(bool isSelected) {
    return BoxDecoration(
      color: isSelected ? primaryGreen : cardBackgroundColor,
      borderRadius: BorderRadius.circular(UIConstants.radiusS),
      border: Border.all(
        color: isSelected ? primaryGreen : borderColor,
      ),
    );
  }
  
  static TextStyle timePeriodButtonTextStyle(bool isSelected) {
    return AppTextStyles.labelMedium.copyWith(
      color: isSelected ? Colors.white : AppColors.textPrimary,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
    );
  }
}
