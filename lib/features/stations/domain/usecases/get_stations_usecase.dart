import '../../../../core/utils/result.dart';
import '../entities/station.dart';
import '../repositories/station_repository.dart';

/// Use case for getting user stations
class GetStationsUseCase {
  final StationRepository repository;

  const GetStationsUseCase(this.repository);

  Future<Result<List<Station>>> call() async {
    return await repository.getUserStations();
  }
}
