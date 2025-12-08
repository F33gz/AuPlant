import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias de notificaciones por umbral
/// 
/// Almacena configuraciones locales para notificaciones de:
/// - Temperatura (min/max)
/// - Humedad del suelo (min/max)
/// - Humedad ambiente (min/max)
class ThresholdNotificationPreferences {
  ThresholdNotificationPreferences._();
  static final ThresholdNotificationPreferences instance = ThresholdNotificationPreferences._();

  // Keys para SharedPreferences
  static const String _keyTemperatureEnabled = 'notif_threshold_temperature_enabled';
  static const String _keySoilHumidityEnabled = 'notif_threshold_soil_humidity_enabled';
  static const String _keyAmbientHumidityEnabled = 'notif_threshold_ambient_humidity_enabled';
  static const String _keyGlobalEnabled = 'notif_threshold_alerts'; // compatibilidad con toggle existente

  // Cache local
  bool? _temperatureEnabled;
  bool? _soilHumidityEnabled;
  bool? _ambientHumidityEnabled;
  bool? _globalEnabled;

  /// Carga todas las preferencias de SharedPreferences
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _globalEnabled = prefs.getBool(_keyGlobalEnabled) ?? true;
    _temperatureEnabled = prefs.getBool(_keyTemperatureEnabled) ?? true;
    _soilHumidityEnabled = prefs.getBool(_keySoilHumidityEnabled) ?? true;
    _ambientHumidityEnabled = prefs.getBool(_keyAmbientHumidityEnabled) ?? true;
  }

  /// Verifica si las notificaciones globales están habilitadas
  Future<bool> isGlobalEnabled() async {
    if (_globalEnabled == null) await load();
    return _globalEnabled ?? true;
  }

  /// Verifica si las notificaciones de temperatura están habilitadas
  Future<bool> isTemperatureEnabled() async {
    if (_temperatureEnabled == null) await load();
    final global = await isGlobalEnabled();
    return global && (_temperatureEnabled ?? true);
  }

  /// Verifica si las notificaciones de humedad del suelo están habilitadas
  Future<bool> isSoilHumidityEnabled() async {
    if (_soilHumidityEnabled == null) await load();
    final global = await isGlobalEnabled();
    return global && (_soilHumidityEnabled ?? true);
  }

  /// Verifica si las notificaciones de humedad ambiente están habilitadas
  Future<bool> isAmbientHumidityEnabled() async {
    if (_ambientHumidityEnabled == null) await load();
    final global = await isGlobalEnabled();
    return global && (_ambientHumidityEnabled ?? true);
  }

  /// Habilita/deshabilita las notificaciones globales
  Future<void> setGlobalEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGlobalEnabled, enabled);
    _globalEnabled = enabled;
  }

  /// Habilita/deshabilita las notificaciones de temperatura
  Future<void> setTemperatureEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTemperatureEnabled, enabled);
    _temperatureEnabled = enabled;
  }

  /// Habilita/deshabilita las notificaciones de humedad del suelo
  Future<void> setSoilHumidityEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoilHumidityEnabled, enabled);
    _soilHumidityEnabled = enabled;
  }

  /// Habilita/deshabilita las notificaciones de humedad ambiente
  Future<void> setAmbientHumidityEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAmbientHumidityEnabled, enabled);
    _ambientHumidityEnabled = enabled;
  }

  /// Obtiene todas las preferencias actuales
  Future<ThresholdNotificationSettings> getSettings() async {
    await load();
    return ThresholdNotificationSettings(
      globalEnabled: _globalEnabled ?? true,
      temperatureEnabled: _temperatureEnabled ?? true,
      soilHumidityEnabled: _soilHumidityEnabled ?? true,
      ambientHumidityEnabled: _ambientHumidityEnabled ?? true,
    );
  }

  /// Guarda todas las preferencias de una vez
  Future<void> saveSettings(ThresholdNotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGlobalEnabled, settings.globalEnabled);
    await prefs.setBool(_keyTemperatureEnabled, settings.temperatureEnabled);
    await prefs.setBool(_keySoilHumidityEnabled, settings.soilHumidityEnabled);
    await prefs.setBool(_keyAmbientHumidityEnabled, settings.ambientHumidityEnabled);
    
    _globalEnabled = settings.globalEnabled;
    _temperatureEnabled = settings.temperatureEnabled;
    _soilHumidityEnabled = settings.soilHumidityEnabled;
    _ambientHumidityEnabled = settings.ambientHumidityEnabled;
  }

  /// Limpia el cache local para forzar recarga desde SharedPreferences
  void clearCache() {
    _globalEnabled = null;
    _temperatureEnabled = null;
    _soilHumidityEnabled = null;
    _ambientHumidityEnabled = null;
  }
}

/// Modelo de configuraciones de notificaciones por umbral
class ThresholdNotificationSettings {
  final bool globalEnabled;
  final bool temperatureEnabled;
  final bool soilHumidityEnabled;
  final bool ambientHumidityEnabled;

  const ThresholdNotificationSettings({
    required this.globalEnabled,
    required this.temperatureEnabled,
    required this.soilHumidityEnabled,
    required this.ambientHumidityEnabled,
  });

  ThresholdNotificationSettings copyWith({
    bool? globalEnabled,
    bool? temperatureEnabled,
    bool? soilHumidityEnabled,
    bool? ambientHumidityEnabled,
  }) {
    return ThresholdNotificationSettings(
      globalEnabled: globalEnabled ?? this.globalEnabled,
      temperatureEnabled: temperatureEnabled ?? this.temperatureEnabled,
      soilHumidityEnabled: soilHumidityEnabled ?? this.soilHumidityEnabled,
      ambientHumidityEnabled: ambientHumidityEnabled ?? this.ambientHumidityEnabled,
    );
  }
}
