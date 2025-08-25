import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Sensor data entity representing real-time plant sensor readings
class SensorData extends Equatable {
  final String plantId;
  final double? humidity;
  final double? light;
  final double? temperature;
  final bool isOnline;
  final DateTime timestamp;
  final List<SensorDataPoint> recentHumidityReadings;
  final List<SensorDataPoint> recentLightReadings;
  final SensorStatistics? humidityStatistics;
  final SensorStatistics? lightStatistics;

  const SensorData({
    required this.plantId,
    this.humidity,
    this.light,
    this.temperature,
    required this.isOnline,
    required this.timestamp,
    this.recentHumidityReadings = const [],
    this.recentLightReadings = const [],
    this.humidityStatistics,
    this.lightStatistics,
  });

  @override
  List<Object?> get props => [
        plantId,
        humidity,
        light,
        temperature,
        isOnline,
        timestamp,
        recentHumidityReadings,
        recentLightReadings,
        humidityStatistics,
        lightStatistics,
      ];
}

/// Individual sensor data point with timestamp and value
class SensorDataPoint extends Equatable {
  final DateTime timestamp;
  final double value;

  const SensorDataPoint({
    required this.timestamp,
    required this.value,
  });

  @override
  List<Object> get props => [timestamp, value];
}

/// Sensor statistics containing min, max, average values
class SensorStatistics extends Equatable {
  final double? min;
  final double? max;
  final double? avg;
  final int count;

  const SensorStatistics({
    this.min,
    this.max,
    this.avg,
    this.count = 0,
  });

  @override
  List<Object?> get props => [min, max, avg, count];
}

/// Plant health status enumeration
enum PlantHealthStatus {
  healthy,
  needsWater,
  needsLight,
  warning,
  offline,
}

/// Extension for PlantHealthStatus
extension PlantHealthStatusExtension on PlantHealthStatus {
  String get displayName {
    switch (this) {
      case PlantHealthStatus.healthy:
        return 'Saludable';
      case PlantHealthStatus.needsWater:
        return 'Necesita agua';
      case PlantHealthStatus.needsLight:
        return 'Necesita luz';
      case PlantHealthStatus.warning:
        return 'Alerta';
      case PlantHealthStatus.offline:
        return 'Sin conexión';
    }
  }

  Color get color {
    switch (this) {
      case PlantHealthStatus.healthy:
        return const Color(0xFF4CAF50); // Green
      case PlantHealthStatus.needsWater:
        return const Color(0xFF2196F3); // Blue
      case PlantHealthStatus.needsLight:
        return const Color(0xFFFF9800); // Orange
      case PlantHealthStatus.warning:
        return const Color(0xFFFFC107); // Amber
      case PlantHealthStatus.offline:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData get icon {
    switch (this) {
      case PlantHealthStatus.healthy:
        return Icons.check_circle;
      case PlantHealthStatus.needsWater:
        return Icons.water_drop;
      case PlantHealthStatus.needsLight:
        return Icons.wb_sunny;
      case PlantHealthStatus.warning:
        return Icons.warning;
      case PlantHealthStatus.offline:
        return Icons.wifi_off;
    }
  }
}
