import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/plant.dart';
import '../../domain/entities/sensor_data.dart';

class PlantHealthStatus extends StatelessWidget {
  final Plant plant;
  final SensorData? sensorData;

  const PlantHealthStatus({
    super.key,
    required this.plant,
    this.sensorData,
  });

  @override
  Widget build(BuildContext context) {
    if (sensorData == null) {
      return _buildNoDataCard();
    }

    final healthStatus = _calculateHealthStatus();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  healthStatus.icon,
                  color: healthStatus.color,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Estado de Salud',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: healthStatus.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          healthStatus.status,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: healthStatus.color,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          healthStatus.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.sensors_off,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'Sin datos del sensor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'No se pueden obtener datos del dispositivo IoT',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  _HealthStatus _calculateHealthStatus() {
    if (sensorData == null) {
      return _HealthStatus(
        status: 'Sin datos',
        message: 'No se pueden obtener datos del sensor',
        color: AppColors.textSecondary,
        icon: Icons.sensors_off,
      );
    }

    final humidity = sensorData!.humidity;
    final thresholds = plant.thresholds;
    
    // Check humidity levels
    if (humidity != null && humidity < thresholds.minHumidity) {
      return _HealthStatus(
        status: 'Necesita agua',
        message: 'La humedad está por debajo del nivel óptimo',
        color: AppColors.error,
        icon: Icons.water_drop_outlined,
      );
    } else if (humidity != null && humidity > thresholds.maxHumidity) {
      return _HealthStatus(
        status: 'Demasiada agua',
        message: 'La humedad está por encima del nivel óptimo',
        color: AppColors.warning,
        icon: Icons.warning,
      );
    } else {
      return _HealthStatus(
        status: 'Saludable',
        message: 'Todos los parámetros están en rango óptimo',
        color: AppColors.success,
        icon: Icons.eco,
      );
    }
  }
}

class _HealthStatus {
  final String status;
  final String message;
  final Color color;
  final IconData icon;

  _HealthStatus({
    required this.status,
    required this.message,
    required this.color,
    required this.icon,
  });
}
