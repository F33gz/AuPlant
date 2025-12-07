import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Core
import '../network/network_info.dart';

// Features - Stations (greenhouse monitoring)
import '../../features/stations/data/datasources/station_remote_datasource.dart';
import '../../features/stations/data/datasources/sensor_remote_datasource.dart';
import '../../features/stations/data/repositories/station_repository_impl.dart';
import '../../features/stations/domain/repositories/station_repository.dart';
import '../../features/stations/domain/usecases/get_stations_usecase.dart';
import '../../features/stations/domain/usecases/add_station_usecase.dart';
import '../../features/stations/domain/usecases/get_sensor_data_usecase.dart';
import '../../features/stations/domain/usecases/update_station_usecase.dart';
import '../../features/stations/domain/usecases/delete_station_usecase.dart';

final GetIt sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initializeDependencies() async {
  // External dependencies
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // Data sources
  sl.registerLazySingleton<StationRemoteDataSource>(
    () => StationRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );
  
  sl.registerLazySingleton<SensorRemoteDataSource>(
    () => SensorRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );

  // Repositories
  sl.registerLazySingleton<StationRepository>(
    () => StationRepositoryImpl(
      stationRemoteDataSource: sl<StationRemoteDataSource>(),
      sensorRemoteDataSource: sl<SensorRemoteDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetStationsUseCase(sl<StationRepository>()));
  sl.registerLazySingleton(() => AddStationUseCase(sl<StationRepository>()));
  sl.registerLazySingleton(() => GetSensorDataUseCase(sl<StationRepository>()));
  sl.registerLazySingleton(() => UpdateStationUseCase(sl<StationRepository>()));
  sl.registerLazySingleton(() => DeleteStationUseCase(sl<StationRepository>()));
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
