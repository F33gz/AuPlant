import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';

/// Health Status Data Class
class HealthStatus {
  final String displayName;
  final IconData icon;
  final Color color;

  HealthStatus({
    required this.displayName,
    required this.icon,
    required this.color,
  });
}

/// Plant Health Status Widget
/// 
/// Displays the health status of a plant
class PlantHealthStatusWidget extends StatelessWidget {
  final HealthStatus healthStatus;

  const PlantHealthStatusWidget({
    super.key,
    required this.healthStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: healthStatus.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(
          color: healthStatus.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            healthStatus.icon,
            color: healthStatus.color,
            size: 32,
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de Salud',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  healthStatus.displayName,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: healthStatus.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
