import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

// Core
import '../network/network_info.dart';
import '../network/auth_token_storage.dart';
import '../network/thingsboard_api_client.dart';
import '../network/thingsboard_websocket_client.dart';

// Features - Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// Features - Stations (greenhouse monitoring)
import '../../features/stations/data/datasources/station_remote_datasource.dart';
import '../../features/stations/data/datasources/sensor_remote_datasource.dart';
import '../../features/stations/data/repositories/station_repository_impl.dart';
import '../../features/stations/domain/repositories/station_repository.dart';
import '../../features/stations/domain/usecases/get_stations_usecase.dart';
import '../../features/stations/domain/usecases/add_station_usecase.dart';
import '../../features/stations/domain/usecases/get_sensor_data_usecase.dart';
import '../../features/stations/domain/usecases/get_sensor_history_usecase.dart';
import '../../features/stations/domain/usecases/update_station_usecase.dart';
import '../../features/stations/domain/usecases/delete_station_usecase.dart';

final GetIt sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // External dependencies
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Core - Network
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );
  
  // Core - Auth Token Storage
  sl.registerLazySingleton<AuthTokenStorage>(
    () => AuthTokenStorageImpl(),
  );
  
  // Core - ThingsBoard API Client
  sl.registerLazySingleton<ThingsBoardApiClient>(
    () => ThingsBoardApiClient(
      httpClient: sl<http.Client>(),
      tokenStorage: sl<AuthTokenStorage>(),
    ),
  );
  
  // Core - ThingsBoard WebSocket Client for real-time telemetry
  sl.registerLazySingleton<ThingsBoardWebSocketClient>(
    () => ThingsBoardWebSocketClient(
      tokenStorage: sl<AuthTokenStorage>(),
    ),
  );

  // Auth - Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      apiClient: sl<ThingsBoardApiClient>(),
    ),
  );

  // Auth - Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
    ),
  );

  // Stations - Data sources
  sl.registerLazySingleton<StationRemoteDataSource>(
    () => StationRemoteDataSourceImpl(
      apiClient: sl<ThingsBoardApiClient>(),
    ),
  );
  
  sl.registerLazySingleton<SensorRemoteDataSource>(
    () => SensorRemoteDataSourceImpl(
      apiClient: sl<ThingsBoardApiClient>(),
    ),
  );

  // Stations - Repositories
  sl.registerLazySingleton<StationRepository>(
    () => StationRepositoryImpl(
      stationRemoteDataSource: sl<StationRemoteDataSource>(),
      sensorRemoteDataSource: sl<SensorRemoteDataSource>(),
    ),
  );

  // Stations - Use cases
  sl.registerLazySingleton(() => GetStationsUseCase(sl<StationRepository>()));
  sl.registerLazySingleton(() => AddStationUseCase(sl<StationRepository>()));
  sl.registerLazySingleton(() => GetSensorDataUseCase(sl<StationRepository>()));
  sl.registerLazySingleton(() => GetSensorHistoryUseCase(sl<StationRepository>()));
  sl.registerLazySingleton(() => UpdateStationUseCase(sl<StationRepository>()));
  sl.registerLazySingleton(() => DeleteStationUseCase(sl<StationRepository>()));
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}

