import 'package:equatable/equatable.dart';

/// Station entity representing a greenhouse monitoring station
/// 
/// A station is a physical monitoring point within a greenhouse that tracks
/// environmental conditions like soil humidity, ambient humidity, and temperature.
class Station extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String? location;
  final String? deviceId;
  final StationThresholds thresholds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Station({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    this.location,
    this.deviceId,
    required this.thresholds,
    required this.createdAt,
    required this.updatedAt,
  });

  Station copyWith({
    String? id,
    String? name,
    String? emoji,
    String? description,
    String? location,
    String? deviceId,
    StationThresholds? thresholds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      location: location ?? this.location,
      deviceId: deviceId ?? this.deviceId,
      thresholds: thresholds ?? this.thresholds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        emoji,
        description,
        location,
        deviceId,
        thresholds,
        createdAt,
        updatedAt,
      ];
}

/// Station thresholds for sensor values
/// 
/// Defines acceptable ranges for environmental monitoring:
/// - Soil humidity (humedad del suelo)
/// - Ambient humidity (humedad ambiente)
/// - Temperature (temperatura)
class StationThresholds extends Equatable {
  /// Minimum acceptable soil humidity percentage
  final double minSoilHumidity;
  /// Maximum acceptable soil humidity percentage
  final double maxSoilHumidity;
  /// Minimum acceptable ambient humidity percentage
  final double minAmbientHumidity;
  /// Maximum acceptable ambient humidity percentage
  final double maxAmbientHumidity;
  /// Minimum acceptable temperature in Celsius
  final double minTemperature;
  /// Maximum acceptable temperature in Celsius
  final double maxTemperature;

  const StationThresholds({
    required this.minSoilHumidity,
    required this.maxSoilHumidity,
    required this.minAmbientHumidity,
    required this.maxAmbientHumidity,
    required this.minTemperature,
    required this.maxTemperature,
  });

  /// Default thresholds for a typical greenhouse station
  factory StationThresholds.defaults() {
    return const StationThresholds(
      minSoilHumidity: 30.0,
      maxSoilHumidity: 70.0,
      minAmbientHumidity: 40.0,
      maxAmbientHumidity: 80.0,
      minTemperature: 15.0,
      maxTemperature: 35.0,
    );
  }

  StationThresholds copyWith({
    double? minSoilHumidity,
    double? maxSoilHumidity,
    double? minAmbientHumidity,
    double? maxAmbientHumidity,
    double? minTemperature,
    double? maxTemperature,
  }) {
    return StationThresholds(
      minSoilHumidity: minSoilHumidity ?? this.minSoilHumidity,
      maxSoilHumidity: maxSoilHumidity ?? this.maxSoilHumidity,
      minAmbientHumidity: minAmbientHumidity ?? this.minAmbientHumidity,
      maxAmbientHumidity: maxAmbientHumidity ?? this.maxAmbientHumidity,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
    );
  }

  @override
  List<Object?> get props => [
        minSoilHumidity,
        maxSoilHumidity,
        minAmbientHumidity,
        maxAmbientHumidity,
        minTemperature,
        maxTemperature,
      ];
}
