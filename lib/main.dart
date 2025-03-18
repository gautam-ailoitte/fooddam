// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/bloc/bloc_observer.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/service/navigation_service.dart';
import 'package:foodam/core/theme/app_theme.dart';
import 'package:foodam/injection_container.dart' as di;
import 'package:foodam/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_state.dart';
import 'package:foodam/src/presentation/cubits/meal_customization/meal_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/order/order_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/payment_cubit.dart';
import 'package:foodam/src/presentation/cubits/susbcription/subscription_cubit.dart';
import 'package:foodam/src/presentation/screens/auth/login_screen.dart';
import 'package:foodam/src/presentation/screens/home_screen.dart';
import 'package:foodam/src/presentation/screens/plan_selection_screen.dart';

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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => di.sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<SubscriptionCubit>(
          create: (context) => di.sl<SubscriptionCubit>(),
        ),
        BlocProvider<MealCustomizationCubit>(
          create: (context) => di.sl<MealCustomizationCubit>(),
        ),
        BlocProvider<OrderCubit>(
          create: (context) => di.sl<OrderCubit>(),
        ),
        BlocProvider<PaymentCubit>(
          create: (context) => di.sl<PaymentCubit>(),
        ),
      ],
      child: MaterialApp(
        title: StringConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnAuthStatus();
  }

  void _navigateBasedOnAuthStatus() {
    // Listen to auth state changes
    context.read<AuthCubit>().stream.listen((state) {
      if (state is Authenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (state is Unauthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      // If state is still loading, we stay on the splash screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder (in a real app, you'd use your app logo)
            Icon(
              Icons.restaurant_menu,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              StringConstants.appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              StringConstants.startingApp,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}