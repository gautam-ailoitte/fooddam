// lib/core/route/app_router.dart (UPDATED - Add Orders Routes)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/order_entity.dart'; // NEW
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/entities/package_slot_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/screens/auth/forgot_password_screen.dart';
import 'package:foodam/src/presentation/screens/auth/login_screen.dart';
import 'package:foodam/src/presentation/screens/auth/registration_screen.dart';
import 'package:foodam/src/presentation/screens/auth/rest_password_screen.dart';
import 'package:foodam/src/presentation/screens/auth/verify_otp_screen.dart';
import 'package:foodam/src/presentation/screens/checkout/chekout_screen.dart';
import 'package:foodam/src/presentation/screens/checkout/confirmation_screen.dart';
import 'package:foodam/src/presentation/screens/home/home_screen.dart';
import 'package:foodam/src/presentation/screens/meal_selection/meal_selection_scree.dart';
import 'package:foodam/src/presentation/screens/nav/main_screen.dart';
import 'package:foodam/src/presentation/screens/orders/meal_detail_screen.dart'; // NEW
import 'package:foodam/src/presentation/screens/orders/orders_screen.dart'; // NEW
import 'package:foodam/src/presentation/screens/package/daily_meal_detail_screen.dart';
import 'package:foodam/src/presentation/screens/package/dish_detail_screen.dart';
import 'package:foodam/src/presentation/screens/package/pacakge_screen.dart';
import 'package:foodam/src/presentation/screens/package/package_detaill_screen.dart';
import 'package:foodam/src/presentation/screens/profile/address_screen.dart';
import 'package:foodam/src/presentation/screens/profile/profile_completion_screen.dart';
import 'package:foodam/src/presentation/screens/profile/profile_screen.dart';
import 'package:foodam/src/presentation/screens/splash/onboarding_screen.dart';
import 'package:foodam/src/presentation/screens/splash/splash_screen.dart';
import 'package:foodam/src/presentation/screens/susbs/create_subscription/start_subscription_planning_screen.dart';
import 'package:foodam/src/presentation/screens/susbs/create_subscription/week_selection_flow_screen.dart';
import 'package:foodam/src/presentation/screens/susbs/subscription_detail_screen.dart';
import 'package:foodam/src/presentation/screens/susbs/subscription_meal_schedule_screen.dart';
import 'package:foodam/src/presentation/screens/susbs/subscription_screen.dart';

import '../../src/presentation/screens/susbs/create_subscription/subscription_summary_screen.dart';
import '../../src/presentation/screens/susbs/meal_detail_screen.dart';

class AppRouter {
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String mainRoute = '/main';
  static const String homeRoute = '/home';

  // Order routes - NEW
  static const String ordersRoute = '/orders';
  static const String orderMealDetailRoute = '/order-meal-detail';

  // Subscription routes - UPDATED for better flow
  static const String subscriptionsRoute = '/subscriptions';
  static const String subscriptionDetailRoute = '/subscription-detail';
  static const String subscriptionMealScheduleRoute =
      '/subscription-meal-schedule';
  static const String mealDetailRoute = '/meal-detail';

  // Subscription creation flow - UPDATED
  static const String startSubscriptionPlanningRoute =
      '/start-subscription-planning';
  static const String weekSelectionFlowRoute = '/week-selection-flow';
  static const String subscriptionSummaryRoute = '/subscription-summary';

  // Package routes
  static const String packagesRoute = '/packages';
  static const String packageDetailRoute = '/package-detail';
  static const String dailyMealDetailRoute = '/daily-meal-detail';
  static const String dishDetailRoute = '/dish-detail';

  // Meal selection and checkout
  static const String mealSelectionRoute = '/meal-selection';
  static const String checkoutRoute = '/checkout';
  static const String confirmationRoute = '/confirmation';

  // Profile routes
  static const String profileRoute = '/profile';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String resetPasswordRoute = '/reset-password';
  static const String verifyOtpRoute = '/verify-otp';
  static const String profileCompletionRoute = '/profile-completion';
  static const String addAddressRoute = '/add-address';

  // Legacy order routes (for backward compatibility)
  static const String todayOrdersRoute = '/today-orders';
  static const String upcomingOrdersRoute = '/upcoming-orders';
  static const String orderHistoryRoute = '/order-history';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case initialRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return MainScreen();
                  } else {
                    return LoginScreen();
                  }
                },
              ),
        );

      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case resetPasswordRoute:
        final email = settings.arguments as String?;
        if (email == null) {
          return _errorRoute(settings);
        }
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email),
        );

      case verifyOtpRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final mobile = args?['mobile'] as String?;
        final isRegistration = args?['isRegistration'] as bool? ?? true;

        if (mobile == null) {
          return _errorRoute(settings);
        }

        return MaterialPageRoute(
          builder:
              (_) => VerifyOTPScreen(
                mobileNumber: mobile,
                isRegistration: isRegistration,
              ),
        );

      case profileCompletionRoute:
        if (settings.arguments is User) {
          return MaterialPageRoute(
            builder:
                (_) =>
                    ProfileCompletionScreen(user: settings.arguments as User),
          );
        }
        return _errorRoute(settings);

      case mainRoute:
        return MaterialPageRoute(
          builder: (_) => MainScreen(key: MainScreenController.key),
        );

      case homeRoute:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      // NEW: Order routes
      case ordersRoute:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());

      case orderMealDetailRoute:
        final order = settings.arguments as Order?;
        if (order == null) {
          return _errorRoute(settings);
        }
        return MaterialPageRoute(
          builder: (_) => OrderMealDetailScreen(order: order),
        );

      // Subscription routes
      case subscriptionsRoute:
        return MaterialPageRoute(builder: (_) => const SubscriptionsScreen());

      case subscriptionDetailRoute:
        final subscription = settings.arguments as Subscription?;
        if (subscription == null) {
          return _errorRoute(settings);
        }
        return MaterialPageRoute(
          builder: (_) => SubscriptionDetailScreen(subscription: subscription),
        );

      case subscriptionMealScheduleRoute:
        final subscription = settings.arguments as Subscription?;
        if (subscription == null) {
          return _errorRoute(settings);
        }
        return MaterialPageRoute(
          builder:
              (_) => SubscriptionMealScheduleScreen(subscription: subscription),
        );

      case mealDetailRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final meal = args?['meal'];
        final timing = args?['timing'] as String?;
        final date = args?['date'] as DateTime?;
        final subscription = args?['subscription'];

        if (meal == null ||
            timing == null ||
            date == null ||
            subscription == null) {
          return _errorRoute(settings);
        }

        return MaterialPageRoute(
          builder:
              (_) => MealDetailScreen(
                meal: meal,
                timing: timing,
                date: date,
                subscription: subscription,
              ),
        );

      // UPDATED: Subscription creation flow with proper navigation
      case startSubscriptionPlanningRoute:
        return _createSubscriptionRoute(
          (_) => const StartSubscriptionPlanningScreen(),
          settings,
        );

      case weekSelectionFlowRoute:
        return _createSubscriptionRoute(
          (_) => const WeekSelectionFlowScreen(),
          settings,
        );

      case subscriptionSummaryRoute:
        return _createSubscriptionRoute(
          (_) => const SubscriptionSummaryScreen(),
          settings,
        );

      // Package routes
      case packagesRoute:
        return MaterialPageRoute(builder: (_) => PackagesScreen());

      case packageDetailRoute:
        final package = settings.arguments as Package?;
        if (package == null) {
          return _errorRoute(settings);
        }
        return MaterialPageRoute(
          builder: (_) => PackageDetailScreen(package: package),
        );

      case dailyMealDetailRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final slot = args?['slot'] as PackageSlot?;
        final package = args?['package'] as Package?;

        if (slot == null || package == null) {
          return _errorRoute(settings);
        }

        return MaterialPageRoute(
          builder: (_) => DailyMealDetailScreen(slot: slot, package: package),
        );

      case dishDetailRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final dish = args?['dish'] as Dish?;
        final mealType = args?['mealType'] as String?;
        final package = args?['package'] as Package?;
        final day = args?['day'] as String?;

        if (dish == null ||
            mealType == null ||
            package == null ||
            day == null) {
          return _errorRoute(settings);
        }

        return MaterialPageRoute(
          builder:
              (_) => DishDetailScreen(
                dish: dish,
                mealType: mealType,
                package: package,
                day: day,
              ),
        );

      case mealSelectionRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return _createErrorRoute(
            'Missing meal selection data',
            'Please go back and select a package first',
          );
        }
        return MaterialPageRoute(builder: (_) => const MealSelectionScreen());

      case checkoutRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return _createErrorRoute(
            'Missing checkout data',
            'Please start over from package selection',
          );
        }
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());

      case confirmationRoute:
        final subscription = settings.arguments as Subscription?;
        if (subscription == null) {
          return _errorRoute(settings);
        }
        return MaterialPageRoute(
          builder: (_) => ConfirmationScreen(subscription: subscription),
        );

      case addAddressRoute:
        if (settings.arguments is Address) {
          return MaterialPageRoute(
            builder:
                (_) => AddAddressScreen(address: settings.arguments as Address),
          );
        }
        return MaterialPageRoute(builder: (_) => const AddAddressScreen());

      case profileRoute:
        return MaterialPageRoute(builder: (_) => ProfileScreen());

      default:
        return _errorRoute(settings);
    }
  }

  /// Create subscription flow route with proper navigation management
  static Route<dynamic> _createSubscriptionRoute(
    Widget Function(BuildContext) builder,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Smooth slide transition for subscription flow
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }

  /// Create error route with custom message
  static Route<dynamic> _createErrorRoute(String title, String message) {
    return MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            initialRoute,
                            (route) => false,
                          ),
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Route Error',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No route defined for ${settings.name}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            initialRoute,
                            (route) => false,
                          ),
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // NEW: Navigation helpers for orders

  /// Navigate to orders screen
  static Future<void> navigateToOrders(BuildContext context) {
    return Navigator.pushNamed(context, ordersRoute);
  }

  /// Navigate to order meal detail
  static Future<void> navigateToOrderMealDetail(
    BuildContext context,
    Order order,
  ) {
    return Navigator.pushNamed(context, orderMealDetailRoute, arguments: order);
  }

  // UPDATED: Navigation helpers for subscription flow

  /// Navigate to subscription planning (entry point)
  static Future<void> startSubscriptionPlanning(BuildContext context) {
    return Navigator.pushNamed(context, startSubscriptionPlanningRoute);
  }

  /// Navigate within subscription flow (uses replacement to prevent stack buildup)
  static Future<void> navigateInSubscriptionFlow(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Exit subscription flow and return to main app
  static void exitSubscriptionFlow(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, mainRoute, (route) => false);
  }

  /// Navigate back in subscription flow
  static void navigateBackInSubscriptionFlow(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  /// Complete subscription flow and navigate to confirmation
  static Future<void> completeSubscriptionFlow(
    BuildContext context,
    Subscription subscription,
  ) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      confirmationRoute,
      (route) => route.settings.name == mainRoute,
      arguments: subscription,
    );
  }

  /// Navigate to subscription list
  static Future<void> navigateToSubscriptions(BuildContext context) {
    return Navigator.pushNamed(context, subscriptionsRoute);
  }

  /// Navigate to subscription detail
  static Future<void> navigateToSubscriptionDetail(
    BuildContext context,
    Subscription subscription,
  ) {
    return Navigator.pushNamed(
      context,
      subscriptionDetailRoute,
      arguments: subscription,
    );
  }

  /// Navigate to package detail
  static Future<void> navigateToPackageDetail(
    BuildContext context,
    Package package,
  ) {
    return Navigator.pushNamed(context, packageDetailRoute, arguments: package);
  }

  /// Navigate to meal detail
  static Future<void> navigateToMealDetail(
    BuildContext context, {
    required dynamic meal,
    required String timing,
    required DateTime date,
    required dynamic subscription,
  }) {
    return Navigator.pushNamed(
      context,
      mealDetailRoute,
      arguments: {
        'meal': meal,
        'timing': timing,
        'date': date,
        'subscription': subscription,
      },
    );
  }

  /// Navigate to dish detail
  static Future<void> navigateToDishDetail(
    BuildContext context, {
    required Dish dish,
    required String mealType,
    required Package package,
    required String day,
  }) {
    return Navigator.pushNamed(
      context,
      dishDetailRoute,
      arguments: {
        'dish': dish,
        'mealType': mealType,
        'package': package,
        'day': day,
      },
    );
  }

  /// Check if current route is part of subscription flow
  static bool isSubscriptionFlowRoute(String? routeName) {
    return [
      startSubscriptionPlanningRoute,
      weekSelectionFlowRoute,
      subscriptionSummaryRoute,
      checkoutRoute,
    ].contains(routeName);
  }

  /// Get previous route in subscription flow
  static String? getPreviousSubscriptionRoute(String currentRoute) {
    switch (currentRoute) {
      case weekSelectionFlowRoute:
        return startSubscriptionPlanningRoute;
      case subscriptionSummaryRoute:
        return weekSelectionFlowRoute;
      case checkoutRoute:
        return subscriptionSummaryRoute;
      default:
        return null;
    }
  }

  /// Get next route in subscription flow
  static String? getNextSubscriptionRoute(String currentRoute) {
    switch (currentRoute) {
      case startSubscriptionPlanningRoute:
        return weekSelectionFlowRoute;
      case weekSelectionFlowRoute:
        return subscriptionSummaryRoute;
      case subscriptionSummaryRoute:
        return checkoutRoute;
      default:
        return null;
    }
  }
}
