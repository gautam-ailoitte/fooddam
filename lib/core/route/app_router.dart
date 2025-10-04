// lib/core/route/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/screens/auth/forgot_password_screen.dart';
import 'package:foodam/src/presentation/screens/auth/login_screen.dart';
import 'package:foodam/src/presentation/screens/auth/registration_screen.dart';
import 'package:foodam/src/presentation/screens/auth/rest_password_screen.dart';
import 'package:foodam/src/presentation/screens/auth/verify_otp_screen.dart';
import 'package:foodam/src/presentation/screens/checkout/confirmation_screen.dart';
import 'package:foodam/src/presentation/screens/home/home_screen.dart';
import 'package:foodam/src/presentation/screens/meal_planning/start_meal_planning_screen.dart';
import 'package:foodam/src/presentation/screens/meal_planning/subscription_summary_screen.dart';
import 'package:foodam/src/presentation/screens/meal_planning/week_grid_screen.dart';
import 'package:foodam/src/presentation/screens/nav/main_screen.dart';
import 'package:foodam/src/presentation/screens/orders/orders_screen.dart';
import 'package:foodam/src/presentation/screens/package/pacakge_screen.dart';
import 'package:foodam/src/presentation/screens/package/package_detaill_screen.dart';
import 'package:foodam/src/presentation/screens/profile/address_screen.dart';
import 'package:foodam/src/presentation/screens/profile/profile_completion_screen.dart';
import 'package:foodam/src/presentation/screens/profile/profile_screen.dart';
import 'package:foodam/src/presentation/screens/splash/onboarding_screen.dart';
import 'package:foodam/src/presentation/screens/splash/splash_screen.dart';

import '../../src/domain/entities/package/package_entity.dart';

class AppRouter {
  // ==================== Route Constants ====================

  // Core App Routes
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String initialRoute = '/';
  static const String mainRoute = '/main';
  static const String homeRoute = '/home';

  // Auth Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String resetPasswordRoute = '/reset-password';
  static const String verifyOtpRoute = '/verify-otp';

  // Profile Routes
  static const String profileRoute = '/profile';
  static const String profileCompletionRoute = '/profile-completion';
  static const String addAddressRoute = '/add-address';

  // Package Routes
  static const String packagesRoute = '/packages';
  static const String packageDetailRoute = '/package-detail';

  // Meal Planning Flow Routes
  static const String startPlanningRoute = '/start-planning';
  static const String weekGridRoute = '/week-grid';
  static const String subscriptionSummaryRoute = '/subscription-summary';
  static const String confirmationRoute = '/confirmation';

  // Order Routes
  static const String ordersRoute = '/orders';

  // ==================== Route Generator ====================

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ===== Core App Routes =====
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

      case onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case mainRoute:
        return MaterialPageRoute(
          builder: (_) => MainScreen(key: MainScreenController.key),
        );

      case homeRoute:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      // ===== Auth Routes =====
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

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

      // ===== Profile Routes =====
      case profileRoute:
        return MaterialPageRoute(builder: (_) => ProfileScreen());

      case profileCompletionRoute:
        if (settings.arguments is User) {
          return MaterialPageRoute(
            builder:
                (_) =>
                    ProfileCompletionScreen(user: settings.arguments as User),
          );
        }
        return _errorRoute(settings);

      case addAddressRoute:
        if (settings.arguments is Address) {
          return MaterialPageRoute(
            builder:
                (_) => AddAddressScreen(address: settings.arguments as Address),
          );
        }
        return MaterialPageRoute(builder: (_) => const AddAddressScreen());

      // ===== Package Routes =====
      case packagesRoute:
        final initialFilter = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => PackagesScreen(initialFilter: initialFilter),
        );

      case packageDetailRoute:
        final package = settings.arguments as Package?;
        if (package == null) {
          return _errorRoute(settings);
        }
        return MaterialPageRoute(
          builder: (_) => PackageDetailScreen(package: package),
        );

      // ===== Meal Planning Flow Routes =====
      case startPlanningRoute:
        return MaterialPageRoute(
          builder: (_) => const StartMealPlanningScreen(),
        );

      case weekGridRoute:
        return MaterialPageRoute(builder: (_) => const WeekGridScreen());

      case subscriptionSummaryRoute:
        return MaterialPageRoute(
          builder: (_) => const SubscriptionSummaryScreen(),
        );

      case confirmationRoute:
        final subscription = settings.arguments as Subscription?;
        if (subscription == null) {
          return _errorRoute(settings);
        }
        return MaterialPageRoute(
          builder: (_) => ConfirmationScreen(subscription: subscription),
        );

      // ===== Order Routes =====
      case ordersRoute:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());

      // ===== Error Route =====
      default:
        return _errorRoute(settings);
    }
  }

  // ==================== Error Route ====================

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

  // ==================== Navigation Helpers ====================

  // Meal Planning Flow Navigation
  static Future<void> startMealPlanning(BuildContext context) {
    return Navigator.pushNamed(context, startPlanningRoute);
  }

  static Future<void> navigateToWeekGrid(BuildContext context) {
    return Navigator.pushNamed(context, weekGridRoute);
  }

  static Future<void> navigateToSummary(BuildContext context) {
    return Navigator.pushNamed(context, subscriptionSummaryRoute);
  }

  static void exitMealPlanningFlow(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, mainRoute, (route) => false);
  }

  // Package Navigation
  static Future<void> navigateToPackages(BuildContext context) {
    return Navigator.pushNamed(context, packagesRoute);
  }

  static Future<void> navigateToPackageDetail(
    BuildContext context,
    Package package,
  ) {
    return Navigator.pushNamed(context, packageDetailRoute, arguments: package);
  }

  // Order Navigation
  static Future<void> navigateToOrders(BuildContext context) {
    return Navigator.pushNamed(context, ordersRoute);
  }

  // Profile Navigation
  static Future<void> navigateToProfile(BuildContext context) {
    return Navigator.pushNamed(context, profileRoute);
  }

  static Future<void> navigateToAddAddress(
    BuildContext context, {
    Address? address,
  }) {
    return Navigator.pushNamed(context, addAddressRoute, arguments: address);
  }

  // Completion Flow
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
}
