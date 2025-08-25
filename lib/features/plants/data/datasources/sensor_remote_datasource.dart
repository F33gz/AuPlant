import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart' as core_exceptions;
import '../models/sensor_data_dto.dart';

/// Remote data source for sensor operations
abstract class SensorRemoteDataSource {
  Future<List<SensorDataDto>> getAllSensorData();
  Future<SensorDataDto> getSensorData(String plantId);
  Future<void> sendWateringCommand({
    required String accessToken,
    required Map<String, dynamic> attributes,
  });
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

      final List<dynamic> plantasData = response.data['plantas'] ?? [];
      
      return plantasData.map<SensorDataDto>((json) {
        return SensorDataDto.fromJson(json);
      }).toList();
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching sensor data: $e');
    }
  }

  @override
  Future<SensorDataDto> getSensorData(String plantId) async {
    try {
      final allSensorData = await getAllSensorData();
      final sensorData = allSensorData.firstWhere(
        (data) => data.plantId == plantId,
        orElse: () => throw core_exceptions.PlantException('Sensor data not found for plant $plantId'),
      );
      return sensorData;
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching sensor data for plant $plantId: $e');
    }
  }

  @override
  Future<void> sendWateringCommand({
    required String accessToken,
    required Map<String, dynamic> attributes,
  }) async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        throw core_exceptions.AuthException('User not authenticated');
      }

      final response = await supabaseClient.functions.invoke(
        'regado',
        body: {
          'accessToken': accessToken,
          'atributos': attributes,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.data == null || response.data['success'] != true) {
        throw core_exceptions.ServerException('Error sending watering command: ${response.data?['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw core_exceptions.ServerException('Error sending watering command: $e');
    }
  }
}
