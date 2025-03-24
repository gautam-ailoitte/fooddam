// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/bloc/bloc_observer.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/theme/app_theme.dart';
import 'package:foodam/injection_container.dart' as di;
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal/meal_cubit.dart';
import 'package:foodam/src/presentation/cubits/pacakge_cubits/pacakage_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment_history/payment_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/user_profile/user_profile_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize dependency injection
  await di.init();
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
  runApp(FoodamApp());
}

class FoodamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => di.di<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<UserProfileCubit>(
          create: (context) => di.di<UserProfileCubit>(),
        ),
        BlocProvider<PackageCubit>(
          create: (context) => di.di<PackageCubit>(),
        ),
        BlocProvider<MealCubit>(
          create: (context) => di.di<MealCubit>(),
        ),
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
      child: MaterialApp(
        title: 'Foodam',
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.splashRoute, 
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}