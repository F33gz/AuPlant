import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../domain/entities/plant.dart';

/// Plant Thresholds Widget
/// 
/// Displays plant threshold configuration
class PlantThresholdsWidget extends StatelessWidget {
  final Plant plant;

  const PlantThresholdsWidget({
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
          Text(
            'Configuración de Umbrales',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildThresholdRow(
            'Humedad',
            '${plant.thresholds.minHumidity.toStringAsFixed(0)}% - ${plant.thresholds.maxHumidity.toStringAsFixed(0)}%',
            Icons.water_drop,
            Colors.blue,
          ),
          const SizedBox(height: UIConstants.spacingS),
          _buildThresholdRow(
            'Luz',
            '${plant.thresholds.minLight.toStringAsFixed(0)} - ${plant.thresholds.maxLight.toStringAsFixed(0)} lux',
            Icons.wb_sunny,
            Colors.orange,
          ),
          const SizedBox(height: UIConstants.spacingM),
          Row(
            children: [
              Icon(
                Icons.auto_mode,
                color: AppColors.primaryGreen,
                size: 16,
              ),
              const SizedBox(width: UIConstants.spacingS),
              Text(
                'Modo Manual',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdRow(String label, String range, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: UIConstants.spacingS),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          range,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
