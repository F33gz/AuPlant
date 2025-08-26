import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../features/plants/domain/entities/sensor_data.dart';

class SensorDataCard extends StatelessWidget {
  final SensorData sensorData;
  final VoidCallback? onRefresh;

  const SensorDataCard({
    super.key,
    required this.sensorData,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Datos del Sensor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: Icon(Icons.refresh, color: AppColors.primaryGreen),
                    onPressed: onRefresh,
                  ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SensorMetric(
                    icon: Icons.water_drop,
                    label: 'Humedad',
                    value: '${sensorData.humidity?.toStringAsFixed(1) ?? '--'}%',
                    color: AppColors.info,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _SensorMetric(
                    icon: Icons.wb_sunny,
                    label: 'Luz',
                    value: '${sensorData.light?.toStringAsFixed(0) ?? '--'} lux',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SensorMetric(
                    icon: Icons.thermostat,
                    label: 'Temperatura',
                    value: '${sensorData.temperature?.toStringAsFixed(1) ?? '--'}°C',
                    color: AppColors.error,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _SensorMetric(
                    icon: Icons.science,
                    label: 'pH',
                    value: '7.0', // Mock pH data
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SensorMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
