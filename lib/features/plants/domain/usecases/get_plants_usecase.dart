import '../../../../core/utils/result.dart';
import '../entities/plant.dart';
import '../repositories/plant_repository.dart';

/// Use case for getting user plants
class GetPlantsUseCase {
  final PlantRepository repository;

  const GetPlantsUseCase(this.repository);

  Future<Result<List<Plant>>> call() async {
    return await repository.getUserPlants();
  }
}
