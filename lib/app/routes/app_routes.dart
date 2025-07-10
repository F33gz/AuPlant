/// Application Routes
/// 
/// Centralized route name definitions for the AuPlant IoT application.
/// All route names used throughout the app should be defined here to maintain
/// consistency and prevent typos.
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Root route
  static const String root = '/';

  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Plant routes
  static const String plantsOverview = '/plants';
  static const String plantDetail = '/plant-detail';
  static const String addPlant = '/add-plant';
  static const String plantSettings = '/plant-settings';

  // Settings routes
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String about = '/about';

  // Debug routes (only available in debug mode)
  static const String debug = '/debug';
  static const String deviceInfo = '/device-info';
}
