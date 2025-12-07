import 'package:flutter/material.dart';
import 'core/di/dependency_injection.dart';
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
  
  runApp(const App());
}

