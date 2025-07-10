import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_routes.dart';
import '../../features/main/presentation/pages/main_page.dart';
import '../../features/plants/presentation/pages/plants_overview_page.dart';
import '../../features/plants/presentation/pages/plant_detail_page.dart';
import '../../features/plants/presentation/pages/add_plant_page.dart';
import '../../features/plants/presentation/pages/plant_settings_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/monitoring/presentation/pages/monitoring_dashboard_page.dart';
import '../../core/models/plant_model.dart';

/// Route Generator
/// 
/// Centralized route generation logic for the AuPlant IoT application.
/// Handles navigation between different screens and passes arguments
/// where necessary.
class RouteGenerator {
  // Private constructor to prevent instantiation
  RouteGenerator._();

  /// Generates routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.root:
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return MaterialPageRoute(
            builder: (_) => const MainPage(),
            settings: settings,
          );
        } else {
          return MaterialPageRoute(
            builder: (_) => const LoginPage(),
            settings: settings,
          );
        }

      case AppRoutes.plantsOverview:
        return MaterialPageRoute(
          builder: (_) => const PlantsOverviewPage(),
          settings: settings,
        );

      case AppRoutes.plantDetail:
        final args = settings.arguments;
        if (args is PlantModel) {
          return MaterialPageRoute(
            builder: (_) => PlantDetailPage(plant: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);

      case AppRoutes.addPlant:
        return MaterialPageRoute(
          builder: (_) => const AddPlantPage(),
          settings: settings,
        );

      case AppRoutes.plantSettings:
        final args = settings.arguments;
        if (args is PlantModel) {
          return MaterialPageRoute(
            builder: (_) => PlantSettingsPage(plant: args),
            settings: settings,
          );
        }
        return _errorRoute(settings);

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupPage(),
          settings: settings,
        );

      default:
        return _errorRoute(settings);
    }
  }

  /// Creates an error route for unknown routes
  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Página no encontrada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Ruta: ${settings.name}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.plantsOverview,
                  (route) => false,
                ),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }

  /// Pre-defined route transitions
  static Route<dynamic> slideTransition(
    Widget page,
    RouteSettings settings, {
    Offset beginOffset = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        final tween = Tween(
          begin: beginOffset,
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Fade transition
  static Route<dynamic> fadeTransition(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Scale transition
  static Route<dynamic> scaleTransition(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        final tween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
