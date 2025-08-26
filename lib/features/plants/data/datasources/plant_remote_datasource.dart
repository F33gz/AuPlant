import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart' as core_exceptions;
import '../models/plant_dto.dart';

/// Remote data source for plant operations
abstract class PlantRemoteDataSource {
  Future<List<PlantDto>> getUserPlants();
  Future<PlantDto> getPlantById(String plantId);
  Future<PlantDto> addPlant({
    required String name,
    required String deviceId,
    String? emoji,
    String? description,
    String? location,
    String? accessToken,
  });
  Future<PlantDto> updatePlant({
    required String plantId,
    String? name,
    String? emoji,
    String? description,
    String? deviceId,
    String? location,
    String? accessToken,
  });
  Future<void> deletePlant(String plantId);
  Stream<List<PlantDto>> watchUserPlants();
}

/// Implementation of PlantRemoteDataSource using Supabase
class PlantRemoteDataSourceImpl implements PlantRemoteDataSource {
  final SupabaseClient supabaseClient;

  PlantRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<PlantDto>> getUserPlants() async {
    try {
      final response = await supabaseClient
          .from('plantas')
          .select('*')
          .order('created_at', ascending: false);

      return response.map<PlantDto>((json) => PlantDto.fromJson(json)).toList();
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching plants: $e');
    }
  }

  @override
  Future<PlantDto> getPlantById(String plantId) async {
    try {
      final response = await supabaseClient
          .from('plantas')
          .select('*')
          .eq('id', plantId)
          .single();

      return PlantDto.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching plant: $e');
    }
  }

  @override
  Future<PlantDto> addPlant({
    required String name,
    required String deviceId,
    String? emoji,
    String? description,
    String? location,
    String? accessToken,
  }) async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        throw core_exceptions.AuthException('User not authenticated');
      }

      final response = await supabaseClient
          .from('plantas')
          .insert({
            'nombre': name,
            'emoji': emoji ?? '🌱',
            'descripcion': description,
            'device_id': deviceId,
            'ubicacion': location,
            'user_id': session.user.id,
            'access_token': accessToken,
          })
          .select()
          .single();

      return PlantDto.fromJson(response);
    } catch (e) {
      throw core_exceptions.ServerException('Error adding plant: $e');
    }
  }

  @override
  Future<PlantDto> updatePlant({
    required String plantId,
    String? name,
    String? emoji,
    String? description,
    String? deviceId,
    String? location,
    String? accessToken,
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
      if (accessToken != null) updateData['access_token'] = accessToken;

      final response = await supabaseClient.functions.invoke(
        'modify_plant',
        body: {
          'action': 'update',
          'plantId': plantId,
          'updateData': updateData,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.data == null || response.data['success'] != true) {
        throw core_exceptions.ServerException('Error updating plant: ${response.data?['error'] ?? 'Unknown error'}');
      }

      // Refresh the model from the database
      final refreshed = await supabaseClient
          .from('plantas')
          .select()
          .eq('id', plantId)
          .single();

      return PlantDto.fromJson(refreshed);
    } catch (e) {
      throw core_exceptions.ServerException('Error updating plant: $e');
    }
  }

  @override
  Future<void> deletePlant(String plantId) async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) {
        throw core_exceptions.AuthException('User not authenticated');
      }

      final response = await supabaseClient.functions.invoke(
        'modify_plant',
        body: {
          'action': 'delete',
          'plantId': plantId,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.data == null || response.data['success'] != true) {
        throw core_exceptions.ServerException('Error deleting plant: ${response.data?['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw core_exceptions.ServerException('Error deleting plant: $e');
    }
  }

  @override
  Stream<List<PlantDto>> watchUserPlants() {
    try {
      return supabaseClient
          .from('plantas')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((data) => data.map<PlantDto>((json) => PlantDto.fromJson(json)).toList());
    } catch (e) {
      throw core_exceptions.ServerException('Error watching plants: $e');
    }
  }
}
