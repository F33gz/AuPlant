import 'package:flutter/material.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../domain/entities/plant.dart';
import '../../../../shared/constants/ui_constants.dart';

/// Plant Card Widget
/// 
/// A card widget that displays plant information including name, emoji,
/// sensor data, and status. Navigates to plant detail when tapped.
class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;

  const PlantCard({
    super.key,
    required this.plant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingS),
      child: GestureDetector(
        onTap: onTap ?? () {
          Navigator.pushNamed(
            context,
            AppRoutes.plantDetail,
            arguments: plant,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            boxShadow: [
              BoxShadow(
                blurRadius: UIConstants.elevationMedium,
                color: AppColors.shadowLight,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
            border: Border.all(
              color: AppColors.border,
              width: UIConstants.borderThin,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.paddingM),
            child: Row(
              children: [
                _buildPlantIcon(),
                const SizedBox(width: UIConstants.spacingL),
                Expanded(child: _buildPlantInfo()),
                const SizedBox(width: UIConstants.spacingS),
                _buildArrowIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the plant icon with gradient background
  Widget _buildPlantIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          plant.emoji,
          style: const TextStyle(fontSize: UIConstants.iconL),
        ),
      ),
    );
  }

  /// Builds the plant information section
  Widget _buildPlantInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plant.name,
          style: AppTextStyles.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: UIConstants.spacingXS),
        _buildSensorData(),
        const SizedBox(height: UIConstants.spacingXS),
        _buildStatusInfo(),
      ],
    );
  }

  /// Builds the sensor data row
  Widget _buildSensorData() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Humedad: ${plant.thresholds.minHumidity.toStringAsFixed(0)}-${plant.thresholds.maxHumidity.toStringAsFixed(0)}%',
            style: AppTextStyles.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: UIConstants.spacingL),
        Expanded(
          child: Text(
            'Luz: ${plant.thresholds.minLight.toStringAsFixed(0)}-${plant.thresholds.maxLight.toStringAsFixed(0)} lx',
            style: AppTextStyles.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the status information row
  Widget _buildStatusInfo() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Última actualización: Hoy',
            style: AppTextStyles.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: UIConstants.spacingL),
        Text(
          'Activa',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  /// Builds the arrow icon
  Widget _buildArrowIcon() {
    return Icon(
      Icons.arrow_forward_ios,
      size: UIConstants.iconS,
      color: AppColors.textSecondary,
    );
  }
}
