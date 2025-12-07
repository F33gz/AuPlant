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

  // Station routes (greenhouse monitoring stations)
  static const String stationsOverview = '/stations';
  static const String stationDetail = '/station-detail';
  static const String addStation = '/add-station';
  static const String stationSettings = '/station-settings';

  // Legacy plant routes - redirects to station routes
  @Deprecated('Use stationsOverview instead')
  static const String plantsOverview = '/stations';
  @Deprecated('Use stationDetail instead')
  static const String plantDetail = '/station-detail';
  @Deprecated('Use addStation instead')
  static const String addPlant = '/add-station';
  @Deprecated('Use stationSettings instead')
  static const String plantSettings = '/station-settings';

  // Settings routes
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';
  static const String about = '/about';

  // Debug routes (only available in debug mode)
  static const String debug = '/debug';
  static const String deviceInfo = '/device-info';
}
