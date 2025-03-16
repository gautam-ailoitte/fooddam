// lib/core/route/app_router.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';
import 'package:foodam/src/presentation/views/active_plan_page.dart';
import 'package:foodam/src/presentation/views/home_page.dart';
import 'package:foodam/src/presentation/views/login_page.dart';
import 'package:foodam/src/presentation/views/meal_customization_page.dart';
import 'package:foodam/src/presentation/views/payment_page.dart';
import 'package:foodam/src/presentation/views/plan_details_page.dart';
import 'package:foodam/src/presentation/views/plan_selection_page.dart';
import 'package:foodam/src/presentation/views/thali_selection_page.dart';

class AppRouter {
  // Method to check if route requires authentication
  static bool _requiresAuth(String routeName) {
    return routeName != AppRoutes.login;
  }
  
  // Generate route method
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract route name
    final routeName = settings.name ?? '/';
    
    // Route guard for authentication
    if (_requiresAuth(routeName)) {
      // Note: Auth check is handled by AuthCubit in the app startup
      // This is just a placeholder for additional route guards if needed
    }

    // Generate the appropriate route
    switch (routeName) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomePage());
        
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginPage());
        
      case AppRoutes.planSelection:
        return MaterialPageRoute(builder: (_) => PlanSelectionPage());
        
      case AppRoutes.planDetails:
        return MaterialPageRoute(builder: (_) => PlanDetailsPage());
        
      case AppRoutes.thaliSelection:
        final args = settings.arguments as Map<String, dynamic>;
        final dayOfWeek = args['dayOfWeek'] as DayOfWeek;
        final mealType = args['mealType'] as MealType;
        
        return MaterialPageRoute(
          builder: (_) => ThaliSelectionPage(
            dayOfWeek: dayOfWeek,
            mealType: mealType,
          ),
        );
        
      case AppRoutes.mealCustomization:
        final args = settings.arguments as Map<String, dynamic>;
        final thali = args['thali'] as Thali;
        final dayOfWeek = args['dayOfWeek'] as DayOfWeek;
        final mealType = args['mealType'] as MealType;
        
        return MaterialPageRoute(
          builder: (_) => MealCustomizationPage(
            thali: thali,
            dayOfWeek: dayOfWeek,
            mealType: mealType,
          ),
        );
        
      case AppRoutes.paymentSummary:
        final plan = settings.arguments as Plan;
        return MaterialPageRoute(
          builder: (_) => PaymentSummaryPage(plan: plan),
        );
        
      case AppRoutes.activePlan:
        final plan = settings.arguments as Plan;
        return MaterialPageRoute(
          builder: (_) => ActivePlanPage(plan: plan),
        );
        
      default:
        return _errorRoute();
    }
  }
  
  // Error route for undefined routes
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(StringConstants.routeNotFound),
        ),
      ),
    );
  }
}