/// UI Constants
/// 
/// Centralized UI constants for spacing, sizing, and layout values
/// used throughout the AuPlant IoT application.
class UIConstants {
  // Private constructor to prevent instantiation
  UIConstants._();

  // Spacing values
  static const double spacingXXS = 2.0;
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // Padding values
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;

  // Margin values
  static const double marginXS = 4.0;
  static const double marginS = 8.0;
  static const double marginM = 12.0;
  static const double marginL = 16.0;
  static const double marginXL = 20.0;
  static const double marginXXL = 24.0;

  // Border radius values
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // Icon sizes
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;

  // Button sizes
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 40.0;
  static const double buttonHeightL = 48.0;
  static const double buttonHeightXL = 56.0;

  // Card sizes
  static const double cardMinHeight = 80.0;
  static const double cardMaxHeight = 200.0;
  static const double cardElevation = 2.0;

  // List item sizes
  static const double listItemHeight = 72.0;
  static const double listItemMinHeight = 56.0;

  // Touch target sizes (following Material Design guidelines)
  static const double touchTargetSize = 48.0;
  static const double touchTargetMinSize = 44.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Breakpoints for responsive design
  static const double breakpointXS = 480.0;
  static const double breakpointS = 768.0;
  static const double breakpointM = 1024.0;
  static const double breakpointL = 1440.0;
  static const double breakpointXL = 1920.0;

  // App bar heights
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 64.0;

  // Bottom navigation bar height
  static const double bottomNavBarHeight = 56.0;

  // Floating action button sizes
  static const double fabSize = 56.0;
  static const double fabSizeSmall = 40.0;
  static const double fabSizeLarge = 96.0;

  // Divider thickness
  static const double dividerThickness = 1.0;
  static const double dividerThicknessBold = 2.0;

  // Border widths
  static const double borderThin = 1.0;
  static const double borderMedium = 2.0;
  static const double borderThick = 3.0;

  // Elevation values
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;

  // Opacity values
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.60;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;

  // Z-index values
  static const int zIndexBackground = 0;
  static const int zIndexContent = 1;
  static const int zIndexFloating = 2;
  static const int zIndexModal = 3;
  static const int zIndexTooltip = 4;
  static const int zIndexOverlay = 5;
}
