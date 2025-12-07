/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'AuPlant';
  static const String appDescription = 'Cuida tus plantas de forma inteligente';
  static const String appVersion = '1.0.0';
  
  // Default Values
  static const String defaultPlantEmoji = '🌱';
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPlantNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const String cacheKeyPrefix = 'auplant_';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
}
