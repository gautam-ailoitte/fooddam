// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/bloc/bloc_observer.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/service/navigation_service.dart';
import 'package:foodam/core/theme/app_theme.dart';
import 'package:foodam/injection_container.dart' as di;
import 'package:foodam/src/presentation/cubits/active_subscription_cubit/active_subscription_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_distributaion/meal_distributaion_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/payament_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment_history/payment_history_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription_plan/subscription_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/susbcription_detail_cubit/subscription_detail_cubit.dart';
import 'package:foodam/src/presentation/cubits/thali_selection/thali_selection_cubit.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
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
      providers: _registerBlocProviders(),
      child: MaterialApp(
        title: 'Foodam',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        navigatorKey: NavigationService.navigatorKey,
        navigatorObservers: [AppRouter.routeObserver],
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRoutes.splash,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  // Centralized list of bloc providers for better organization
  List<BlocProvider> _registerBlocProviders() {
    return [
      // Authentication & User Cubits
      BlocProvider<AuthCubit>(
        create: (context) => di.di<AuthCubit>()..checkAuthStatus(),
      ),
      BlocProvider<UserProfileCubit>(
        create: (context) => di.di<UserProfileCubit>(),
      ),
      
      // Subscription & Plan Cubits
      BlocProvider<ActiveSubscriptionsCubit>(
        create: (context) => di.di<ActiveSubscriptionsCubit>(),
      ),
      BlocProvider<SubscriptionPlansCubit>(
        create: (context) => di.di<SubscriptionPlansCubit>(),
      ),
      BlocProvider<SubscriptionDetailsCubit>(
        create: (context) => di.di<SubscriptionDetailsCubit>(),
      ),
      
      // Meal & Food Cubits
      BlocProvider<TodayMealsCubit>(
        create: (context) => di.di<TodayMealsCubit>(),
      ),
      BlocProvider<MealPlanSelectionCubit>(
        create: (context) => di.di<MealPlanSelectionCubit>(),
      ),
      BlocProvider<MealDistributionCubit>(
        create: (context) => di.di<MealDistributionCubit>(),
      ),
      BlocProvider<ThaliSelectionCubit>(
        create: (context) => di.di<ThaliSelectionCubit>(),
      ),
      
      // Payment Cubits
      BlocProvider<PaymentCubit>(
        create: (context) => di.di<PaymentCubit>(),
      ),
      BlocProvider<PaymentHistoryCubit>(
        create: (context) => di.di<PaymentHistoryCubit>(),
      ),
    ];
  }
}