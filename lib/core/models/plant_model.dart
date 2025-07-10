import 'package:flutter/material.dart';

/// Plant Model
/// 
/// Represents a plant in the AuPlant IoT system with all its properties,
/// sensor data, and status information.
class PlantModel {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final double currentHumidity;
  final double currentLight;
  final double? currentTemperature;
  final double? currentSoilMoisture;
  final bool isOnline;
  final bool isAutoMode;
  final DateTime lastWatered;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PlantThresholds thresholds;
  final List<String> imageUrls;
  final String? deviceId;
  final String? location;
  final String? accessToken;

  const PlantModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.currentHumidity,
    required this.currentLight,
    this.currentTemperature,
    this.currentSoilMoisture,
    required this.isOnline,
    required this.isAutoMode,
    required this.lastWatered,
    required this.createdAt,
    required this.updatedAt,
    required this.thresholds,
    this.imageUrls = const [],
    this.deviceId,
    this.location,
    this.accessToken,
  });

  /// Creates a copy of this plant with the given fields replaced
  PlantModel copyWith({
    String? id,
    String? name,
    String? emoji,
    String? description,
    double? currentHumidity,
    double? currentLight,
    double? currentTemperature,
    double? currentSoilMoisture,
    bool? isOnline,
    bool? isAutoMode,
    DateTime? lastWatered,
    DateTime? createdAt,
    DateTime? updatedAt,
    PlantThresholds? thresholds,
    List<String>? imageUrls,
    String? deviceId,
    String? location,
    String? accessToken,
  }) {
    return PlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      currentHumidity: currentHumidity ?? this.currentHumidity,
      currentLight: currentLight ?? this.currentLight,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      currentSoilMoisture: currentSoilMoisture ?? this.currentSoilMoisture,
      isOnline: isOnline ?? this.isOnline,
      isAutoMode: isAutoMode ?? this.isAutoMode,
      lastWatered: lastWatered ?? this.lastWatered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thresholds: thresholds ?? this.thresholds,
      imageUrls: imageUrls ?? this.imageUrls,
      deviceId: deviceId ?? this.deviceId,
      location: location ?? this.location,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  /// Creates a PlantModel from a JSON map
  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      currentHumidity: (json['currentHumidity'] as num).toDouble(),
      currentLight: (json['currentLight'] as num).toDouble(),
      currentTemperature: json['currentTemperature'] != null
          ? (json['currentTemperature'] as num).toDouble()
          : null,
      currentSoilMoisture: json['currentSoilMoisture'] != null
          ? (json['currentSoilMoisture'] as num).toDouble()
          : null,
      isOnline: json['isOnline'] as bool,
      isAutoMode: json['isAutoMode'] as bool,
      lastWatered: DateTime.parse(json['lastWatered'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      thresholds: PlantThresholds.fromJson(json['thresholds'] as Map<String, dynamic>),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      deviceId: json['deviceId'] as String?,
      location: json['location'] as String?,
      accessToken: json['access_token'] as String?,
    );
  }

  /// Creates a PlantModel from Supabase data
  factory PlantModel.fromSupabase(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] as String,
      name: json['nombre'] as String,
      emoji: json['emoji'] as String? ?? '🌱',
      description: json['descripcion'] as String? ?? '',
      currentHumidity: 0.0, // Will be updated from sensor data
      currentLight: 0.0, // Will be updated from sensor data
      currentTemperature: null,
      currentSoilMoisture: null,
      isOnline: true, // Default to online, will be updated based on sensor data
      isAutoMode: false,
      lastWatered: DateTime.now().subtract(const Duration(hours: 24)), // Default
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      thresholds: PlantThresholds(
        minHumidity: (json['humidity_threshold_min'] as num?)?.toDouble() ?? 30.0,
        maxHumidity: (json['humidity_threshold_max'] as num?)?.toDouble() ?? 70.0,
        minLight: (json['light_threshold_min'] as num?)?.toDouble() ?? 200.0,
        maxLight: (json['light_threshold_max'] as num?)?.toDouble() ?? 800.0,
      ),
      imageUrls: const [],
      deviceId: json['device_id'] as String?,
      location: json['ubicacion'] as String?,
      accessToken: json['access_token'] as String?,
    );
  }

  /// Converts this PlantModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'description': description,
      'currentHumidity': currentHumidity,
      'currentLight': currentLight,
      'currentTemperature': currentTemperature,
      'currentSoilMoisture': currentSoilMoisture,
      'isOnline': isOnline,
      'isAutoMode': isAutoMode,
      'lastWatered': lastWatered.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'thresholds': thresholds.toJson(),
      'imageUrls': imageUrls,
      'deviceId': deviceId,
      'location': location,
      'accessToken': accessToken,
    };
  }

  /// Gets the formatted time since last watered
  String get formattedLastWatered {
    final now = DateTime.now();
    final difference = now.difference(lastWatered);

    if (difference.inDays > 0) {
      return 'Regada hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Regada hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Regada hace ${difference.inMinutes}min';
    } else {
      return 'Regada hace un momento';
    }
  }

  /// Gets the plant health status based on thresholds
  PlantHealthStatus get healthStatus {
    if (!isOnline) return PlantHealthStatus.offline;

    final humidityInRange = currentHumidity >= thresholds.minHumidity &&
        currentHumidity <= thresholds.maxHumidity;
    final lightInRange = currentLight >= thresholds.minLight &&
        currentLight <= thresholds.maxLight;

    if (humidityInRange && lightInRange) {
      return PlantHealthStatus.healthy;
    } else if (!humidityInRange && currentHumidity < thresholds.minHumidity) {
      return PlantHealthStatus.needsWater;
    } else if (!lightInRange && currentLight < thresholds.minLight) {
      return PlantHealthStatus.needsLight;
    } else {
      return PlantHealthStatus.warning;
    }
  }

  @override
  String toString() {
    return 'PlantModel(id: $id, name: $name, isOnline: $isOnline, healthStatus: $healthStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlantModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Plant Thresholds Configuration
/// 
/// Defines the optimal ranges for plant sensors to determine
/// when automatic actions should be triggered.
class PlantThresholds {
  final double minHumidity;
  final double maxHumidity;
  final double minLight;
  final double maxLight;
  final double? minTemperature;
  final double? maxTemperature;
  final double? minSoilMoisture;
  final double? maxSoilMoisture;

  const PlantThresholds({
    required this.minHumidity,
    required this.maxHumidity,
    required this.minLight,
    required this.maxLight,
    this.minTemperature,
    this.maxTemperature,
    this.minSoilMoisture,
    this.maxSoilMoisture,
  });

  /// Creates a copy of this thresholds with the given fields replaced
  PlantThresholds copyWith({
    double? minHumidity,
    double? maxHumidity,
    double? minLight,
    double? maxLight,
    double? minTemperature,
    double? maxTemperature,
    double? minSoilMoisture,
    double? maxSoilMoisture,
  }) {
    return PlantThresholds(
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
      minLight: minLight ?? this.minLight,
      maxLight: maxLight ?? this.maxLight,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      minSoilMoisture: minSoilMoisture ?? this.minSoilMoisture,
      maxSoilMoisture: maxSoilMoisture ?? this.maxSoilMoisture,
    );
  }

  /// Creates PlantThresholds from a JSON map
  factory PlantThresholds.fromJson(Map<String, dynamic> json) {
    return PlantThresholds(
      minHumidity: (json['minHumidity'] as num).toDouble(),
      maxHumidity: (json['maxHumidity'] as num).toDouble(),
      minLight: (json['minLight'] as num).toDouble(),
      maxLight: (json['maxLight'] as num).toDouble(),
      minTemperature: json['minTemperature'] != null
          ? (json['minTemperature'] as num).toDouble()
          : null,
      maxTemperature: json['maxTemperature'] != null
          ? (json['maxTemperature'] as num).toDouble()
          : null,
      minSoilMoisture: json['minSoilMoisture'] != null
          ? (json['minSoilMoisture'] as num).toDouble()
          : null,
      maxSoilMoisture: json['maxSoilMoisture'] != null
          ? (json['maxSoilMoisture'] as num).toDouble()
          : null,
    );
  }

  /// Converts this PlantThresholds to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
      'minLight': minLight,
      'maxLight': maxLight,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minSoilMoisture': minSoilMoisture,
      'maxSoilMoisture': maxSoilMoisture,
    };
  }

  /// Default thresholds for common plants
  static const PlantThresholds defaultThresholds = PlantThresholds(
    minHumidity: 40.0,
    maxHumidity: 80.0,
    minLight: 200.0,
    maxLight: 1000.0,
    minTemperature: 15.0,
    maxTemperature: 30.0,
    minSoilMoisture: 30.0,
    maxSoilMoisture: 70.0,
  );
}

/// Plant Health Status Enumeration
/// 
/// Represents the current health status of a plant based on
/// sensor readings and thresholds.
enum PlantHealthStatus {
  healthy,
  needsWater,
  needsLight,
  warning,
  offline,
}

/// Extension methods for PlantHealthStatus
extension PlantHealthStatusExtension on PlantHealthStatus {
  /// Gets the display name for the health status
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

  /// Gets the color associated with the health status
  Color get color {
    switch (this) {
      case PlantHealthStatus.healthy:
        return const Color(0xFF4CAF50);
      case PlantHealthStatus.needsWater:
        return const Color(0xFF2196F3);
      case PlantHealthStatus.needsLight:
        return const Color(0xFFFF9800);
      case PlantHealthStatus.warning:
        return const Color(0xFFFF5722);
      case PlantHealthStatus.offline:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Gets the icon associated with the health status
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
        return Icons.cloud_off;
    }
  }
}
