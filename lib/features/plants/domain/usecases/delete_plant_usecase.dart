import '../../../../core/utils/result.dart';
import '../repositories/plant_repository.dart';

class DeletePlantUseCase {
  final PlantRepository repository;

  DeletePlantUseCase(this.repository);

  Future<Result<void>> call(String plantId) async {
    return await repository.deletePlant(plantId);
  }
}
