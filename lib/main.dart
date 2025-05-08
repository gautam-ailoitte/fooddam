// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/bloc/bloc_observer.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/loggin_manager.dart';
import 'package:foodam/core/service/navigation_service.dart';
import 'package:foodam/core/theme/app_theme.dart';
import 'package:foodam/core/theme/theme_provider.dart' as custom_theme;
import 'package:foodam/injection_container.dart' as di;
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/banner/banner_cubits.dart';
import 'package:foodam/src/presentation/cubits/cloud_kitchen/cloud_kitchen_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal/meal_cubit.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment_history/payment_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';
import 'package:provider/provider.dart';

//103151335
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===============================================================
  // LOG SETTINGS - CHANGE THESE VALUES DIRECTLY TO ADJUST LOGGING
  // ===============================================================
  // Options: none, critical, error, info, debug, verbose
  final AppLogLevel logLevel = AppLogLevel.debug;

  // Set this to true for detailed BLoC logging (shows full state)
  final bool detailedBlocLogs = false;
  // ===============================================================

  // Initialize logging manager with hardcoded log level
  final LoggingManager loggingManager = LoggingManager();
  loggingManager.initialize(logLevel: logLevel);

  // Set bloc detailed logging (don't need UI for this)
  AppBlocObserver.toggleDetailedLogs(detailedBlocLogs);
  Bloc.observer = NoOpBlocObserver();

  try {
    loggingManager.logger.i('Starting application initialization', tag: 'APP');

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize dependency injection
    await di.init();

    loggingManager.logger.i('Application initialized successfully', tag: 'APP');

    runApp(const FoodamApp());
  } catch (e, stackTrace) {
    loggingManager.logger.e(
      'Error during initialization',
      error: e,
      stackTrace: stackTrace,
      tag: 'APP',
    );
    runApp(ErrorApp(error: e.toString()));
  }
}

class FoodamApp extends StatelessWidget {
  const FoodamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme provider
        ChangeNotifierProvider(
          create: (_) => custom_theme.ThemeProvider(di.di()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => di.di<AuthCubit>()..checkAuthStatus(),
          ),
          BlocProvider<UserProfileCubit>(
            create: (context) => di.di<UserProfileCubit>(),
          ),
          BlocProvider<CloudKitchenCubit>(
            create: (context) => di.di<CloudKitchenCubit>(),
          ),
          BlocProvider<BannerCubit>(create: (context) => di.di<BannerCubit>()),
          BlocProvider<OrdersCubit>(create: (context) => di.di<OrdersCubit>()),
          BlocProvider<PackageCubit>(
            create: (context) => di.di<PackageCubit>(),
          ),
          BlocProvider<RazorpayPaymentCubit>(
            create: (context) => di.di<RazorpayPaymentCubit>(),
          ),
          BlocProvider<MealCubit>(create: (context) => di.di<MealCubit>()),
          BlocProvider<TodayMealCubit>(
            create: (context) => di.di<TodayMealCubit>(),
          ),
          BlocProvider<SubscriptionCubit>(
            create: (context) => di.di<SubscriptionCubit>(),
          ),
          BlocProvider<CreateSubscriptionCubit>(
            create: (context) => di.di<CreateSubscriptionCubit>(),
          ),
          BlocProvider<PaymentCubit>(
            create: (context) => di.di<PaymentCubit>(),
          ),
        ],
        child: Consumer<custom_theme.ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              title: 'Foodam',
              navigatorKey: NavigationService.navigatorKey,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.lightTheme,
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: AppRouter.splashRoute,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({required this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodam Error',
      theme: ThemeData(primarySwatch: Colors.red),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
                const SizedBox(height: 20),
                const Text(
                  'Application Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'The application could not be started due to an error:',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text('Exit App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
