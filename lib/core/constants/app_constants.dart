class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.foodam.com';
  
  // Storage Keys
  static const String tokenKey = 'AUTH_TOKEN';
  static const String userKey = 'USER_DATA';
  
  // App settings
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Days of the week
  static const List<String> weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  
  // Meal timings
  static const List<String> mealTimings = [
    'breakfast',
    'lunch',
    'dinner',
  ];
}