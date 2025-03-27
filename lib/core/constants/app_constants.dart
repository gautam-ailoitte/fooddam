// lib/core/constants/app_constants.dart
import 'package:flutter/foundation.dart';

class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.foodam.mithilastack.com/';
  static const bool useMockData = false;
  
  // Storage Keys
  static const String tokenKey = 'AUTH_TOKEN';
  static const String refreshTokenKey = 'REFRESH_TOKEN';
  static const String userKey = 'USER_DATA';
  
  // App settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const bool isDevelopment = kDebugMode;
  
  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String currentUserEndpoint = '/api/auth/me';
  static const String packagesEndpoint = '/api/subscriptions/packages';
  static const String subscriptionsEndpoint = '/api/subscriptions';
  static const String subscribeEndpoint = '/api/subscriptions/subscribe';
  
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
  
  // Meal Types Display Names
  static const Map<String, String> mealTypeNames = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
  };
  
  // Day Display Names
  static const Map<String, String> dayNames = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
  };
  
  // Subscription Status
  static const Map<String, String> subscriptionStatusNames = {
    'pending': 'Pending',
    'active': 'Active',
    'paused': 'Paused',
    'cancelled': 'Cancelled',
    'expired': 'Expired',
  };
  
  // Demo credentials
  static const String demoEmail = 'prince@gmail.com';
  static const String demoPassword = 'Prince@2002';

  static var appVersion=1;

  static var buildNumber=1;
}
