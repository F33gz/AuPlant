import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'core/di/dependency_injection.dart';
import 'core/network/thingsboard_api_client.dart';
import 'core/services/telemetry_monitor_service.dart';
import 'app/app.dart';
import 'app/theme/theme_controller.dart';
import 'shared/utils/notifications_service.dart';

/// AuPlant IoT - Greenhouse Monitoring App
/// 
/// Using ThingsBoard for IoT platform instead of Supabase.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection (includes ThingsBoard client)
  await initializeDependencies();
  
  // Load theme preference
  await ThemeController.instance.load();
  
  // Initialize local notifications service
  await NotificationsService.instance.initialize();
  
  // Start telemetry monitoring if authenticated
  _initTelemetryMonitor();
  
  runApp(const App());
}

/// Inicializa el monitor de telemetría si hay sesión activa
Future<void> _initTelemetryMonitor() async {
  try {
    final sl = GetIt.instance;
    if (sl.isRegistered<ThingsBoardApiClient>()) {
      final apiClient = sl<ThingsBoardApiClient>();
      final isAuthenticated = await apiClient.isAuthenticated();
      if (isAuthenticated) {
        await TelemetryMonitorService.instance.start();
      }
    }
  } catch (e) {
    // Ignorar errores de inicialización
  }
}

