// lib/core/route/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/screens/auth/forgot_password_screen.dart';
import 'package:foodam/src/presentation/screens/auth/login_screen.dart';
import 'package:foodam/src/presentation/screens/auth/registration_screen.dart';
import 'package:foodam/src/presentation/screens/checkout/chekout_screen.dart';
import 'package:foodam/src/presentation/screens/checkout/confirmation_screen.dart';
import 'package:foodam/src/presentation/screens/home/home_screen.dart';
import 'package:foodam/src/presentation/screens/meal_selection/meal_selection_scree.dart';
import 'package:foodam/src/presentation/screens/nav/main_screen.dart';
import 'package:foodam/src/presentation/screens/package/pacakge_screen.dart';
import 'package:foodam/src/presentation/screens/package/package_detaill_screen.dart';
import 'package:foodam/src/presentation/screens/profile/address_screen.dart';
import 'package:foodam/src/presentation/screens/profile/profile_completion_screen.dart';
import 'package:foodam/src/presentation/screens/profile/profile_screen.dart';
import 'package:foodam/src/presentation/screens/splash/onboarding_screen.dart';
import 'package:foodam/src/presentation/screens/splash/splash_screen.dart';
import 'package:foodam/src/presentation/screens/susbs/subscription_detail_screen.dart';
import 'package:foodam/src/presentation/screens/susbs/subscription_screen.dart';

class AppRouter {
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String mainRoute = '/main';
  static const String homeRoute = '/home';
  static const String subscriptionsRoute = '/subscriptions';
  static const String subscriptionDetailRoute = '/subscription-detail';
  static const String packagesRoute = '/packages';
  static const String packageDetailRoute = '/package-detail';
  static const String mealSelectionRoute = '/meal-selection';
  static const String checkoutRoute = '/checkout';
  static const String confirmationRoute = '/confirmation';
  static const String profileRoute = '/profile';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String profileCompletionRoute = '/profile-completion';
  static const String addAddressRoute = '/add-address';

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
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case profileCompletionRoute:
        // This route would typically be accessed directly from login/register
        // But adding it here for completeness
        if (settings.arguments is User) {
          return MaterialPageRoute(
            builder:
                (_) =>
                    ProfileCompletionScreen(user: settings.arguments as User),
          );
        }
        return _errorRoute(settings);

      case mainRoute:
        return MaterialPageRoute(builder: (_) => MainScreen());

      case homeRoute:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case subscriptionsRoute:
        return MaterialPageRoute(builder: (_) => SubscriptionsScreen());

      case subscriptionDetailRoute:
        final subscription = settings.arguments as Subscription;
        return MaterialPageRoute(
          builder: (_) => SubscriptionDetailScreen(subscription: subscription),
        );

      case packagesRoute:
        return MaterialPageRoute(builder: (_) => PackagesScreen());

      case packageDetailRoute:
        final package = settings.arguments as Package;
        return MaterialPageRoute(
          builder: (_) => PackageDetailScreen(package: package),
        );

      case mealSelectionRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => MealSelectionScreen(
                package: args['package'],
                personCount: args['personCount'] ?? 1,
                startDate:
                    args['startDate'] ?? DateTime.now().add(Duration(days: 1)),
                durationDays: args['durationDays'] ?? 7,
              ),
        );

      case checkoutRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => CheckoutScreen(
                packageId: args['packageId'],
                mealSlots: args['mealSlots'],
                personCount: args['personCount'] ?? 1,
                startDate:
                    args['startDate'] ?? DateTime.now().add(Duration(days: 1)),
                durationDays: args['durationDays'] ?? 7,
              ),
        );

      case confirmationRoute:
        final subscription = settings.arguments as Subscription;
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

  // Add the missing _errorRoute method
  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
    );
  }
}
