import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/stations/domain/entities/station.dart';

/// Almacenamiento local de umbrales de estaciones
/// 
/// Guarda los umbrales configurados por el usuario de manera local
/// usando SharedPreferences. No envía datos al servidor.
class LocalThresholdsStorage {
  LocalThresholdsStorage._();
  static final LocalThresholdsStorage instance = LocalThresholdsStorage._();

  static const String _keyPrefix = 'station_thresholds_';

  /// Guarda los umbrales de una estación localmente
  Future<void> saveThresholds(String stationId, StationThresholds thresholds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$stationId';
    
    final data = {
      'minSoilHumidity': thresholds.minSoilHumidity,
      'maxSoilHumidity': thresholds.maxSoilHumidity,
      'minAmbientHumidity': thresholds.minAmbientHumidity,
      'maxAmbientHumidity': thresholds.maxAmbientHumidity,
      'minTemperature': thresholds.minTemperature,
      'maxTemperature': thresholds.maxTemperature,
    };
    
    await prefs.setString(key, jsonEncode(data));
  }

  /// Obtiene los umbrales guardados localmente para una estación
  /// Retorna null si no hay umbrales guardados
  Future<StationThresholds?> getThresholds(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$stationId';
    
    final jsonStr = prefs.getString(key);
    if (jsonStr == null) return null;
    
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return StationThresholds(
        minSoilHumidity: (data['minSoilHumidity'] as num).toDouble(),
        maxSoilHumidity: (data['maxSoilHumidity'] as num).toDouble(),
        minAmbientHumidity: (data['minAmbientHumidity'] as num).toDouble(),
        maxAmbientHumidity: (data['maxAmbientHumidity'] as num).toDouble(),
        minTemperature: (data['minTemperature'] as num).toDouble(),
        maxTemperature: (data['maxTemperature'] as num).toDouble(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene los umbrales para una estación, usando los locales si existen
  /// o los por defecto de la estación si no hay guardados localmente
  Future<StationThresholds> getThresholdsOrDefault(String stationId, StationThresholds defaultThresholds) async {
    final local = await getThresholds(stationId);
    return local ?? defaultThresholds;
  }

  /// Elimina los umbrales guardados de una estación
  Future<void> deleteThresholds(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$stationId';
    await prefs.remove(key);
  }

  /// Verifica si hay umbrales guardados localmente para una estación
  Future<bool> hasLocalThresholds(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$stationId';
    return prefs.containsKey(key);
  }

  /// Obtiene todos los IDs de estaciones que tienen umbrales guardados localmente
  Future<List<String>> getAllStationIdsWithLocalThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    return keys.map((k) => k.substring(_keyPrefix.length)).toList();
  }
}
