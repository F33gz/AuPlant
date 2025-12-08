import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../../../../core/services/threshold_notification_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _fln = FlutterLocalNotificationsPlugin();
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  
  // Alertas de umbrales
  bool _thresholdAlertsGlobal = true;
  bool _temperatureAlerts = true;
  bool _soilHumidityAlerts = true;
  bool _ambientHumidityAlerts = true;

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
    // Best-effort: guess local zone by common IDs or fallback to UTC
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

    // Cargar preferencias de recordatorio de riego
    final prefs = await SharedPreferences.getInstance();
    final reminderEnabled = prefs.getBool('notif_watering_enabled') ?? false;
    final hour = prefs.getInt('notif_watering_hour') ?? 9;
    final minute = prefs.getInt('notif_watering_minute') ?? 0;
    
    // Cargar preferencias de umbrales
    final thresholdPrefs = await ThresholdNotificationPreferences.instance.getSettings();
    
    setState(() {
      _reminderEnabled = reminderEnabled;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _thresholdAlertsGlobal = thresholdPrefs.globalEnabled;
      _temperatureAlerts = thresholdPrefs.temperatureEnabled;
      _soilHumidityAlerts = thresholdPrefs.soilHumidityEnabled;
      _ambientHumidityAlerts = thresholdPrefs.ambientHumidityEnabled;
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
    
    // Guardar preferencias de umbrales
    await ThresholdNotificationPreferences.instance.saveSettings(
      ThresholdNotificationSettings(
        globalEnabled: _thresholdAlertsGlobal,
        temperatureEnabled: _temperatureAlerts,
        soilHumidityEnabled: _soilHumidityAlerts,
        ambientHumidityEnabled: _ambientHumidityAlerts,
      ),
    );
    
    if (_reminderEnabled) {
      await _scheduleDailyReminder();
    } else {
      await _fln.cancel(1001);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabledColor = theme.disabledColor;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección: Recordatorios de riego
          _buildSectionHeader(context, 'Recordatorios de riego', Icons.water_drop),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Recordatorio diario'),
                  subtitle: const Text('Recibe un recordatorio para revisar tus plantas'),
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
                  trailing: Icon(Icons.schedule, color: _reminderEnabled ? null : disabledColor),
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
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sección: Alertas por umbrales
          _buildSectionHeader(context, 'Alertas por umbrales', Icons.notifications_active),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Alertas activas'),
                  subtitle: const Text('Habilitar todas las alertas por umbrales'),
                  value: _thresholdAlertsGlobal,
                  onChanged: (v) async {
                    setState(() => _thresholdAlertsGlobal = v);
                    await _persistAndApply();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.thermostat,
                        size: 20,
                        color: _thresholdAlertsGlobal ? theme.colorScheme.primary : disabledColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Temperatura'),
                    ],
                  ),
                  subtitle: const Text('Alertar cuando salga del rango configurado'),
                  value: _temperatureAlerts && _thresholdAlertsGlobal,
                  onChanged: _thresholdAlertsGlobal
                      ? (v) async {
                          setState(() => _temperatureAlerts = v);
                          await _persistAndApply();
                        }
                      : null,
                ),
                SwitchListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.grass,
                        size: 20,
                        color: _thresholdAlertsGlobal ? theme.colorScheme.primary : disabledColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Humedad del suelo'),
                    ],
                  ),
                  subtitle: const Text('Alertar cuando salga del rango configurado'),
                  value: _soilHumidityAlerts && _thresholdAlertsGlobal,
                  onChanged: _thresholdAlertsGlobal
                      ? (v) async {
                          setState(() => _soilHumidityAlerts = v);
                          await _persistAndApply();
                        }
                      : null,
                ),
                SwitchListTile(
                  title: Row(
                    children: [
                      Icon(
                        Icons.water,
                        size: 20,
                        color: _thresholdAlertsGlobal ? theme.colorScheme.primary : disabledColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Humedad ambiente'),
                    ],
                  ),
                  subtitle: const Text('Alertar cuando salga del rango configurado'),
                  value: _ambientHumidityAlerts && _thresholdAlertsGlobal,
                  onChanged: _thresholdAlertsGlobal
                      ? (v) async {
                          setState(() => _ambientHumidityAlerts = v);
                          await _persistAndApply();
                        }
                      : null,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nota informativa
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los umbrales se configuran por estación en la configuración de cada una. Las alertas se envían una vez al día por cada tipo.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
