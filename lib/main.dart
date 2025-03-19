// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/bloc/bloc_observer.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/theme/app_theme.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:foodam/src/presentation/cubits/checkout/checkout_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_configuration/meal_configuration_cubit.dart';
import 'package:foodam/src/presentation/cubits/order/order_cubit.dart';
import 'package:foodam/src/presentation/cubits/profile/profile_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription_cubit.dart';
import 'package:foodam/injection_container.dart' as di;
import 'package:foodam/src/presentation/screens/auth/login_page.dart';
import 'package:foodam/src/presentation/screens/auth/signup_page.dart';
import 'package:foodam/src/presentation/screens/checkout/checkout_page.dart';
import 'package:foodam/src/presentation/screens/home/home_page.dart';
import 'package:foodam/src/presentation/screens/meal_configuration/meal_configuration_page.dart';
import 'dart:async';

import 'package:foodam/src/presentation/screens/subscription/subscription_detail_page.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger first for early debugging
  final logger = LoggerService();
  logger.setMinimumLogLevel(kDebugMode ? LogLevel.verbose : LogLevel.error);
  logger.i('Starting application initialization', tag: 'APP');
  
  try {
    // Initialize dependencies
    await di.init();
    
    // Setup Bloc observer for debugging
    Bloc.observer = AppBlocObserver();
    
    logger.i('Application initialized successfully', tag: 'APP');
  } catch (e, stackTrace) {
    logger.e('Error during initialization', error: e, stackTrace: stackTrace, tag: 'APP');
  }
  
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => di.sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => di.sl<ProfileCubit>(),
        ),
        BlocProvider<SubscriptionCubit>(
          create: (context) => di.sl<SubscriptionCubit>(),
        ),
        BlocProvider<MealConfigurationCubit>(
          create: (context) => di.sl<MealConfigurationCubit>(),
        ),
        BlocProvider<CheckoutCubit>(
          create: (context) => di.sl<CheckoutCubit>(),
        ),
        BlocProvider<OrderManagementCubit>(
          create: (context) => di.sl<OrderManagementCubit>(),
        ),
      ],
      child: MaterialApp(
        title: StringConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: LoginPage.routeName,
        routes: {
          LoginPage.routeName: (context) => const LoginPage(),
          RegisterPage.routeName: (context) => const RegisterPage(),
          HomePage.routeName: (context) => const HomePage(),
          PlanSelectionPage.routeName: (context) => const PlanSelectionPage(),
          MealConfigurationPage.routeName: (context) => const MealConfigurationPage(),
          CheckoutPage.routeName: (context) => const CheckoutPage(),
          OrderDetailsPage.routeName: (context) => const OrderDetailsPage(orderId: '',),
          SubscriptionDetailsPage.routeName: (context) {
            // This route should be navigated to with arguments, providing a default empty subscription
            return SubscriptionDetailsPage(
              subscription: Subscription(
                id: 'default_id',
                userId: 'default_user_id',
                duration: SubscriptionDuration.days30,
                startDate: DateTime.now(),
                endDate: DateTime.now().add(Duration(days: 30)),
                status: SubscriptionStatus.active,
                basePrice: 100.0,
                totalPrice: 120.0,
                isCustomized: false,
                mealPreferences: [],
                deliverySchedule: DeliverySchedule(
                  daysOfWeek: [], // Replace with a valid list of days
                  preferredTimeSlot: 'default_time_slot', // Replace with a valid time slot
                ), // Replace with a valid DeliverySchedule object
                deliveryAddress: Address(
                  street: 'default_street',
                  city: 'default_city',
                  state: 'default_state',
                  zipCode: 'default_zip',
                  country: 'default_country',
                ),
                createdAt: DateTime.now(),
              ), // Replace with a valid Subscription object
            );
          },
        },
        onGenerateRoute: (settings) {
          // Handle routes that need arguments
          if (settings.name == SubscriptionDetailsPage.routeName) {
            final args = settings.arguments as Subscription;
            return MaterialPageRoute(
              builder: (context) => SubscriptionDetailsPage(
                subscription: args,
              ),
            );
          }
          
          if (settings.name == OrderDetailsPage.routeName) {
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) {
                return OrderDetailsPage(orderId: args);
              },
            );
          }
          
          if (settings.name == CheckoutPage.routeName) {
            final args = settings.arguments as double;
            return MaterialPageRoute(
              builder: (context) {
                return CheckoutPage(additionalCost: args);
              },
            );
          }
          
          return null;
        },
        builder: (context, child) {
          // Add any app-wide UI modifications here
          return MediaQuery(
            // Set text scaling to prevent layout issues
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  static const routeName = '/order-details';
  final String orderId;

  const OrderDetailsPage({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Center(
        child: Text('Order ID: $orderId'),
      ),
    );
  }
}



class CheckoutPage extends StatelessWidget {
  static const routeName = '/checkout';
  final double additionalCost;

  const CheckoutPage({Key? key, this.additionalCost = 0.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Center(
        child: Text('Additional Cost: ₹$additionalCost'),
      ),
    );
  }
}