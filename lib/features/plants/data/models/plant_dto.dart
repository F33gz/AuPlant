import '../../domain/entities/plant.dart';

/// Data Transfer Object for Plant
class PlantDto {
  final String id;
  final String nombre;
  final String emoji;
  final String? descripcion;
  final String? ubicacion;
  final String? deviceId;
  final double? humidityThresholdMin;
  final double? humidityThresholdMax;
  final double? lightThresholdMin;
  final double? lightThresholdMax;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlantDto({
    required this.id,
    required this.nombre,
    required this.emoji,
    this.descripcion,
    this.ubicacion,
    this.deviceId,
    this.humidityThresholdMin,
    this.humidityThresholdMax,
    this.lightThresholdMin,
    this.lightThresholdMax,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlantDto.fromJson(Map<String, dynamic> json) {
    double? _asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    double? _readDouble(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) {
          final v = _asDouble(json[k]);
          if (v != null) return v;
        }
      }
      return null;
    }

    return PlantDto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      emoji: json['emoji'] as String? ?? '🌱',
      descripcion: json['descripcion'] as String?,
      ubicacion: json['ubicacion'] as String?,
      deviceId: json['device_id'] as String?,
      // Prefer Supabase column names; fallback to old keys if any
      humidityThresholdMin: _readDouble(['min_humedad', 'humidity_threshold_min']),
      humidityThresholdMax: _readDouble(['max_humedad', 'humidity_threshold_max']),
      lightThresholdMin: _readDouble(['min_luz', 'light_threshold_min']),
      lightThresholdMax: _readDouble(['max_luz', 'light_threshold_max']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'emoji': emoji,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'device_id': deviceId,
  // Use DB column names when persisting
  'min_humedad': humidityThresholdMin,
  'max_humedad': humidityThresholdMax,
  'min_luz': lightThresholdMin,
  'max_luz': lightThresholdMax,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert DTO to domain entity
  Plant toEntity() {
    return Plant(
      id: id,
      name: nombre,
      emoji: emoji,
      description: descripcion ?? '',
      location: ubicacion,
      deviceId: deviceId,
      thresholds: PlantThresholds(
        minHumidity: humidityThresholdMin ?? 30.0,
        maxHumidity: humidityThresholdMax ?? 70.0,
        minLight: lightThresholdMin ?? 200.0,
        maxLight: lightThresholdMax ?? 800.0,
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create DTO from domain entity
  static PlantDto fromEntity(Plant plant) {
    return PlantDto(
      id: plant.id,
      nombre: plant.name,
      emoji: plant.emoji,
      descripcion: plant.description,
      ubicacion: plant.location,
      deviceId: plant.deviceId,
      humidityThresholdMin: plant.thresholds.minHumidity,
      humidityThresholdMax: plant.thresholds.maxHumidity,
      lightThresholdMin: plant.thresholds.minLight,
      lightThresholdMax: plant.thresholds.maxLight,
      createdAt: plant.createdAt,
      updatedAt: plant.updatedAt,
    );
  }
}
