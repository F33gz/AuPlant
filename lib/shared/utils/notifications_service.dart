// no-op
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _wateringNotifId = 1001;
  static const _wateringChannelId = 'watering_reminders';
  static const _wateringChannelName = 'Recordatorios de riego';

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

  Future<void> showThresholdAlertOncePerDay({
    required String plantId,
    required String plantName,
    required double humidity,
    required double minHum,
  }) async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notif_threshold_alerts') ?? true;
    if (!enabled) return;

    if (humidity >= minHum) return;

    final todayKey = 'alert_${plantId}_date';
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final last = prefs.getString(todayKey);
    if (last == todayStr) return; // already alerted today

    final id = 2000 + _stableId(plantId);
    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'threshold_alerts',
        'Alertas de humedad',
        channelDescription: 'Alertas cuando la humedad baja del umbral',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _fln.show(
      id,
      'Humedad baja en $plantName',
      'La humedad (${humidity.toStringAsFixed(0)}%) está por debajo del umbral (${minHum.toStringAsFixed(0)}%).',
      details,
    );
    await prefs.setString(todayKey, todayStr);
  }

  int _stableId(String s) {
    // Simple deterministic hash
    var h = 0;
    for (final codeUnit in s.codeUnits) {
      h = (h * 31 + codeUnit) & 0x7fffffff;
    }
    return h % 8000; // keep range reasonable
  }
}
