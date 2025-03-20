// lib/core/route/app_router.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/service/navigation_service.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';
import 'package:foodam/src/presentation/screens/auth/login_screen.dart';
import 'package:foodam/src/presentation/screens/home/home_screen.dart';
import 'package:foodam/src/presentation/screens/payment/payment_screen.dart';
import 'package:foodam/src/presentation/screens/splash/splash_screen.dart';
import 'package:foodam/src/presentation/screens/subscription/meal_distributation_screen.dart';
import 'package:foodam/src/presentation/screens/subscription/plan_duration_selection_screen.dart';
import 'package:foodam/src/presentation/screens/subscription/plan_selection_screen.dart';
import 'package:foodam/src/presentation/screens/subscription/thali_selection_screen.dart';
// Enum to categorize routes for appropriate transitions
  enum RouteType {
    fade,
    slideRight,
    slideUp,
    slideDown,
    scale,
    material
  }
class AppRouter {
  // Route observer for analytics
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  static final LoggerService _logger = LoggerService();

  

  // Route names mapped to their transition types
  static final Map<String, RouteType> _routeTransitionTypes = {
    AppRoutes.splash: RouteType.fade,
    AppRoutes.login: RouteType.fade,
    AppRoutes.home: RouteType.fade,
    AppRoutes.planSelection: RouteType.slideRight,
    AppRoutes.planDetails: RouteType.slideRight,
    AppRoutes.planDuration: RouteType.slideRight,
    AppRoutes.mealDistribution: RouteType.slideRight,
    AppRoutes.thaliSelection: RouteType.slideRight,
    AppRoutes.paymentSummary: RouteType.slideUp,
    AppRoutes.activePlan: RouteType.slideRight,
    AppRoutes.pauseSubscription: RouteType.slideUp,
    // Default is material transition
  };

  // Main route generation method
  static Route<dynamic> generateRoute(RouteSettings settings) {
    _logger.i('Navigating to: ${settings.name}', tag: 'ROUTER');
    
    // Extract route arguments if available
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    try {
      switch (settings.name) {
        // Auth Routes
        case AppRoutes.splash:
          return _buildRoute(settings, const SplashScreen());
        case AppRoutes.login:
          return _buildRoute(settings, const LoginScreen());
          
        // Main App Routes
        case AppRoutes.home:
          return _buildRoute(settings, const HomeScreen());
          
        // Plan Selection Flow
        case AppRoutes.planSelection:
          return _buildRoute(settings, const PlanSelectionScreen());
        case AppRoutes.planDetails:
          final plan = args['plan'] as SubscriptionPlan?;
          if (plan == null) {
            _logger.e('Plan not provided for details screen', tag: 'ROUTER');
            return _buildErrorRoute(
              settings, 
              'Missing plan details. Please select a plan first.'
            );
          }
          return _buildRoute(settings, PlanDetailsScreen(plan: plan));
        case AppRoutes.planDuration:
          return _buildRoute(settings, const PlanDurationScreen());
        case AppRoutes.mealDistribution:
          return _buildRoute(settings, const MealDistributionScreen());
        case AppRoutes.thaliSelection:
          return _buildRoute(settings, const ThaliSelectionScreen());
        case AppRoutes.paymentSummary:
          return _buildRoute(settings, const PaymentSummaryScreen());

        // Active Subscription Routes
        case AppRoutes.activePlan:
          final subscription = args['subscription'] as Subscription?;
          if (subscription == null) {
            _logger.e('Subscription not provided for details screen', tag: 'ROUTER');
            return _buildErrorRoute(
              settings, 
              'Subscription not found. Please try again.'
            );
          }
          return _buildRoute(settings, ActivePlanScreen(subscription: subscription));
        case AppRoutes.pauseSubscription:
          final subscriptionId = args['subscriptionId'] as String?;
          if (subscriptionId == null) {
            _logger.e('SubscriptionId not provided for pause screen', tag: 'ROUTER');
            return _buildErrorRoute(
              settings, 
              'Subscription details missing. Please try again.'
            );
          }
          return _buildRoute(settings, PauseSubscriptionScreen(subscriptionId: subscriptionId));
          
        // Maintenance route (temporary route when features are under development)
        case AppRoutes.maintenance:
          return _buildRoute(settings, const MaintenanceScreen());

        // Default case for unknown routes
        default:
          _logger.w('Route not found: ${settings.name}', tag: 'ROUTER');
          return _buildRoute(
            settings,
            NotFoundScreen(
              routeName: settings.name ?? 'Unknown',
            ),
          );
      }
    } catch (e, stackTrace) {
      // Log and handle any unexpected errors during routing
      _logger.e(
        'Error during routing to ${settings.name}', 
        error: e, 
        stackTrace: stackTrace,
        tag: 'ROUTER'
      );
      
      return _buildRoute(
        settings,
        ErrorScreen(
          routeName: settings.name ?? 'Unknown',
          error: e.toString(),
        ),
      );
    }
  }

  // Helper method to build routes with appropriate transitions
  static Route<dynamic> _buildRoute(RouteSettings settings, Widget page) {
    final routeType = _routeTransitionTypes[settings.name] ?? RouteType.material;
    
    switch (routeType) {
      case RouteType.fade:
        return _buildFadeRoute(settings, page);
      case RouteType.slideRight:
        return _buildSlideRightRoute(settings, page);
      case RouteType.slideUp:
        return _buildSlideUpRoute(settings, page);
      case RouteType.slideDown:
        return _buildSlideDownRoute(settings, page);
      case RouteType.scale:
        return _buildScaleRoute(settings, page);
      case RouteType.material:
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => page,
        );
    }
  }

  // Helper to build error routes
  static Route<dynamic> _buildErrorRoute(RouteSettings settings, String message) {
    _logger.w('Building error route: $message', tag: 'ROUTER');
    
    return _buildFadeRoute(
      settings,
      ErrorScreen(
        routeName: settings.name ?? 'Unknown',
        error: message,
      ),
    );
  }

  // Custom transition animations
  static Route<dynamic> _buildFadeRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<dynamic> _buildSlideRightRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static Route<dynamic> _buildSlideUpRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuint;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static Route<dynamic> _buildSlideDownRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuint;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static Route<dynamic> _buildScaleRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeOutExpo;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);
        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}

// Generic Error Screen for unexpected errors
class ErrorScreen extends StatelessWidget {
  final String routeName;
  final String error;
  
  const ErrorScreen({
    super.key, 
    required this.routeName, 
    required this.error
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Error"),
        backgroundColor: Colors.red[900],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'An error occurred',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Route: $routeName',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 36),
                ElevatedButton.icon(
                  onPressed: () {
                    NavigationService.pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Return to Home'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Not Found Screen for unknown routes
class NotFoundScreen extends StatelessWidget {
  final String routeName;
  
  const NotFoundScreen({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(StringConstants.routeNotFound)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.question_mark,
                  color: Colors.amber,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  '404 - Page Not Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The route "$routeName" could not be found.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 36),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    NavigationService.pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Maintenance Screen
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction,
                  size: 80,
                  color: Colors.amber[700],
                ),
                const SizedBox(height: 24),
                Text(
                  'Under Maintenance',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'re making this feature even better! Please check back soon.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder screens for routes that are referenced but not fully implemented
class PlanDetailsScreen extends StatelessWidget {
  final SubscriptionPlan plan;
  
  const PlanDetailsScreen({super.key, required this.plan});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plan Details: ${plan.name}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              'Plan Details Screen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'This screen is under development',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivePlanScreen extends StatelessWidget {
  final Subscription subscription;
  
  const ActivePlanScreen({super.key, required this.subscription});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Active Plan: ${subscription.subscriptionPlan.name}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              'Active Plan Screen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'This screen is under development',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class PauseSubscriptionScreen extends StatelessWidget {
  final String subscriptionId;
  
  const PauseSubscriptionScreen({super.key, required this.subscriptionId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pause Subscription')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              'Pause Subscription Screen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'This screen is under development',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// TO DO (Future Improvements):
// 1. Implement remaining screens:
//    - Profile Screen
//    - Edit Profile Screen
//    - Address Management Screens
//    - Order Details Screen
//    - Payment History Screen
//    - Meal Customization Screen
// 2. Add deep linking support
// 3. Implement route history tracking for analytics
// 4. Add route guards for authenticated routes
// 5. Implement route-specific animations based on navigation direction