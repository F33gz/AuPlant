import '../services/local_station_settings_storage.dart';
import '../services/local_thresholds_storage.dart';
import '../../features/stations/domain/entities/station.dart';

/// Utilidad para combinar datos de estaciones del servidor con datos locales
class StationDataMerger {
  StationDataMerger._();
  
  /// Combina los datos de una estación del servidor con los guardados localmente
  /// 
  /// Los datos locales tienen prioridad sobre los del servidor
  static Future<Station> mergeWithLocalData(Station serverStation) async {
    // Cargar umbrales locales
    final localThresholds = await LocalThresholdsStorage.instance
        .getThresholds(serverStation.id);
    
    // Cargar info básica local
    final localSettings = await LocalStationSettingsStorage.instance
        .getSettings(serverStation.id);
    
    // Construir estación combinada
    var mergedStation = serverStation;
    
    if (localThresholds != null) {
      mergedStation = mergedStation.copyWith(thresholds: localThresholds);
    }
    
    if (localSettings != null) {
      mergedStation = mergedStation.copyWith(
        name: localSettings.name,
        emoji: localSettings.emoji,
        location: localSettings.location,
      );
    }
    
    return mergedStation;
  }
  
  /// Combina una lista de estaciones del servidor con datos locales
  static Future<List<Station>> mergeListWithLocalData(List<Station> serverStations) async {
    final mergedStations = <Station>[];
    
    for (final station in serverStations) {
      final merged = await mergeWithLocalData(station);
      mergedStations.add(merged);
    }
    
    return mergedStations;
  }
}
