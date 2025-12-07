import '../../../../core/utils/result.dart';
import '../repositories/station_repository.dart';

/// Use case for deleting a station
class DeleteStationUseCase {
  final StationRepository repository;

  const DeleteStationUseCase(this.repository);

  Future<Result<void>> call(String stationId) async {
    return await repository.deleteStation(stationId);
  }
}
