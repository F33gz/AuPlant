import '../../../../core/network/thingsboard_api_client.dart';
import '../../../../core/errors/exceptions.dart' as core_exceptions;
import '../models/sensor_data_dto.dart';

/// ThingsBoard telemetry key names
class TelemetryKeys {
  static const String soilHumidity = 'soil';
  static const String ambientHumidity = 'hum';
  static const String temperature = 'temp';
  
  static String get allKeys => '$soilHumidity,$ambientHumidity,$temperature';
}

/// Remote data source for sensor operations using ThingsBoard
abstract class SensorRemoteDataSource {
  Future<List<SensorDataDto>> getAllSensorData();
  Future<SensorDataDto> getSensorData(String stationId);
  Future<Map<String, List<Map<String, dynamic>>>> getSensorHistory({
    required String deviceId,
    required List<String> keys,
    required int startTs,
    required int endTs,
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
  Future<Map<String, List<Map<String, dynamic>>>> getSensorHistory({
    required String deviceId,
    required List<String> keys,
    required int startTs,
    required int endTs,
  }) async {
    try {
      // Endpoint: GET /api/plugins/telemetry/DEVICE/{deviceId}/values/timeseries?keys={keys}&startTs={startTs}&endTs={endTs}
      final keysParam = keys.join(',');
      final response = await apiClient.get(
        '/plugins/telemetry/DEVICE/$deviceId/values/timeseries?keys=$keysParam&startTs=$startTs&endTs=$endTs',
      );
      
      // Parse response into expected format
      final result = <String, List<Map<String, dynamic>>>{};
      for (final key in keys) {
        if (response[key] != null) {
          result[key] = (response[key] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      }
      return result;
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching sensor history: $e');
    }
  }
}

