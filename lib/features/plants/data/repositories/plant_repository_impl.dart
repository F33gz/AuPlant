import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/plant.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/repositories/plant_repository.dart';
import '../datasources/plant_remote_datasource.dart';
import '../datasources/sensor_remote_datasource.dart';

/// Implementation of PlantRepository
class PlantRepositoryImpl implements PlantRepository {
  final PlantRemoteDataSource plantRemoteDataSource;
  final SensorRemoteDataSource sensorRemoteDataSource;

  PlantRepositoryImpl({
    required this.plantRemoteDataSource,
    required this.sensorRemoteDataSource,
  });

  @override
  Future<Result<List<Plant>>> getUserPlants() async {
    try {
      final plantDtos = await plantRemoteDataSource.getUserPlants();
      final plants = plantDtos.map((dto) => dto.toEntity()).toList();
      return Success(plants);
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
  Future<Result<Plant>> getPlantById(String plantId) async {
    try {
      final plantDto = await plantRemoteDataSource.getPlantById(plantId);
      return Success(plantDto.toEntity());
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
  Future<Result<Plant>> addPlant({
    required String name,
    required String deviceId,
    String? emoji,
    String? description,
    String? location,
  }) async {
    try {
      final plantDto = await plantRemoteDataSource.addPlant(
        name: name,
        deviceId: deviceId,
        emoji: emoji,
        description: description,
        location: location,
      );
      return Success(plantDto.toEntity());
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
  Future<Result<Plant>> updatePlant({
    required String plantId,
    String? name,
    String? emoji,
    String? description,
    String? deviceId,
    String? location,
  }) async {
    try {
      final plantDto = await plantRemoteDataSource.updatePlant(
        plantId: plantId,
        name: name,
        emoji: emoji,
        description: description,
        deviceId: deviceId,
        location: location,
      );
      return Success(plantDto.toEntity());
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
  Future<Result<void>> deletePlant(String plantId) async {
    try {
      await plantRemoteDataSource.deletePlant(plantId);
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
  Future<Result<SensorData>> getSensorData(String plantId) async {
    try {
      final sensorDto = await sensorRemoteDataSource.getSensorData(plantId);
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

  @override
  Future<Result<void>> sendWateringCommand({
    required String plantId,
    required Map<String, dynamic> attributes,
  }) async {
    try {
      await sensorRemoteDataSource.sendWateringCommand(
        plantId: plantId,
        attributes: attributes,
      );
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
  Stream<Result<List<Plant>>> watchUserPlants() {
    try {
      return plantRemoteDataSource.watchUserPlants().map(
        (plantDtos) {
          try {
            final plants = plantDtos.map((dto) => dto.toEntity()).toList();
            return Success(plants);
          } catch (e) {
            return Error(ServerFailure('Error processing plant stream: $e'));
          }
        },
      );
    } catch (e) {
      return Stream.value(Error(ServerFailure('Error watching plants: $e')));
    }
  }
}
