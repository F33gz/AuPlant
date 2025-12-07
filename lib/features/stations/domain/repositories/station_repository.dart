import '../../../../core/utils/result.dart';
import '../entities/station.dart';
import '../entities/sensor_data.dart';
import '../entities/telemetry_history.dart';

/// Abstract repository for station operations
/// 
/// Defines the contract for data operations on greenhouse monitoring stations.
abstract class StationRepository {
  /// Get all stations for the current user
  Future<Result<List<Station>>> getUserStations();
  
  /// Get a specific station by ID
  Future<Result<Station>> getStationById(String stationId);
  
  /// Add a new station
  Future<Result<Station>> addStation({
    required String name,
    required String deviceId,
    String? emoji,
    String? description,
    String? location,
  });
  
  /// Update an existing station
  Future<Result<Station>> updateStation({
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
  });
  
  /// Delete a station
  Future<Result<void>> deleteStation(String stationId);
  
  /// Get sensor data for a station
  Future<Result<SensorData>> getSensorData(String stationId);
  
  /// Get sensor data for all stations
  Future<Result<List<SensorData>>> getAllSensorData();
  
  /// Get historical sensor data for a station
  /// 
  /// [stationId] - The station/device ID
  /// [timeRange] - Time range for historical data (e.g., last 24 hours)
  Future<Result<SensorHistoryData>> getSensorHistory(
    String stationId,
    HistoryTimeRange timeRange,
  );
}
