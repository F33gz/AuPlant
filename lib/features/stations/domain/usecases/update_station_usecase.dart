import '../../../../core/utils/result.dart';
import '../entities/station.dart';
import '../repositories/station_repository.dart';

/// Use case for updating an existing station
class UpdateStationUseCase {
  final StationRepository repository;

  const UpdateStationUseCase(this.repository);

  Future<Result<Station>> call({
    required String stationId,
    String? name,
    String? emoji,
    String? description,
    String? deviceId,
    String? location,
    double? minSoilHumidity,
    double? maxSoilHumidity,
    double? minAmbientHumidity,
    double? maxAmbientHumidity,
    double? minTemperature,
    double? maxTemperature,
  }) async {
    return await repository.updateStation(
      stationId: stationId,
      name: name,
      emoji: emoji,
      description: description,
      deviceId: deviceId,
      location: location,
      minSoilHumidity: minSoilHumidity,
      maxSoilHumidity: maxSoilHumidity,
      minAmbientHumidity: minAmbientHumidity,
      maxAmbientHumidity: maxAmbientHumidity,
      minTemperature: minTemperature,
      maxTemperature: maxTemperature,
    );
  }
}
