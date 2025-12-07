import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart' as core_exceptions;
import '../models/sensor_data_dto.dart';

/// Remote data source for sensor operations
abstract class SensorRemoteDataSource {
  Future<List<SensorDataDto>> getAllSensorData();
  Future<SensorDataDto> getSensorData(String stationId);
}

/// Implementation of SensorRemoteDataSource using Supabase
class SensorRemoteDataSourceImpl implements SensorRemoteDataSource {
  final SupabaseClient supabaseClient;

  SensorRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<SensorDataDto>> getAllSensorData() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        throw core_exceptions.AuthException('User not authenticated');
      }

      // TODO: Update edge function name when backend changes
      final response = await supabaseClient.functions.invoke(
        'get_plant_data',
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.data == null) {
        throw core_exceptions.ServerException('No data received from server');
      }

      // TODO: Update response key when backend changes (plantas -> estaciones)
      final List<dynamic> stationsData = response.data['plantas'] ?? [];
      
      return stationsData.map<SensorDataDto>((json) {
        return SensorDataDto.fromJson(json);
      }).toList();
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching sensor data: $e');
    }
  }

  @override
  Future<SensorDataDto> getSensorData(String stationId) async {
    try {
      final allSensorData = await getAllSensorData();
      final sensorData = allSensorData.firstWhere(
        (data) => data.stationId == stationId,
        orElse: () => throw core_exceptions.PlantException('Sensor data not found for station $stationId'),
      );
      return sensorData;
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching sensor data for station $stationId: $e');
    }
  }
}
