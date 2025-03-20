// lib/core/constants/app_route_constant.dart
class AppRoutes {
  // Auth routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main app routes
  static const String home = '/';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String addresses = '/addresses';
  static const String editAddress = '/edit-address';
  
  // Plan selection flow
  static const String planSelection = '/plan-selection';
  static const String planDetails = '/plan-details';
  static const String planDuration = '/plan-duration';
  static const String mealDistribution = '/meal-distribution';
  static const String thaliSelection = '/thali-selection';
  static const String mealCustomization = '/meal-customization';
  static const String paymentSummary = '/payment-summary';
  static const String paymentSuccess = '/payment-success';
  
  // Active subscription routes
  static const String activePlan = '/active-plan';
  static const String pauseSubscription = '/pause-subscription';
  static const String activeOrderDetails = '/active-order-details';
  
  // History routes
  static const String orderHistory = '/order-history';
  static const String paymentHistory = '/payment-history';
  static const String orderDetails = '/order-details';
  
  // Support routes
  static const String support = '/support';
  static const String helpCenter = '/help-center';
  static const String faqs = '/faqs';
  
  // Error routes
  static const String notFound = '/not-found';
  static const String maintenance = '/maintenance';
}