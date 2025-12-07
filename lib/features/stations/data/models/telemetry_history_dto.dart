import '../../domain/entities/telemetry_history.dart';

/// DTO for telemetry history data from ThingsBoard
class TelemetryHistoryDto {
  final String deviceId;
  final Map<String, List<TelemetryPointDto>> data;

  const TelemetryHistoryDto({
    required this.deviceId,
    required this.data,
  });

  /// Parse ThingsBoard timeseries response with startTs/endTs
  /// 
  /// Response format:
  /// ```json
  /// {
  ///   "hum": [{"ts": 1765130174760, "value": "50"}, ...],
  ///   "soil": [{"ts": 1765130174760, "value": "52"}, ...],
  ///   "temp": [{"ts": 1765130174760, "value": "26"}, ...]
  /// }
  /// ```
  factory TelemetryHistoryDto.fromThingsBoardResponse(
    String deviceId,
    Map<String, dynamic> json,
  ) {
    final data = <String, List<TelemetryPointDto>>{};
    
    for (final key in json.keys) {
      final points = json[key] as List<dynamic>?;
      if (points != null) {
        data[key] = points
            .map((p) => TelemetryPointDto.fromJson(p as Map<String, dynamic>))
            .toList();
      }
    }
    
    return TelemetryHistoryDto(deviceId: deviceId, data: data);
  }

  /// Convert to domain entity
  SensorHistoryData toEntity({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return SensorHistoryData(
      deviceId: deviceId,
      soilHumidity: _extractHistory('soil'),
      ambientHumidity: _extractHistory('hum'),
      temperature: _extractHistory('temp'),
      startTime: startTime,
      endTime: endTime,
    );
  }

  TelemetryHistory? _extractHistory(String key) {
    final points = data[key];
    if (points == null || points.isEmpty) return null;
    
    return TelemetryHistory(
      deviceId: deviceId,
      key: key,
      points: points.map((p) => p.toEntity()).toList(),
    );
  }
}

/// DTO for a single telemetry point
class TelemetryPointDto {
  final int ts;
  final String value;

  const TelemetryPointDto({
    required this.ts,
    required this.value,
  });

  factory TelemetryPointDto.fromJson(Map<String, dynamic> json) {
    return TelemetryPointDto(
      ts: json['ts'] as int,
      value: json['value'].toString(),
    );
  }

  TelemetryPoint toEntity() {
    return TelemetryPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(ts),
      value: double.tryParse(value) ?? 0.0,
    );
  }
}
