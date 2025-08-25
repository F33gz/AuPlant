import 'package:equatable/equatable.dart';

/// Plant entity representing the core business object
class Plant extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String? location;
  final String? deviceId;
  final String? accessToken;
  final PlantThresholds thresholds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Plant({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    this.location,
    this.deviceId,
    this.accessToken,
    required this.thresholds,
    required this.createdAt,
    required this.updatedAt,
  });

  Plant copyWith({
    String? id,
    String? name,
    String? emoji,
    String? description,
    String? location,
    String? deviceId,
    String? accessToken,
    PlantThresholds? thresholds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      location: location ?? this.location,
      deviceId: deviceId ?? this.deviceId,
      accessToken: accessToken ?? this.accessToken,
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
        accessToken,
        thresholds,
        createdAt,
        updatedAt,
      ];
}

/// Plant thresholds for sensor values
class PlantThresholds extends Equatable {
  final double minHumidity;
  final double maxHumidity;
  final double minLight;
  final double maxLight;
  final double? minTemperature;
  final double? maxTemperature;

  const PlantThresholds({
    required this.minHumidity,
    required this.maxHumidity,
    required this.minLight,
    required this.maxLight,
    this.minTemperature,
    this.maxTemperature,
  });

  PlantThresholds copyWith({
    double? minHumidity,
    double? maxHumidity,
    double? minLight,
    double? maxLight,
    double? minTemperature,
    double? maxTemperature,
  }) {
    return PlantThresholds(
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
      minLight: minLight ?? this.minLight,
      maxLight: maxLight ?? this.maxLight,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
    );
  }

  @override
  List<Object?> get props => [
        minHumidity,
        maxHumidity,
        minLight,
        maxLight,
        minTemperature,
        maxTemperature,
      ];
}
