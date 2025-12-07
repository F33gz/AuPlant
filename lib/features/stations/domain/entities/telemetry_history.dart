/// Represents a single telemetry data point
class TelemetryPoint {
  final DateTime timestamp;
  final double value;

  const TelemetryPoint({
    required this.timestamp,
    required this.value,
  });

  @override
  String toString() => 'TelemetryPoint(ts: $timestamp, value: $value)';
}

/// Represents historical telemetry data for a sensor type
class TelemetryHistory {
  final String deviceId;
  final String key;
  final List<TelemetryPoint> points;

  const TelemetryHistory({
    required this.deviceId,
    required this.key,
    required this.points,
  });

  /// Get the minimum value in the history
  double? get minValue {
    if (points.isEmpty) return null;
    return points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
  }

  /// Get the maximum value in the history
  double? get maxValue {
    if (points.isEmpty) return null;
    return points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
  }

  /// Get the average value in the history
  double? get averageValue {
    if (points.isEmpty) return null;
    return points.map((p) => p.value).reduce((a, b) => a + b) / points.length;
  }

  /// Get the latest value
  double? get latestValue {
    if (points.isEmpty) return null;
    return points.first.value; // ThingsBoard returns newest first
  }

  /// Get just the values as a list (for charts)
  List<double> get values => points.map((p) => p.value).toList();

  /// Get values reversed (oldest first, for charts)
  List<double> get valuesOldestFirst => points.reversed.map((p) => p.value).toList();

  @override
  String toString() => 'TelemetryHistory(deviceId: $deviceId, key: $key, points: ${points.length})';
}

/// Combined historical data for all sensor types
class SensorHistoryData {
  final String deviceId;
  final TelemetryHistory? soilHumidity;
  final TelemetryHistory? ambientHumidity;
  final TelemetryHistory? temperature;
  final DateTime startTime;
  final DateTime endTime;

  const SensorHistoryData({
    required this.deviceId,
    this.soilHumidity,
    this.ambientHumidity,
    this.temperature,
    required this.startTime,
    required this.endTime,
  });

  /// Check if there's any data
  bool get hasData => 
      (soilHumidity?.points.isNotEmpty ?? false) ||
      (ambientHumidity?.points.isNotEmpty ?? false) ||
      (temperature?.points.isNotEmpty ?? false);

  @override
  String toString() => 'SensorHistoryData(deviceId: $deviceId, '
      'soil: ${soilHumidity?.points.length ?? 0}, '
      'ambient: ${ambientHumidity?.points.length ?? 0}, '
      'temp: ${temperature?.points.length ?? 0})';
}

/// Time range options for historical data
enum HistoryTimeRange {
  lastHour,
  last6Hours,
  last24Hours,
}

extension HistoryTimeRangeExtension on HistoryTimeRange {
  Duration get duration {
    switch (this) {
      case HistoryTimeRange.lastHour:
        return const Duration(hours: 1);
      case HistoryTimeRange.last6Hours:
        return const Duration(hours: 6);
      case HistoryTimeRange.last24Hours:
        return const Duration(hours: 24);
    }
  }

  String get label {
    switch (this) {
      case HistoryTimeRange.lastHour:
        return '1h';
      case HistoryTimeRange.last6Hours:
        return '6h';
      case HistoryTimeRange.last24Hours:
        return '24h';
    }
  }

  String get displayName {
    switch (this) {
      case HistoryTimeRange.lastHour:
        return 'Última hora';
      case HistoryTimeRange.last6Hours:
        return 'Últimas 6 horas';
      case HistoryTimeRange.last24Hours:
        return 'Últimas 24 horas';
    }
  }
}
