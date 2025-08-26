import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../domain/entities/sensor_data.dart';

/// Sensor Data Grid Widget
/// 
/// Displays sensor data in a grid format
class SensorDataGrid extends StatelessWidget {
  final SensorData sensorData;

  const SensorDataGrid({
    super.key,
    required this.sensorData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos de Sensores',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: UIConstants.spacingM),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: UIConstants.spacingM,
          mainAxisSpacing: UIConstants.spacingM,
          children: [
            _buildSensorCard(
              'Humedad del Suelo',
              '${sensorData.humidity?.toStringAsFixed(1) ?? '--'}%',
              Icons.water_drop,
              Colors.blue,
            ),
            _buildSensorCard(
              'Luz',
              '${sensorData.light?.toStringAsFixed(0) ?? '--'} lux',
              Icons.wb_sunny,
              Colors.orange,
            ),
            _buildSensorCard(
              'Temperatura',
              '${sensorData.temperature?.toStringAsFixed(1) ?? '--'}°C',
              Icons.thermostat,
              Colors.red,
            ),
            _buildSensorCard(
              'Humedad Ambiental',
              '${(sensorData.temperature != null ? (sensorData.temperature! * 0.8).toStringAsFixed(1) : '--')}%', // Mock data
              Icons.air,
              Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingXS),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
