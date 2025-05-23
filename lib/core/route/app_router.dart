// lib/core/route/app_router.dart (UPDATE SUBSCRIPTION ROUTES)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
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
import 'package:foodam/src/presentation/screens/package/daily_meal_detail_screen.dart';
import 'package:foodam/src/presentation/screens/package/dish_detail_screen.dart';
import 'package:foodam/src/presentation/screens/package/pacakge_screen.dart';
import 'package:foodam/src/presentation/screens/package/package_detaill_screen.dart';
import 'package:foodam/src/presentation/screens/profile/address_screen.dart';
import 'package:foodam/src/presentation/screens/profile/profile_completion_screen.dart';
import 'package:foodam/src/presentation/screens/profile/profile_screen.dart';
import 'package:foodam/src/presentation/screens/splash/onboarding_screen.dart';
import 'package:foodam/src/presentation/screens/splash/splash_screen.dart';
import 'package:foodam/src/presentation/screens/susbs/subscription_detail_screen.dart';
import 'package:foodam/src/presentation/screens/susbs/subscription_meal_schedule_screen.dart';
import 'package:foodam/src/presentation/screens/susbs/subscription_screen.dart';

import '../../src/presentation/screens/susbs/meal_detail_screen.dart';

class AppRouter {
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String mainRoute = '/main';
  static const String homeRoute = '/home';

  // Subscription routes
  static const String subscriptionsRoute = '/subscriptions';
  static const String subscriptionDetailRoute = '/subscription-detail';
  static const String subscriptionMealScheduleRoute =
      '/subscription-meal-schedule';
  static const String mealDetailRoute = '/meal-detail';

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

  // Order routes
  static const String ordersRoute = '/orders';
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
          return MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Missing meal selection data'),
                        SizedBox(height: 16),
                        Text('Please go back and select a package first'),
                      ],
                    ),
                  ),
                ),
          );
        }
        return MaterialPageRoute(builder: (_) => const MealSelectionScreen());

      case checkoutRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Missing checkout data'),
                        SizedBox(height: 16),
                        Text('Please start over from package selection'),
                      ],
                    ),
                  ),
                ),
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
}
