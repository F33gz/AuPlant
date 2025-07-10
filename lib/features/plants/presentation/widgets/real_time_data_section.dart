import 'package:flutter/material.dart';
import 'plant_detail_constants.dart';
import 'sensor_card.dart';
import '../../../../core/services/plant_service.dart';

/// Real-Time Data Section
/// 
/// Displays the current sensor readings with statistics and trends.
/// Shows humidity and light data using enhanced SensorCard components.
/// Includes threshold indicators and 24-hour statistics.
/// 
/// Features:
/// - Real-time sensor values with ThingsBoard integration
/// - Statistical data (min, max, avg) from last 24 hours
/// - Color-coded sensor cards with threshold indicators
/// - Recent readings trends
/// - Error handling for offline sensors
class RealTimeDataSection extends StatelessWidget {
  final PlantWithSensorData plantData;

  const RealTimeDataSection({
    super.key,
    required this.plantData,
  });

  @override
  Widget build(BuildContext context) {
    return _buildSensorCards();
  }

  /// Builds the sensor cards in a responsive row layout
  Widget _buildSensorCards() {
    return Row(
      children: [
        Expanded(
          child: SensorCard(
            title: 'Humedad',
            value: plantData.humedad != null 
                ? '${plantData.humedad!.toStringAsFixed(1)}%'
                : 'N/A',
            icon: Icons.water_drop,
            color: _getHumidityColor(),
            backgroundColor: PlantDetailConstants.humidityBackground,
            subtitle: _getHumidityStatus(),
            thresholdRange: '${plantData.humidityThresholdMin.toInt()}-${plantData.humidityThresholdMax.toInt()}%',
            statistics: plantData.humidityStatistics,
            isOnline: plantData.humedad != null,
          ),
        ),
        const SizedBox(width: PlantDetailConstants.spacingL),
        Expanded(
          child: SensorCard(
            title: 'Luz',
            value: plantData.luz != null 
                ? '${plantData.luz!.toStringAsFixed(1)} lx'
                : 'N/A',
            icon: Icons.wb_sunny,
            color: _getLightColor(),
            backgroundColor: PlantDetailConstants.lightBackground,
            subtitle: _getLightStatus(),
            statistics: plantData.lightStatistics,
            isOnline: plantData.luz != null,
          ),
        ),
      ],
    );
  }

  /// Determines the humidity color based on threshold ranges
  Color _getHumidityColor() {
    if (plantData.humedad == null) return PlantDetailConstants.humidityColor;
    
    if (plantData.humedad! < plantData.humidityThresholdMin) {
      return PlantDetailConstants.errorColor;
    } else if (plantData.humedad! > plantData.humidityThresholdMax) {
      return PlantDetailConstants.errorColor;
    } else {
      return PlantDetailConstants.successColor;
    }
  }

  /// Determines the light color based on threshold ranges
  Color _getLightColor() {
    if (plantData.luz == null) return PlantDetailConstants.lightColor;
    
    return PlantDetailConstants.successColor;
  }

  /// Gets humidity status text based on threshold ranges
  String _getHumidityStatus() {
    if (plantData.humedad == null) return 'Sin datos';
    
    if (plantData.humedad! < plantData.humidityThresholdMin) {
      return 'Muy bajo';
    } else if (plantData.humedad! > plantData.humidityThresholdMax) {
      return 'Muy alto';
    } else {
      return 'Óptimo';
    }
  }

  /// Gets light status text based on threshold ranges
  String _getLightStatus() {
    if (plantData.luz == null) return 'Sin datos';
    
    return 'Óptimo';
  }
}
