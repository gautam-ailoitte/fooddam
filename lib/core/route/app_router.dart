// lib/core/route/app_router.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/service/navigation_service.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';
import 'package:foodam/src/presentation/screens/auth/login_screen.dart';
import 'package:foodam/src/presentation/screens/home/home_screen.dart';
import 'package:foodam/src/presentation/screens/payment/payment_screen.dart';
import 'package:foodam/src/presentation/screens/splash/splash_screen.dart';
import 'package:foodam/src/presentation/screens/subscription/meal_distributation_screen.dart';
import 'package:foodam/src/presentation/screens/subscription/plan_duration_selection_screen.dart';
import 'package:foodam/src/presentation/screens/subscription/plan_selection_screen.dart';

class AppRouter {
  // Route observer for analytics
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  // Main route generation method
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract route arguments if available
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    switch (settings.name) {
      // Auth Routes
      case AppRoutes.splash:
        return _buildRoute(settings, const SplashScreen());
      case AppRoutes.login:
        return _buildRoute(settings, const LoginScreen());
      // case AppRoutes.register:
      //   return _buildRoute(settings, const RegisterScreen());
      // case AppRoutes.forgotPassword:
      //   return _buildRoute(settings, const ForgotPasswordScreen());

      // Main App Routes
      case AppRoutes.home:
        return _buildRoute(settings, const HomeScreen());
      // case AppRoutes.profile:
      //   return _buildRoute(settings, const ProfileScreen());
      // case AppRoutes.editProfile:
      //   return _buildRoute(settings, const EditProfileScreen());
      // case AppRoutes.addresses:
      //   return _buildRoute(settings, const AddressListScreen());
      // case AppRoutes.editAddress:
      //   final addressId = args['addressId'] as String?;
      //   return _buildRoute(settings, EditAddressScreen(addressId: addressId));

      // Plan Selection Flow
      case AppRoutes.planSelection:
        return _buildRoute(settings, const PlanSelectionScreen());
      // case AppRoutes.planDetails:
      //   final planId = args['planId'] as String?;
      //   return _buildRoute(settings, PlanDetailsScreen(planId: planId));
      case AppRoutes.planDuration:
        return _buildRoute(settings, const PlanDurationScreen());
      case AppRoutes.mealDistribution:
        return _buildRoute(settings, const MealDistributionScreen());
      case AppRoutes.thaliSelection:
        return _buildRoute(settings, const ThaliSelectionScreen());
      // case AppRoutes.mealCustomization:
      //   final meal = args['meal'] as Meal?;
      //   final mealType = args['mealType'] as String?;
      //   final date = args['date'] as DateTime?;
        
      //   if (meal == null || mealType == null || date == null) {
      //     return _buildErrorRoute(settings, 'Invalid meal customization parameters');
      //   }
        
       
        
      //   return _buildRoute(
      //     settings, 
      //     MealCustomizationScreen(
      //       meal: meal,
      //       mealType: mealType,
      //       date: date,
      //     )
      //   );
      case AppRoutes.paymentSummary:
        return _buildRoute(settings, const PaymentSummaryScreen());
      // case AppRoutes.paymentSuccess:
      //   return _buildRoute(settings, const PaymentSuccessScreen());

      // Active Subscription Routes
      case AppRoutes.activePlan:
        final subscription = args['subscription'] as Subscription?;
        
        if (subscription == null) {
          return _buildErrorRoute(settings, 'Subscription not found');
        }
        
        // return _buildRoute(
        //   settings, 
        //   ActivePlanScreen(subscription: subscription)
        // );
      case AppRoutes.pauseSubscription:
        final subscriptionId = args['subscriptionId'] as String?;
        
        if (subscriptionId == null) {
          return _buildErrorRoute(settings, 'Subscription ID not provided');
        }
        
        // return _buildRoute(
        //   settings, 
        //   PauseSubscriptionScreen(subscriptionId: subscriptionId)
        // );
      // case AppRoutes.activeOrderDetails:
      //   final orderId = args['orderId'] as String?;
      //   return _buildRoute(settings, OrderDetailsScreen(orderId: orderId));

      // History Routes
      // case AppRoutes.orderHistory:
      //   return _buildRoute(settings, const OrderHistoryScreen());
      // case AppRoutes.paymentHistory:
      //   return _buildRoute(settings, const PaymentHistoryScreen());
      // case AppRoutes.orderDetails:
      //   final orderId = args['orderId'] as String?;
      //   return _buildRoute(settings, OrderDetailsScreen(orderId: orderId));

      // // Support Routes
          // const NotFoundScreen(),
      //   return _buildRoute(settings, const HelpCenterScreen());
      // case AppRoutes.faqs:
      //   return _buildRoute(settings, const FAQsScreen());

      // // Error Routes
      // case AppRoutes.notFound:
      //   return _buildRoute(settings, const NotFoundScreen());
      case AppRoutes.maintenance:
        return _buildRoute(settings, MaintenanceScreen());

      // Default case for unknown routes
      default:
        return _buildRoute(
          settings,
          NotFoundScreen(
            routeName: settings.name ?? 'Unknown',
          ),
        );
    }
  }

  // Helper method to build routes with consistent transitions
  static Route<dynamic> _buildRoute(RouteSettings settings, Widget page) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => page,
    );
  }

  // Helper to build error routes
  static Route<dynamic> _buildErrorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(StringConstants.routeNotFound)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => NavigationService.pop(),
                child: Text(StringConstants.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom transition animations
  static Route<dynamic> _buildSlideUpRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static Route<dynamic> _buildFadeRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

// Placeholder for screens not yet created
// class PlanDetailsScreen extends StatelessWidget {
//   final String? planId;
  
//   const PlanDetailsScreen({super.key, this.planId});
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Plan Details')),
//       body: Center(child: Text('Plan Details: $planId')),
//     );
//   }
// }

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.build, size: 64),
            SizedBox(height: 16),
            Text(
              'Under Maintenance',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We\'ll be back soon!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} class NotFoundScreen extends StatelessWidget {
          const NotFoundScreen({super.key, required String routeName});
        
          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(title: const Text('Page Not Found')),
              body: const Center(
                child: Text(
                  '404 - Page Not Found',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            );
          }
        }