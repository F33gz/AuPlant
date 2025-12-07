import '../../../../core/network/thingsboard_api_client.dart';
import '../../../../core/errors/exceptions.dart' as core_exceptions;
import '../models/sensor_data_dto.dart';

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
      // TODO: Implementar obtención de telemetría de todos los dispositivos
      // Se necesita primero obtener la lista de dispositivos y luego sus datos
      // Por ahora retornamos lista vacía
      return [];
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching sensor data: $e');
    }
  }

  @override
  Future<SensorDataDto> getSensorData(String stationId) async {
    try {
      // TODO: Implementar obtención de telemetría del dispositivo desde ThingsBoard
      // Endpoint: GET /api/plugins/telemetry/DEVICE/{deviceId}/values/timeseries?keys=soilHumidity,ambientHumidity,temperature
      final response = await apiClient.get(
        '/plugins/telemetry/DEVICE/$stationId/values/timeseries?keys=soilHumidity,ambientHumidity,temperature',
      );
      
      return SensorDataDto.fromThingsBoardJson(stationId, response);
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
      // TODO: Implementar obtención de historial de telemetría desde ThingsBoard
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

