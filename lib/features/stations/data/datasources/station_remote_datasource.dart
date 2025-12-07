import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart' as core_exceptions;
import '../models/station_dto.dart';

/// Remote data source for station operations
abstract class StationRemoteDataSource {
  Future<List<StationDto>> getUserStations();
  Future<StationDto> getStationById(String stationId);
  Future<StationDto> addStation({
    required String name,
    required String deviceId,
    String? emoji,
    String? description,
    String? location,
  });
  Future<StationDto> updateStation({
    required String stationId,
    String? name,
    String? emoji,
    String? description,
    String? deviceId,
    String? location,
    double? minSoilHumidity,
    double? maxSoilHumidity,
    double? minAmbientHumidity,
    double? maxAmbientHumidity,
    double? minTemperature,
    double? maxTemperature,
  });
  Future<void> deleteStation(String stationId);
  Stream<List<StationDto>> watchUserStations();
}

/// Implementation of StationRemoteDataSource using Supabase
class StationRemoteDataSourceImpl implements StationRemoteDataSource {
  final SupabaseClient supabaseClient;

  StationRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<StationDto>> getUserStations() async {
    try {
      // TODO: Update table name when DB schema changes (plantas -> estaciones)
      final response = await supabaseClient
          .from('plantas')
          .select('*')
          .order('created_at', ascending: false);

      return response.map<StationDto>((json) => StationDto.fromJson(json)).toList();
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching stations: $e');
    }
  }

  @override
  Future<StationDto> getStationById(String stationId) async {
    try {
      // TODO: Update table name when DB schema changes
      final response = await supabaseClient
          .from('plantas')
          .select('*')
          .eq('id', stationId)
          .single();

      return StationDto.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching station: $e');
    }
  }

  @override
  Future<StationDto> addStation({
    required String name,
    required String deviceId,
    String? emoji,
    String? description,
    String? location,
  }) async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        throw core_exceptions.AuthException('User not authenticated');
      }

      // TODO: Update table name and column names when DB schema changes
      final response = await supabaseClient
          .from('plantas')
          .insert({
            'nombre': name,
            'emoji': emoji ?? '🌱',
            'descripcion': description,
            'device_id': deviceId,
            'ubicacion': location,
            'user_id': session.user.id,
          })
          .select()
          .single();

      return StationDto.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException('Error adding station: $e');
    }
  }

  @override
  Future<StationDto> updateStation({
    required String stationId,
    String? name,
    String? emoji,
    String? description,
    String? deviceId,
    String? location,
    double? minSoilHumidity,
    double? maxSoilHumidity,
    double? minAmbientHumidity,
    double? maxAmbientHumidity,
    double? minTemperature,
    double? maxTemperature,
  }) async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        throw core_exceptions.AuthException('User not authenticated');
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['nombre'] = name;
      if (emoji != null) updateData['emoji'] = emoji;
      if (description != null) updateData['descripcion'] = description;
      if (deviceId != null) updateData['device_id'] = deviceId;
      if (location != null) updateData['ubicacion'] = location;
      // TODO: Update column names when DB schema changes
      if (minSoilHumidity != null) updateData['min_humedad_suelo'] = minSoilHumidity;
      if (maxSoilHumidity != null) updateData['max_humedad_suelo'] = maxSoilHumidity;
      if (minAmbientHumidity != null) updateData['min_humedad_ambiente'] = minAmbientHumidity;
      if (maxAmbientHumidity != null) updateData['max_humedad_ambiente'] = maxAmbientHumidity;
      if (minTemperature != null) updateData['min_temperatura'] = minTemperature;
      if (maxTemperature != null) updateData['max_temperatura'] = maxTemperature;

      // TODO: Update edge function name when backend changes
      final response = await supabaseClient.functions.invoke(
        'modify_plant',
        body: {
          'action': 'update',
          'plantId': stationId,
          'updateData': updateData,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.data == null || response.data['success'] != true) {
        throw core_exceptions.ServerException('Error updating station: ${response.data?['error'] ?? 'Unknown error'}');
      }

      // Refresh the model from the database
      // TODO: Update table name when DB schema changes
      final refreshed = await supabaseClient
          .from('plantas')
          .select()
          .eq('id', stationId)
          .single();

      return StationDto.fromJson(refreshed);
    } catch (e) {
      throw core_exceptions.ServerException('Error updating station: $e');
    }
  }

  @override
  Future<void> deleteStation(String stationId) async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        throw core_exceptions.AuthException('User not authenticated');
      }

      // TODO: Update edge function name when backend changes
      final response = await supabaseClient.functions.invoke(
        'modify_plant',
        body: {
          'action': 'delete',
          'plantId': stationId,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.data == null || response.data['success'] != true) {
        throw core_exceptions.ServerException('Error deleting station: ${response.data?['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw core_exceptions.ServerException('Error deleting station: $e');
    }
  }

  @override
  Stream<List<StationDto>> watchUserStations() {
    try {
      // TODO: Update table name when DB schema changes
      return supabaseClient
          .from('plantas')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((data) => data.map<StationDto>((json) => StationDto.fromJson(json)).toList());
    } catch (e) {
      throw core_exceptions.ServerException('Error watching stations: $e');
    }
  }
}
