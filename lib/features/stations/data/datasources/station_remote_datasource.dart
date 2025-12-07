import 'dart:convert';

import '../../../../core/network/thingsboard_api_client.dart';
import '../../../../core/errors/exceptions.dart' as core_exceptions;
import '../models/station_dto.dart';

/// Remote data source for station operations using ThingsBoard
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

/// Implementation of StationRemoteDataSource using ThingsBoard API
class StationRemoteDataSourceImpl implements StationRemoteDataSource {
  final ThingsBoardApiClient apiClient;

  StationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<StationDto>> getUserStations() async {
    try {
      // First get the customerId from the current user's token
      final tokens = await apiClient.getCurrentTokens();
      if (tokens == null) {
        throw core_exceptions.AuthException('No hay sesión activa');
      }
      
      // Extract customerId from JWT token
      final customerId = _extractCustomerIdFromToken(tokens.token);
      if (customerId == null) {
        throw core_exceptions.ServerException('No se pudo obtener el customerId del usuario');
      }
      
      // Get devices for this customer
      // Endpoint: GET /api/customer/{customerId}/deviceInfos?pageSize=100&page=0
      final response = await apiClient.get(
        '/customer/$customerId/deviceInfos?pageSize=100&page=0&sortProperty=createdTime&sortOrder=DESC',
      );
      
      final data = response['data'] as List<dynamic>?;
      if (data == null) return [];
      
      return data
          .map((device) => StationDto.fromThingsBoardDeviceInfo(device as Map<String, dynamic>))
          .toList();
    } on core_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw core_exceptions.ServerException('Error fetching stations: $e');
    }
  }

  /// Extract customerId from JWT token payload
  String? _extractCustomerIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      // Parse JWT payload as JSON
      final jsonStr = _decodeBase64(parts[1]);
      final json = Map<String, dynamic>.from(
        const JsonDecoder().convert(jsonStr) as Map,
      );
      return json['customerId'] as String?;
    } catch (_) {
      return null;
    }
  }
  
  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0: break;
      case 2: output += '=='; break;
      case 3: output += '='; break;
      default: throw Exception('Invalid base64 string');
    }
    return String.fromCharCodes(base64Decode(output));
  }

  @override
  Future<StationDto> getStationById(String stationId) async {
    try {
      // Endpoint: GET /api/device/{deviceId}
      final response = await apiClient.get('/device/$stationId');
      return StationDto.fromThingsBoardDeviceInfo(response);
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
      // TODO: Implementar creación de dispositivo en ThingsBoard
      // Por ahora, solo verificamos que el deviceId existe en ThingsBoard
      // y lo asociamos con metadata local
      throw core_exceptions.ServerException('Station creation via app not supported yet');
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
      // TODO: Implementar actualización de atributos del dispositivo en ThingsBoard
      // Endpoint: POST /api/plugins/telemetry/DEVICE/{deviceId}/attributes/SHARED
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (emoji != null) updateData['emoji'] = emoji;
      if (description != null) updateData['description'] = description;
      if (location != null) updateData['location'] = location;
      if (minSoilHumidity != null) updateData['minSoilHumidity'] = minSoilHumidity;
      if (maxSoilHumidity != null) updateData['maxSoilHumidity'] = maxSoilHumidity;
      if (minAmbientHumidity != null) updateData['minAmbientHumidity'] = minAmbientHumidity;
      if (maxAmbientHumidity != null) updateData['maxAmbientHumidity'] = maxAmbientHumidity;
      if (minTemperature != null) updateData['minTemperature'] = minTemperature;
      if (maxTemperature != null) updateData['maxTemperature'] = maxTemperature;

      // TODO: Conectar con API real
      throw core_exceptions.ServerException('Station update via app not supported yet');
    } catch (e) {
      throw core_exceptions.ServerException('Error updating station: $e');
    }
  }

  @override
  Future<void> deleteStation(String stationId) async {
    try {
      // TODO: Implementar eliminación o desasociación del dispositivo
      throw core_exceptions.ServerException('Station deletion via app not supported yet');
    } catch (e) {
      throw core_exceptions.ServerException('Error deleting station: $e');
    }
  }

  @override
  Stream<List<StationDto>> watchUserStations() {
    // TODO: Implementar WebSocket o polling para actualizaciones en tiempo real
    // Por ahora, emitimos un stream que hace polling cada 30 segundos
    return Stream.periodic(
      const Duration(seconds: 30),
      (_) => getUserStations(),
    ).asyncMap((future) => future);
  }
}

