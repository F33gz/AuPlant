import '../../../../core/utils/result.dart';
import '../entities/plant.dart';
import '../entities/sensor_data.dart';

/// Abstract repository for plant operations
abstract class PlantRepository {
  /// Get all plants for the current user
  Future<Result<List<Plant>>> getUserPlants();
  
  /// Get a specific plant by ID
  Future<Result<Plant>> getPlantById(String plantId);
  
  /// Add a new plant
  Future<Result<Plant>> addPlant({
    required String name,
    required String deviceId,
    String? emoji,
    String? description,
    String? location,
    String? accessToken,
  });
  
  /// Update an existing plant
  Future<Result<Plant>> updatePlant({
    required String plantId,
    String? name,
    String? emoji,
    String? description,
    String? deviceId,
    String? location,
    String? accessToken,
  });
  
  /// Delete a plant
  Future<Result<void>> deletePlant(String plantId);
  
  /// Get sensor data for a plant
  Future<Result<SensorData>> getSensorData(String plantId);
  
  /// Get sensor data for all plants
  Future<Result<List<SensorData>>> getAllSensorData();
  
  /// Send watering command
  Future<Result<void>> sendWateringCommand({
    required String accessToken,
    required Map<String, dynamic> attributes,
  });
  
  /// Watch plants for real-time updates
  Stream<Result<List<Plant>>> watchUserPlants();
}
