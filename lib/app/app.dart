import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'theme/app_theme.dart';
import 'routes/route_generator.dart';
import 'routes/app_routes.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

/// Main Application Widget
/// 
/// The root widget of the AuPlant IoT application that configures
/// the MaterialApp with theme, routing, and other global settings.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuPlant IoT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.root,
      onGenerateRoute: RouteGenerator.generateRoute,
      navigatorObservers: [routeObserver],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0), // Prevent text scaling
          ),
          child: child!,
        );
      },
    );
  }
}
