import '../../../../core/utils/result.dart';
import '../entities/plant.dart';
import '../repositories/plant_repository.dart';

/// Use case for adding a new plant
class AddPlantUseCase {
  final PlantRepository repository;

  const AddPlantUseCase(this.repository);

  Future<Result<Plant>> call({
    required String name,
    required String deviceId,
    String? emoji,
    String? description,
    String? location,
    String? accessToken,
  }) async {
    return await repository.addPlant(
      name: name,
      deviceId: deviceId,
      emoji: emoji,
      description: description,
      location: location,
      accessToken: accessToken,
    );
  }
}
