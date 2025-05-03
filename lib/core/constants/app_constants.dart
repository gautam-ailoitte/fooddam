// lib/core/constants/app_constants.dart
import 'package:flutter/foundation.dart';

class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.foodam.mithilastack.com/';
  static const bool useMockData = false;
  static const String googleMapKey = 'AIzaSyC6-HTk9TbnPmFXO1ZiVgCwnUSTDL2hSFM';
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

  // Auth Endpoints
  static const String registerMobileEndpoint = '/api/auth/register';
  static const String verifyMobileEndpoint = '/api/auth/verify-mobile';
  static const String verifyOtpEndpoint = '/api/auth/verify-otp';
  static const String forgotPasswordEndpoint = '/api/auth/forgot-password';
  static const String resetPasswordEndpoint = '/api/auth/reset-password';

  static const String refreshTokenEndpoint = '/api/auth/refresh-token';
  static const String validateTokenEndpoint = '/api/auth/validate-token';

  // Meal Endpoints
  static const String mealsEndpoint = '/api/meals';
  static const String dishesEndpoint = '/api/dishes';

  // User Address Endpoints
  static const String addressesEndpoint = '/api/addresses';

  // Payment Endpoints
  static const String paymentsEndpoint = '/api/payments';

  // Max Items
  static const int maxAddresses = 5;
  static const int maxActiveSubscriptions = 3;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int otpLength = 6;
  static const int phoneNumberLength = 10;

  // Features
  static const bool enableDemoLogin = kDebugMode;
  static const bool enableMobileLogin = true;
  static const bool enableEmailVerification = true;

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
  static const List<String> mealTimings = ['breakfast', 'lunch', 'dinner'];

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

  static var appVersion = 1;

  static var buildNumber = 1;
}
