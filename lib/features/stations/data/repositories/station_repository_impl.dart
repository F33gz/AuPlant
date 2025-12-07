import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/repositories/station_repository.dart';
import '../datasources/station_remote_datasource.dart';
import '../datasources/sensor_remote_datasource.dart';

/// Implementation of StationRepository
class StationRepositoryImpl implements StationRepository {
  final StationRemoteDataSource stationRemoteDataSource;
  final SensorRemoteDataSource sensorRemoteDataSource;

  StationRepositoryImpl({
    required this.stationRemoteDataSource,
    required this.sensorRemoteDataSource,
  });

  @override
  Future<Result<List<Station>>> getUserStations() async {
    try {
      final stationDtos = await stationRemoteDataSource.getUserStations();
      final stations = stationDtos.map((dto) => dto.toEntity()).toList();
      return Success(stations);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Station>> getStationById(String stationId) async {
    try {
      final stationDto = await stationRemoteDataSource.getStationById(stationId);
      return Success(stationDto.toEntity());
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Station>> addStation({
    required String name,
    required String deviceId,
    String? emoji,
    String? description,
    String? location,
  }) async {
    try {
      final stationDto = await stationRemoteDataSource.addStation(
        name: name,
        deviceId: deviceId,
        emoji: emoji,
        description: description,
        location: location,
      );
      return Success(stationDto.toEntity());
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Station>> updateStation({
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
      final stationDto = await stationRemoteDataSource.updateStation(
        stationId: stationId,
        name: name,
        emoji: emoji,
        description: description,
        deviceId: deviceId,
        location: location,
        minSoilHumidity: minSoilHumidity,
        maxSoilHumidity: maxSoilHumidity,
        minAmbientHumidity: minAmbientHumidity,
        maxAmbientHumidity: maxAmbientHumidity,
        minTemperature: minTemperature,
        maxTemperature: maxTemperature,
      );
      return Success(stationDto.toEntity());
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> deleteStation(String stationId) async {
    try {
      await stationRemoteDataSource.deleteStation(stationId);
      return const Success(null);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<SensorData>> getSensorData(String stationId) async {
    try {
      final sensorDto = await sensorRemoteDataSource.getSensorData(stationId);
      return Success(sensorDto.toEntity());
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, code: e.code));
    } on PlantException catch (e) {
      return Error(PlantFailure(e.message, code: e.code));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<SensorData>>> getAllSensorData() async {
    try {
      final sensorDtos = await sensorRemoteDataSource.getAllSensorData();
      final sensorData = sensorDtos.map((dto) => dto.toEntity()).toList();
      return Success(sensorData);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message, code: e.code));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: $e'));
    }
  }

  /// Watch user stations stream
  Stream<Result<List<Station>>> watchUserStations() {
    try {
      return stationRemoteDataSource.watchUserStations().map(
        (stationDtos) {
          try {
            final stations = stationDtos.map((dto) => dto.toEntity()).toList();
            return Success(stations);
          } catch (e) {
            return Error(ServerFailure('Error processing station stream: $e'));
          }
        },
      );
    } catch (e) {
      return Stream.value(Error(ServerFailure('Error watching stations: $e')));
    }
  }
}
