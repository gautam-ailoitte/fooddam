import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/injection_container.dart' as di;
import 'package:foodam/src/presentation/cubits/active_plan_cubit/active_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubits.dart';
import 'package:foodam/src/presentation/cubits/draft_plan_cubit/draft_plan_cubit.dart';
import 'package:foodam/src/presentation/cubits/meal_customization_cubit/meal_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_browse_cubit/plan_browse_cubit.dart';
import 'package:foodam/src/presentation/cubits/plan_customization_cubit/plan_customization_cubit.dart';
import 'package:foodam/src/presentation/cubits/thali_selection_subit/thali_selection_cubit.dart';
import 'package:foodam/src/presentation/payment_cubit/payment_cubit.dart';
import 'package:foodam/src/presentation/views/home_page.dart';
import 'package:foodam/src/presentation/views/login_page.dart';
import 'package:foodam/src/presentation/widgets/common/app_loading.dart';
// Make sure this is created

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize dependency injection
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _routeObserver = RouteObserver<PageRoute>();

  MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => di.sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<ActivePlanCubit>(
          create: (context) => di.sl<ActivePlanCubit>(),
        ),
        BlocProvider<DraftPlanCubit>(
          create: (context) => di.sl<DraftPlanCubit>(),
        ),
        BlocProvider<PlanBrowseCubit>(
          create: (context) => di.sl<PlanBrowseCubit>(),
        ),
        BlocProvider<PlanCustomizationCubit>(
          create: (context) => di.sl<PlanCustomizationCubit>(),
        ),
        BlocProvider<PaymentCubit>(
          create: (context) => di.sl<PaymentCubit>(),
        ),
        BlocProvider<ThaliSelectionCubit>(
          create: (context) => di.sl<ThaliSelectionCubit>(),
        ),
        BlocProvider<MealCustomizationCubit>(
          create: (context) => di.sl<MealCustomizationCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Meal Subscription',
        theme: ThemeData(primarySwatch: Colors.orange),
        onGenerateRoute: AppRouter.generateRoute,
        navigatorObservers: [_routeObserver], // Register route observer
        debugShowCheckedModeBanner: false,
        home: AppStartPage(), // Set the home page
      ),
    );
  }
}

class AppStartPage extends StatelessWidget {
  const AppStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return Scaffold(body: AppLoading(message: 'Starting app...'));
        } else if (state is AuthAuthenticated) {
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}