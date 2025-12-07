import '../../domain/entities/station.dart';

/// Data Transfer Object for Station
/// 
/// Maps between JSON from ThingsBoard API and the Station domain entity.
class StationDto {
  final String id;
  final String nombre;
  final String emoji;
  final String? descripcion;
  final String? ubicacion;
  final String? deviceId;
  final double? minSoilHumidity;
  final double? maxSoilHumidity;
  final double? minAmbientHumidity;
  final double? maxAmbientHumidity;
  final double? minTemperature;
  final double? maxTemperature;
  final DateTime createdAt;
  final DateTime updatedAt;
  // ThingsBoard specific fields
  final bool isActive;
  final String? customerTitle;
  final String? deviceProfileName;

  const StationDto({
    required this.id,
    required this.nombre,
    required this.emoji,
    this.descripcion,
    this.ubicacion,
    this.deviceId,
    this.minSoilHumidity,
    this.maxSoilHumidity,
    this.minAmbientHumidity,
    this.maxAmbientHumidity,
    this.minTemperature,
    this.maxTemperature,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = false,
    this.customerTitle,
    this.deviceProfileName,
  });

  factory StationDto.fromJson(Map<String, dynamic> json) {
    double? asDoubleLocal(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    double? readDoubleLocal(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) {
          final v = asDoubleLocal(json[k]);
          if (v != null) return v;
        }
      }
      return null;
    }

    return StationDto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      emoji: json['emoji'] as String? ?? '🌱',
      descripcion: json['descripcion'] as String?,
      ubicacion: json['ubicacion'] as String?,
      deviceId: json['device_id'] as String?,
      minSoilHumidity: readDoubleLocal(['min_humedad_suelo', 'min_humedad']),
      maxSoilHumidity: readDoubleLocal(['max_humedad_suelo', 'max_humedad']),
      minAmbientHumidity: readDoubleLocal(['min_humedad_ambiente']),
      maxAmbientHumidity: readDoubleLocal(['max_humedad_ambiente']),
      minTemperature: readDoubleLocal(['min_temperatura']),
      maxTemperature: readDoubleLocal(['max_temperatura']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Create DTO from ThingsBoard device response
  factory StationDto.fromThingsBoardJson(Map<String, dynamic> json) {
    final id = json['id'] as Map<String, dynamic>?;
    final deviceId = id?['id'] as String? ?? '';
    
    // ThingsBoard stores custom attributes separately
    // For now, use device name and type as basic info
    return StationDto(
      id: deviceId,
      nombre: json['name'] as String? ?? 'Sin nombre',
      emoji: '🌱', // Default emoji, can be stored in attributes
      descripcion: json['type'] as String?,
      ubicacion: json['label'] as String?,
      deviceId: deviceId,
      // Thresholds should be loaded from device attributes
      minSoilHumidity: null,
      maxSoilHumidity: null,
      minAmbientHumidity: null,
      maxAmbientHumidity: null,
      minTemperature: null,
      maxTemperature: null,
      createdAt: json['createdTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdTime'] as int)
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create DTO from ThingsBoard deviceInfos endpoint response
  /// Response format from /api/customer/{customerId}/deviceInfos
  factory StationDto.fromThingsBoardDeviceInfo(Map<String, dynamic> json) {
    final id = json['id'] as Map<String, dynamic>?;
    final deviceId = id?['id'] as String? ?? '';
    final additionalInfo = json['additionalInfo'] as Map<String, dynamic>?;
    final isGateway = additionalInfo?['gateway'] == true;
    
    return StationDto(
      id: deviceId,
      nombre: json['name'] as String? ?? 'Sin nombre',
      // Use different emoji for gateways
      emoji: isGateway ? '📡' : '🌱',
      descripcion: json['type'] as String?,
      ubicacion: json['label'] as String?,
      deviceId: deviceId,
      // These can be loaded from device attributes later
      minSoilHumidity: null,
      maxSoilHumidity: null,
      minAmbientHumidity: null,
      maxAmbientHumidity: null,
      minTemperature: null,
      maxTemperature: null,
      createdAt: json['createdTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdTime'] as int)
          : DateTime.now(),
      updatedAt: DateTime.now(),
      // Additional ThingsBoard specific fields
      isActive: json['active'] as bool? ?? false,
      customerTitle: json['customerTitle'] as String?,
      deviceProfileName: json['deviceProfileName'] as String?,
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
      // TODO: Update column names when DB schema changes
      'min_humedad_suelo': minSoilHumidity,
      'max_humedad_suelo': maxSoilHumidity,
      'min_humedad_ambiente': minAmbientHumidity,
      'max_humedad_ambiente': maxAmbientHumidity,
      'min_temperatura': minTemperature,
      'max_temperatura': maxTemperature,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert DTO to domain entity
  Station toEntity() {
    final defaults = StationThresholds.defaults();
    return Station(
      id: id,
      name: nombre,
      emoji: emoji,
      description: descripcion ?? '',
      location: ubicacion,
      deviceId: deviceId,
      thresholds: StationThresholds(
        minSoilHumidity: minSoilHumidity ?? defaults.minSoilHumidity,
        maxSoilHumidity: maxSoilHumidity ?? defaults.maxSoilHumidity,
        minAmbientHumidity: minAmbientHumidity ?? defaults.minAmbientHumidity,
        maxAmbientHumidity: maxAmbientHumidity ?? defaults.maxAmbientHumidity,
        minTemperature: minTemperature ?? defaults.minTemperature,
        maxTemperature: maxTemperature ?? defaults.maxTemperature,
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create DTO from domain entity
  static StationDto fromEntity(Station station) {
    return StationDto(
      id: station.id,
      nombre: station.name,
      emoji: station.emoji,
      descripcion: station.description,
      ubicacion: station.location,
      deviceId: station.deviceId,
      minSoilHumidity: station.thresholds.minSoilHumidity,
      maxSoilHumidity: station.thresholds.maxSoilHumidity,
      minAmbientHumidity: station.thresholds.minAmbientHumidity,
      maxAmbientHumidity: station.thresholds.maxAmbientHumidity,
      minTemperature: station.thresholds.minTemperature,
      maxTemperature: station.thresholds.maxTemperature,
      createdAt: station.createdAt,
      updatedAt: station.updatedAt,
    );
  }
}
