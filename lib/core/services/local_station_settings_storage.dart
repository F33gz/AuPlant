import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento local de configuraciones básicas de estaciones
/// 
/// Guarda nombre, emoji y ubicación de manera local usando SharedPreferences.
/// No envía datos al servidor.
class LocalStationSettingsStorage {
  LocalStationSettingsStorage._();
  static final LocalStationSettingsStorage instance = LocalStationSettingsStorage._();

  static const String _keyPrefix = 'station_settings_';

  /// Guarda la configuración básica de una estación localmente
  Future<void> saveSettings(String stationId, LocalStationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$stationId';
    
    final data = {
      'name': settings.name,
      'emoji': settings.emoji,
      'location': settings.location,
    };
    
    await prefs.setString(key, jsonEncode(data));
  }

  /// Obtiene la configuración guardada localmente para una estación
  /// Retorna null si no hay configuración guardada
  Future<LocalStationSettings?> getSettings(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$stationId';
    
    final jsonStr = prefs.getString(key);
    if (jsonStr == null) return null;
    
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return LocalStationSettings(
        name: data['name'] as String,
        emoji: data['emoji'] as String,
        location: data['location'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  /// Verifica si hay configuración guardada localmente para una estación
  Future<bool> hasLocalSettings(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$stationId';
    return prefs.containsKey(key);
  }

  /// Elimina la configuración guardada de una estación
  Future<void> deleteSettings(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$stationId';
    await prefs.remove(key);
  }

  /// Obtiene todos los IDs de estaciones que tienen configuración guardada localmente
  Future<List<String>> getAllStationIdsWithLocalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    return keys.map((k) => k.substring(_keyPrefix.length)).toList();
  }
}

/// Modelo de configuración básica de una estación
class LocalStationSettings {
  final String name;
  final String emoji;
  final String? location;

  const LocalStationSettings({
    required this.name,
    required this.emoji,
    this.location,
  });

  LocalStationSettings copyWith({
    String? name,
    String? emoji,
    String? location,
  }) {
    return LocalStationSettings(
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      location: location ?? this.location,
    );
  }
}
