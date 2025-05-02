// lib/core/constants/app_config.dart
class AppConfig {
  // API Keys - Replace these with your actual keys
  static const String razorpayKeyTest = 'rzp_test_YOUR_TEST_KEY_HERE';
  static const String razorpayKeyLive = 'rzp_live_YOUR_LIVE_KEY_HERE';

  // Use this to switch between test and production keys
  static String get razorpayKey {
    // Use test key for debug mode, live key for production
    const bool isProduction = false; // Change this based on your environment
    return isProduction ? razorpayKeyLive : razorpayKeyTest;
  }
}
