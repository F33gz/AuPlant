import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart' as fntz;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _fln = FlutterLocalNotificationsPlugin();
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _thresholdAlerts = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Local notifications init (Android/iOS)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _fln.initialize(initSettings);

    // Ask for permissions where needed
    await _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _fln.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);

    // Timezone init
    tzdata.initializeTimeZones();
    try {
      final name = await fntz.FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminderEnabled = prefs.getBool('notif_watering_enabled') ?? false;
      final hour = prefs.getInt('notif_watering_hour') ?? 9;
      final minute = prefs.getInt('notif_watering_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _thresholdAlerts = prefs.getBool('notif_threshold_alerts') ?? true;
    });
    if (_reminderEnabled) {
      _scheduleDailyReminder();
    }
  }

  Future<void> _scheduleDailyReminder() async {
    final androidDetails = const AndroidNotificationDetails(
      'watering_reminders', 'Recordatorios de riego',
      channelDescription: 'Notificaciones diarias para recordar regar tus plantas',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // Schedule at selected time daily
    final selected = _reminderTime;
  final tzTime = _nextInstanceOfTime(selected);
    await _fln.zonedSchedule(
      1001,
      'Recordatorio de riego',
      'Hora de revisar y regar tus plantas 🌿',
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  Future<void> _persistAndApply() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_watering_enabled', _reminderEnabled);
    await prefs.setInt('notif_watering_hour', _reminderTime.hour);
    await prefs.setInt('notif_watering_minute', _reminderTime.minute);
    await prefs.setBool('notif_threshold_alerts', _thresholdAlerts);
    if (_reminderEnabled) {
      await _scheduleDailyReminder();
    } else {
      await _fln.cancel(1001);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Recordatorio de regar'),
            subtitle: const Text('Recibe un recordatorio diario a una hora específica'),
            value: _reminderEnabled,
            onChanged: (v) async {
              setState(() => _reminderEnabled = v);
              await _persistAndApply();
            },
          ),
          ListTile(
            title: const Text('Hora del recordatorio'),
            subtitle: Text(_reminderTime.format(context)),
            enabled: _reminderEnabled,
            trailing: const Icon(Icons.schedule),
            onTap: !_reminderEnabled
                ? null
                : () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (picked != null) {
                      setState(() => _reminderTime = picked);
                      await _persistAndApply();
                    }
                  },
          ),
          const Divider(height: 32),
          SwitchListTile(
            title: const Text('Alertas por humedad baja'),
            subtitle: const Text('Notificar cuando la humedad baje del umbral configurado'),
            value: _thresholdAlerts,
            onChanged: (v) async {
              setState(() => _thresholdAlerts = v);
              await _persistAndApply();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
