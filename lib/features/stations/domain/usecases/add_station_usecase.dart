import '../../../../core/utils/result.dart';
import '../entities/station.dart';
import '../repositories/station_repository.dart';

/// Use case for adding a new station
class AddStationUseCase {
  final StationRepository repository;

  const AddStationUseCase(this.repository);

  Future<Result<Station>> call({
    required String name,
    required String deviceId,
    String? emoji,
    String? description,
    String? location,
  }) async {
    return await repository.addStation(
      name: name,
      deviceId: deviceId,
      emoji: emoji,
      description: description,
      location: location,
    );
  }
}
