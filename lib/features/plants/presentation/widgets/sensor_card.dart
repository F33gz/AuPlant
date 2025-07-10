import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../../core/services/plant_service.dart';

/// Sensor Card Widget
/// 
/// A reusable card component for displaying sensor data with an icon,
/// title, value, status, statistics, and threshold information.
/// Used for humidity, light, and other sensor readings.
/// 
/// Features:
/// - Real-time sensor values with connection status
/// - Statistical data display (min, max, avg)
/// - Customizable icon, colors, and text
/// - Optional subtitle for status information
/// - Optional threshold range display
/// - Consistent styling with the app theme
/// - Responsive design
/// - Accessibility support
class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String? subtitle;
  final String? thresholdRange;
  final SensorStatistics? statistics;
  final bool isOnline;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.subtitle,
    this.thresholdRange,
    this.statistics,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: UIConstants.elevationMedium,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: UIConstants.spacingM),
          _buildValue(),
          if (subtitle != null) ...[
            const SizedBox(height: UIConstants.spacingXS),
            _buildSubtitle(),
          ],
          if (thresholdRange != null) ...[
            const SizedBox(height: UIConstants.spacingXS),
            _buildThresholdRange(),
          ],
          if (statistics != null) ...[
            const SizedBox(height: UIConstants.spacingM),
            _buildStatistics(),
          ],
        ],
      ),
    );
  }

  /// Builds the header section with icon, title, and connection status
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(UIConstants.paddingS),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(UIConstants.radiusS),
          ),
          child: Icon(
            icon,
            color: color,
            size: UIConstants.iconM,
          ),
        ),
        const SizedBox(width: UIConstants.spacingM),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  /// Builds the value display section
  Widget _buildValue() {
    return Text(
      value,
      style: AppTextStyles.sensorValue,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the subtitle/status section
  Widget _buildSubtitle() {
    return Text(
      subtitle!,
      style: AppTextStyles.labelSmall.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the threshold range section
  Widget _buildThresholdRange() {
    return Text(
      'Rango: $thresholdRange',
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textTertiary,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the statistics section showing min, max, avg
  Widget _buildStatistics() {
    if (statistics == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingS),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Min', statistics!.min),
          _buildStatItem('Prom', statistics!.avg),
          _buildStatItem('Máx', statistics!.max),
        ],
      ),
    );
  }

  /// Builds a single statistic item
  Widget _buildStatItem(String label, double? value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: UIConstants.spacingXS),
        Text(
          value != null ? value.toStringAsFixed(1) : 'N/A',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
