import '../../../../core/utils/result.dart';
import '../entities/sensor_data.dart';
import '../repositories/plant_repository.dart';

/// Use case for getting sensor data
class GetSensorDataUseCase {
  final PlantRepository repository;

  const GetSensorDataUseCase(this.repository);

  /// Get sensor data for a specific plant
  Future<Result<SensorData>> call(String plantId) async {
    return await repository.getSensorData(plantId);
  }

  /// Get sensor data for all plants
  Future<Result<List<SensorData>>> callForAllPlants() async {
    return await repository.getAllSensorData();
  }
}
