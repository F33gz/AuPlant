import '../../../../core/network/thingsboard_api_client.dart';
import '../../../../core/errors/exceptions.dart' as core_exceptions;
import '../models/sensor_data_dto.dart';
import '../models/telemetry_history_dto.dart';

/// ThingsBoard telemetry key names
class TelemetryKeys {
  static const String soilHumidity = 'soil';
  static const String ambientHumidity = 'hum';
  static const String temperature = 'temp';
  
  static String get allKeys => '$soilHumidity,$ambientHumidity,$temperature';
  static List<String> get allKeysList => [soilHumidity, ambientHumidity, temperature];
}

/// Remote data source for sensor operations using ThingsBoard
abstract class SensorRemoteDataSource {
  Future<List<SensorDataDto>> getAllSensorData();
  Future<SensorDataDto> getSensorData(String stationId);
  
  /// Get historical telemetry data for a device
  /// 
  /// [deviceId] - ThingsBoard device ID
  /// [startTs] - Start timestamp in milliseconds (Unix epoch)
  /// [endTs] - End timestamp in milliseconds (Unix epoch)
  /// [keys] - Optional list of telemetry keys (defaults to all: soil, hum, temp)
  Future<TelemetryHistoryDto> getSensorHistory({
    required String deviceId,
    required int startTs,
    required int endTs,
    List<String>? keys,
  });
}

/// Implementation of SensorRemoteDataSource using ThingsBoard API
class SensorRemoteDataSourceImpl implements SensorRemoteDataSource {
  final ThingsBoardApiClient apiClient;

  SensorRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SensorDataDto>> getAllSensorData() async {
    try {
      // This would require fetching all devices first, then their telemetry
      // For now, return empty list - telemetry should be fetched per device
      return [];
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching sensor data: $e');
    }
  }

  @override
  Future<SensorDataDto> getSensorData(String stationId) async {
    try {
      // Endpoint: GET /api/plugins/telemetry/DEVICE/{deviceId}/values/timeseries?keys=hum,soil,temp
      // When no startTs/endTs is provided, ThingsBoard returns only the latest value
      final response = await apiClient.get(
        '/plugins/telemetry/DEVICE/$stationId/values/timeseries?keys=${TelemetryKeys.allKeys}',
      );
      
      return SensorDataDto.fromThingsBoardTelemetry(stationId, response);
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching sensor data for station $stationId: $e');
    }
  }

  @override
  Future<TelemetryHistoryDto> getSensorHistory({
    required String deviceId,
    required int startTs,
    required int endTs,
    List<String>? keys,
  }) async {
    try {
      // Endpoint: GET /api/plugins/telemetry/DEVICE/{deviceId}/values/timeseries?keys={keys}&startTs={startTs}&endTs={endTs}
      final keysParam = (keys ?? TelemetryKeys.allKeysList).join(',');
      final response = await apiClient.get(
        '/plugins/telemetry/DEVICE/$deviceId/values/timeseries?keys=$keysParam&startTs=$startTs&endTs=$endTs',
      );
      
      return TelemetryHistoryDto.fromThingsBoardResponse(deviceId, response);
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching sensor history: $e');
    }
  }
}

