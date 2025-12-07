import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Sensor data entity representing real-time station sensor readings
/// 
/// Contains current readings for:
/// - Soil humidity (humedad del suelo)
/// - Ambient humidity (humedad ambiente)  
/// - Temperature (temperatura)
class SensorData extends Equatable {
  final String stationId;
  final double? soilHumidity;
  final double? ambientHumidity;
  final double? temperature;
  final bool isOnline;
  final DateTime timestamp;
  final List<SensorDataPoint> recentSoilHumidityReadings;
  final List<SensorDataPoint> recentAmbientHumidityReadings;
  final List<SensorDataPoint> recentTemperatureReadings;
  final SensorStatistics? soilHumidityStatistics;
  final SensorStatistics? ambientHumidityStatistics;
  final SensorStatistics? temperatureStatistics;

  const SensorData({
    required this.stationId,
    this.soilHumidity,
    this.ambientHumidity,
    this.temperature,
    required this.isOnline,
    required this.timestamp,
    this.recentSoilHumidityReadings = const [],
    this.recentAmbientHumidityReadings = const [],
    this.recentTemperatureReadings = const [],
    this.soilHumidityStatistics,
    this.ambientHumidityStatistics,
    this.temperatureStatistics,
  });

  @override
  List<Object?> get props => [
        stationId,
        soilHumidity,
        ambientHumidity,
        temperature,
        isOnline,
        timestamp,
        recentSoilHumidityReadings,
        recentAmbientHumidityReadings,
        recentTemperatureReadings,
        soilHumidityStatistics,
        ambientHumidityStatistics,
        temperatureStatistics,
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

/// Station health status enumeration
enum StationHealthStatus {
  healthy,
  lowSoilHumidity,
  highTemperature,
  lowTemperature,
  warning,
  offline,
}

/// Extension for StationHealthStatus
extension StationHealthStatusExtension on StationHealthStatus {
  String get displayName {
    switch (this) {
      case StationHealthStatus.healthy:
        return 'Saludable';
      case StationHealthStatus.lowSoilHumidity:
        return 'Humedad baja';
      case StationHealthStatus.highTemperature:
        return 'Temperatura alta';
      case StationHealthStatus.lowTemperature:
        return 'Temperatura baja';
      case StationHealthStatus.warning:
        return 'Alerta';
      case StationHealthStatus.offline:
        return 'Sin conexión';
    }
  }

  Color get color {
    switch (this) {
      case StationHealthStatus.healthy:
        return const Color(0xFF4CAF50); // Green
      case StationHealthStatus.lowSoilHumidity:
        return const Color(0xFF2196F3); // Blue
      case StationHealthStatus.highTemperature:
        return const Color(0xFFFF5722); // Deep Orange
      case StationHealthStatus.lowTemperature:
        return const Color(0xFF03A9F4); // Light Blue
      case StationHealthStatus.warning:
        return const Color(0xFFFFC107); // Amber
      case StationHealthStatus.offline:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData get icon {
    switch (this) {
      case StationHealthStatus.healthy:
        return Icons.check_circle;
      case StationHealthStatus.lowSoilHumidity:
        return Icons.water_drop;
      case StationHealthStatus.highTemperature:
        return Icons.thermostat;
      case StationHealthStatus.lowTemperature:
        return Icons.ac_unit;
      case StationHealthStatus.warning:
        return Icons.warning;
      case StationHealthStatus.offline:
        return Icons.wifi_off;
    }
  }
}
