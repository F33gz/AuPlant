import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../domain/entities/plant.dart';

/// Plant Info Card Widget
/// 
/// Displays basic plant information in a card format
class PlantInfoCard extends StatelessWidget {
  final Plant plant;

  const PlantInfoCard({
    super.key,
    required this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: UIConstants.spacingS),
              Text(
                plant.location ?? 'Sin ubicación',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (plant.description.isNotEmpty) ...[
            const SizedBox(height: UIConstants.spacingM),
            Text(
              plant.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (plant.deviceId != null) ...[
            const SizedBox(height: UIConstants.spacingM),
            Row(
              children: [
                Icon(Icons.sensors, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: UIConstants.spacingS),
                Text(
                  'Device: ${plant.deviceId}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
