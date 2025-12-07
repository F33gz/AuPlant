import '../../../../core/utils/result.dart';
import '../entities/telemetry_history.dart';
import '../repositories/station_repository.dart';

/// Use case for getting historical sensor data
class GetSensorHistoryUseCase {
  final StationRepository repository;

  const GetSensorHistoryUseCase(this.repository);

  /// Get historical sensor data for a specific station
  /// 
  /// [stationId] - The station/device ID
  /// [timeRange] - Time range for historical data (defaults to last 24 hours)
  Future<Result<SensorHistoryData>> call(
    String stationId, {
    HistoryTimeRange timeRange = HistoryTimeRange.last24Hours,
  }) async {
    return await repository.getSensorHistory(stationId, timeRange);
  }
}
