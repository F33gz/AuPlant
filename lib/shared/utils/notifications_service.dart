import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../core/services/threshold_notification_preferences.dart';

/// Tipos de alerta de umbral
enum ThresholdAlertType {
  temperatureLow,
  temperatureHigh,
  soilHumidityLow,
  soilHumidityHigh,
  ambientHumidityLow,
  ambientHumidityHigh,
}

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _wateringNotifId = 1001;
  static const _wateringChannelId = 'watering_reminders';
  static const _wateringChannelName = 'Recordatorios de riego';

  // Canales para alertas de umbrales
  static const _temperatureAlertChannelId = 'temperature_alerts';
  static const _temperatureAlertChannelName = 'Alertas de temperatura';
  static const _soilHumidityAlertChannelId = 'soil_humidity_alerts';
  static const _soilHumidityAlertChannelName = 'Alertas de humedad del suelo';
  static const _ambientHumidityAlertChannelId = 'ambient_humidity_alerts';
  static const _ambientHumidityAlertChannelName = 'Alertas de humedad ambiente';

  Future<void> initialize() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _fln.initialize(initSettings);

    // Request permissions
    await _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _fln.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);

    // Timezone init
    tz.initializeTimeZones();
    final candidates = <String>[
      'America/Bogota', 'America/Mexico_City', 'America/Lima', 'America/Guayaquil',
      'America/Argentina/Buenos_Aires', 'America/Santiago', 'America/Sao_Paulo',
      'Europe/Madrid', 'UTC',
    ];
    bool set = false;
    for (final id in candidates) {
      try {
        tz.setLocalLocation(tz.getLocation(id));
        set = true;
        break;
      } catch (_) {}
    }
    if (!set) tz.setLocalLocation(tz.getLocation('UTC'));

    _initialized = true;
  }

  Future<void> scheduleDailyWateringReminder(TimeOfDay time) async {
    await initialize();
    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        _wateringChannelId,
        _wateringChannelName,
        channelDescription: 'Notificaciones diarias para recordar regar tus plantas',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    final now = tz.TZDateTime.now(tz.local);
    var schedule = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (schedule.isBefore(now)) schedule = schedule.add(const Duration(days: 1));
    await _fln.zonedSchedule(
      _wateringNotifId,
      'Recordatorio de riego',
      'Hora de revisar y regar tus plantas 🌿',
      schedule,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyWateringReminder() async {
    await initialize();
    await _fln.cancel(_wateringNotifId);
  }

  /// Muestra una alerta de umbral una vez por día por tipo y estación
  /// 
  /// [stationId] - ID único de la estación
  /// [stationName] - Nombre para mostrar de la estación
  /// [alertType] - Tipo de alerta (temp alta/baja, humedad suelo alta/baja, humedad ambiente alta/baja)
  /// [currentValue] - Valor actual del sensor
  /// [thresholdValue] - Valor del umbral que se cruzó
  Future<void> showThresholdAlert({
    required String stationId,
    required String stationName,
    required ThresholdAlertType alertType,
    required double currentValue,
    required double thresholdValue,
  }) async {
    await initialize();

    // Verificar si está habilitada según el tipo
    final prefs = ThresholdNotificationPreferences.instance;
    bool enabled = false;
    
    switch (alertType) {
      case ThresholdAlertType.temperatureLow:
      case ThresholdAlertType.temperatureHigh:
        enabled = await prefs.isTemperatureEnabled();
        break;
      case ThresholdAlertType.soilHumidityLow:
      case ThresholdAlertType.soilHumidityHigh:
        enabled = await prefs.isSoilHumidityEnabled();
        break;
      case ThresholdAlertType.ambientHumidityLow:
      case ThresholdAlertType.ambientHumidityHigh:
        enabled = await prefs.isAmbientHumidityEnabled();
        break;
    }

    if (!enabled) return;

    // Control de una alerta por día por tipo y estación
    final sharedPrefs = await SharedPreferences.getInstance();
    final todayKey = 'alert_${stationId}_${alertType.name}_date';
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final last = sharedPrefs.getString(todayKey);
    if (last == todayStr) return; // ya se alertó hoy

    // Generar datos de notificación según tipo
    final (title, body, channelId, channelName) = _getAlertContent(
      alertType: alertType,
      stationName: stationName,
      currentValue: currentValue,
      thresholdValue: thresholdValue,
    );

    final id = _generateNotificationId(stationId, alertType);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Alertas cuando los valores cruzan los umbrales configurados',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _fln.show(id, title, body, details);
    await sharedPrefs.setString(todayKey, todayStr);
  }

  /// Genera contenido de la notificación según el tipo de alerta
  (String title, String body, String channelId, String channelName) _getAlertContent({
    required ThresholdAlertType alertType,
    required String stationName,
    required double currentValue,
    required double thresholdValue,
  }) {
    switch (alertType) {
      case ThresholdAlertType.temperatureLow:
        return (
          '🌡️ Temperatura baja en $stationName',
          'La temperatura (${currentValue.toStringAsFixed(1)}°C) está por debajo del mínimo (${thresholdValue.toStringAsFixed(1)}°C)',
          _temperatureAlertChannelId,
          _temperatureAlertChannelName,
        );
      case ThresholdAlertType.temperatureHigh:
        return (
          '🌡️ Temperatura alta en $stationName',
          'La temperatura (${currentValue.toStringAsFixed(1)}°C) está por encima del máximo (${thresholdValue.toStringAsFixed(1)}°C)',
          _temperatureAlertChannelId,
          _temperatureAlertChannelName,
        );
      case ThresholdAlertType.soilHumidityLow:
        return (
          '💧 Humedad del suelo baja en $stationName',
          'La humedad del suelo (${currentValue.toStringAsFixed(0)}%) está por debajo del mínimo (${thresholdValue.toStringAsFixed(0)}%)',
          _soilHumidityAlertChannelId,
          _soilHumidityAlertChannelName,
        );
      case ThresholdAlertType.soilHumidityHigh:
        return (
          '💧 Humedad del suelo alta en $stationName',
          'La humedad del suelo (${currentValue.toStringAsFixed(0)}%) está por encima del máximo (${thresholdValue.toStringAsFixed(0)}%)',
          _soilHumidityAlertChannelId,
          _soilHumidityAlertChannelName,
        );
      case ThresholdAlertType.ambientHumidityLow:
        return (
          '💨 Humedad ambiente baja en $stationName',
          'La humedad ambiente (${currentValue.toStringAsFixed(0)}%) está por debajo del mínimo (${thresholdValue.toStringAsFixed(0)}%)',
          _ambientHumidityAlertChannelId,
          _ambientHumidityAlertChannelName,
        );
      case ThresholdAlertType.ambientHumidityHigh:
        return (
          '💨 Humedad ambiente alta en $stationName',
          'La humedad ambiente (${currentValue.toStringAsFixed(0)}%) está por encima del máximo (${thresholdValue.toStringAsFixed(0)}%)',
          _ambientHumidityAlertChannelId,
          _ambientHumidityAlertChannelName,
        );
    }
  }

  /// Genera un ID único de notificación basado en estación y tipo de alerta
  int _generateNotificationId(String stationId, ThresholdAlertType alertType) {
    // Base IDs: 2000-2999 para temperatura, 3000-3999 para suelo, 4000-4999 para ambiente
    final baseId = switch (alertType) {
      ThresholdAlertType.temperatureLow => 2000,
      ThresholdAlertType.temperatureHigh => 2100,
      ThresholdAlertType.soilHumidityLow => 3000,
      ThresholdAlertType.soilHumidityHigh => 3100,
      ThresholdAlertType.ambientHumidityLow => 4000,
      ThresholdAlertType.ambientHumidityHigh => 4100,
    };
    return baseId + _stableId(stationId);
  }

  // Método legacy para compatibilidad
  Future<void> showThresholdAlertOncePerDay({
    required String plantId,
    required String plantName,
    required double humidity,
    required double minHum,
  }) async {
    if (humidity >= minHum) return;
    
    await showThresholdAlert(
      stationId: plantId,
      stationName: plantName,
      alertType: ThresholdAlertType.soilHumidityLow,
      currentValue: humidity,
      thresholdValue: minHum,
    );
  }

  int _stableId(String s) {
    // Simple deterministic hash
    var h = 0;
    for (final codeUnit in s.codeUnits) {
      h = (h * 31 + codeUnit) & 0x7fffffff;
    }
    return h % 100; // keep range reasonable within each category
  }
}
