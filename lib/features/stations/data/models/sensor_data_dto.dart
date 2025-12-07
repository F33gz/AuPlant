import '../../domain/entities/sensor_data.dart';

/// Data Transfer Object for Sensor Data
/// 
/// Maps between JSON from API and the SensorData domain entity.
class SensorDataDto {
  final String stationId;
  final String nombre;
  final String emoji;
  final String descripcion;
  final String ubicacion;
  final double? soilHumidity;
  final double? ambientHumidity;
  final double? temperature;
  final String? deviceId;
  final bool? online;
  final List<SensorDataPointDto> recentSoilHumidityReadings;
  final List<SensorDataPointDto> recentAmbientHumidityReadings;
  final List<SensorDataPointDto> recentTemperatureReadings;
  final SensorStatisticsDto? soilHumidityStatistics;
  final SensorStatisticsDto? ambientHumidityStatistics;
  final SensorStatisticsDto? temperatureStatistics;
  final String? error;

  const SensorDataDto({
    required this.stationId,
    required this.nombre,
    required this.emoji,
    required this.descripcion,
    required this.ubicacion,
    this.soilHumidity,
    this.ambientHumidity,
    this.temperature,
    this.deviceId,
    this.online,
    this.recentSoilHumidityReadings = const [],
    this.recentAmbientHumidityReadings = const [],
    this.recentTemperatureReadings = const [],
    this.soilHumidityStatistics,
    this.ambientHumidityStatistics,
    this.temperatureStatistics,
    this.error,
  });

  factory SensorDataDto.fromJson(Map<String, dynamic> json) {
    return SensorDataDto(
      stationId: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🌱',
      descripcion: json['descripcion']?.toString() ?? '',
      ubicacion: json['ubicacion']?.toString() ?? '',
      // TODO: Update field names when API changes
      soilHumidity: _parseDouble(json['humedad_suelo'] ?? json['humedad']),
      ambientHumidity: _parseDouble(json['humedad_ambiente']),
      temperature: _parseDouble(json['temperatura']),
      deviceId: json['device_id']?.toString(),
      online: _parseBool(json['online']),
      recentSoilHumidityReadings: _parseRecentReadings(json, 'recentReadings', 'soilHumidity'),
      recentAmbientHumidityReadings: _parseRecentReadings(json, 'recentReadings', 'ambientHumidity'),
      recentTemperatureReadings: _parseRecentReadings(json, 'recentReadings', 'temperature'),
      soilHumidityStatistics: _parseStatistics(json, 'statistics', 'soilHumidity'),
      ambientHumidityStatistics: _parseStatistics(json, 'statistics', 'ambientHumidity'),
      temperatureStatistics: _parseStatistics(json, 'statistics', 'temperature'),
      error: json['error']?.toString(),
    );
  }

  /// Convert DTO to domain entity
  SensorData toEntity() {
    return SensorData(
      stationId: stationId,
      soilHumidity: soilHumidity,
      ambientHumidity: ambientHumidity,
      temperature: temperature,
      isOnline: online ?? (soilHumidity != null && error == null),
      timestamp: DateTime.now(),
      recentSoilHumidityReadings: recentSoilHumidityReadings.map((dto) => dto.toEntity()).toList(),
      recentAmbientHumidityReadings: recentAmbientHumidityReadings.map((dto) => dto.toEntity()).toList(),
      recentTemperatureReadings: recentTemperatureReadings.map((dto) => dto.toEntity()).toList(),
      soilHumidityStatistics: soilHumidityStatistics?.toEntity(),
      ambientHumidityStatistics: ambientHumidityStatistics?.toEntity(),
      temperatureStatistics: temperatureStatistics?.toEntity(),
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v == 'true') return true;
      if (v == 'false') return false;
    }
    if (value is num) return value != 0;
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<SensorDataPointDto> _parseRecentReadings(Map<String, dynamic> json, String readingsKey, String sensorType) {
    try {
      final readings = json[readingsKey] as Map<String, dynamic>?;
      if (readings == null) return [];
      
      final sensorReadings = readings[sensorType] as List<dynamic>?;
      if (sensorReadings == null) return [];
      
      return sensorReadings.map<SensorDataPointDto>((item) {
        if (item is Map<String, dynamic>) {
          return SensorDataPointDto(
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              (item['timestamp'] as num?)?.toInt() ?? 0
            ),
            value: _parseDouble(item['value']) ?? 0.0,
          );
        }
        return SensorDataPointDto(timestamp: DateTime.now(), value: 0.0);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static SensorStatisticsDto? _parseStatistics(Map<String, dynamic> json, String statisticsKey, String sensorType) {
    try {
      final statistics = json[statisticsKey] as Map<String, dynamic>?;
      if (statistics == null) return null;
      
      final sensorStats = statistics[sensorType] as Map<String, dynamic>?;
      if (sensorStats == null) return null;
      
      return SensorStatisticsDto.fromJson(sensorStats);
    } catch (e) {
      return null;
    }
  }
}

/// DTO for individual sensor data points
class SensorDataPointDto {
  final DateTime timestamp;
  final double value;

  const SensorDataPointDto({
    required this.timestamp,
    required this.value,
  });

  SensorDataPoint toEntity() {
    return SensorDataPoint(
      timestamp: timestamp,
      value: value,
    );
  }
}

/// DTO for sensor statistics
class SensorStatisticsDto {
  final double? min;
  final double? max;
  final double? avg;
  final int count;

  const SensorStatisticsDto({
    this.min,
    this.max,
    this.avg,
    this.count = 0,
  });

  factory SensorStatisticsDto.fromJson(Map<String, dynamic> json) {
    return SensorStatisticsDto(
      min: _parseDouble(json['min']),
      max: _parseDouble(json['max']),
      avg: _parseDouble(json['avg']),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  SensorStatistics toEntity() {
    return SensorStatistics(
      min: min,
      max: max,
      avg: avg,
      count: count,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
