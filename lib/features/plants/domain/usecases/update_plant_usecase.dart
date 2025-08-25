import '../../../../core/utils/result.dart';
import '../entities/plant.dart';
import '../repositories/plant_repository.dart';

class UpdatePlantUseCase {
  final PlantRepository repository;

  UpdatePlantUseCase(this.repository);

  Future<Result<Plant>> call({
    required String plantId,
    String? name,
    String? emoji,
    String? description,
    String? deviceId,
    String? location,
    String? accessToken,
  }) async {
    return await repository.updatePlant(
      plantId: plantId,
      name: name,
      emoji: emoji,
      description: description,
      deviceId: deviceId,
      location: location,
      accessToken: accessToken,
    );
  }
}
