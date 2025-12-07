import '../../../../core/utils/result.dart';
import '../entities/sensor_data.dart';
import '../repositories/station_repository.dart';

/// Use case for getting sensor data
class GetSensorDataUseCase {
  final StationRepository repository;

  const GetSensorDataUseCase(this.repository);

  /// Get sensor data for a specific station
  Future<Result<SensorData>> call(String stationId) async {
    return await repository.getSensorData(stationId);
  }

  /// Get sensor data for all stations
  Future<Result<List<SensorData>>> callForAllStations() async {
    return await repository.getAllSensorData();
  }
}
