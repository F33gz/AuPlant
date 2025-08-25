import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Core
import '../network/network_info.dart';

// Features - Plants
import '../../features/plants/data/datasources/plant_remote_datasource.dart';
import '../../features/plants/data/datasources/sensor_remote_datasource.dart';
import '../../features/plants/data/repositories/plant_repository_impl.dart';
import '../../features/plants/domain/repositories/plant_repository.dart';
import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../features/plants/domain/usecases/get_sensor_data_usecase.dart';
import '../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../../features/plants/domain/usecases/delete_plant_usecase.dart';

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
  sl.registerLazySingleton<PlantRemoteDataSource>(
    () => PlantRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );
  
  sl.registerLazySingleton<SensorRemoteDataSource>(
    () => SensorRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );

  // Repositories
  sl.registerLazySingleton<PlantRepository>(
    () => PlantRepositoryImpl(
      plantRemoteDataSource: sl<PlantRemoteDataSource>(),
      sensorRemoteDataSource: sl<SensorRemoteDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPlantsUseCase(sl<PlantRepository>()));
  sl.registerLazySingleton(() => AddPlantUseCase(sl<PlantRepository>()));
  sl.registerLazySingleton(() => GetSensorDataUseCase(sl<PlantRepository>()));
  sl.registerLazySingleton(() => UpdatePlantUseCase(sl<PlantRepository>()));
  sl.registerLazySingleton(() => DeletePlantUseCase(sl<PlantRepository>()));
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
