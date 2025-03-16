// lib/core/route/app_router.dart
import 'package:flutter/material.dart';
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
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
        
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
        
      case '/plan-selection':
        return MaterialPageRoute(builder: (_) => PlanSelectionPage());
        
      case '/plan-details':
        return MaterialPageRoute(builder: (_) => PlanDetailsPage());
        
      case '/thali-selection':
        final args = settings.arguments as Map<String, dynamic>;
        final dayOfWeek = args['dayOfWeek'] as DayOfWeek;
        final mealType = args['mealType'] as MealType;
        
        return MaterialPageRoute(
          builder: (_) => ThaliSelectionPage(
            dayOfWeek: dayOfWeek,
            mealType: mealType,
          ),
        );
        
      case '/meal-customization':
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
        
      case '/payment-summary':
        final plan = settings.arguments as Plan;
        return MaterialPageRoute(
          builder: (_) => PaymentSummaryPage(plan: plan),
        );
        
      case '/active-plan':
        final plan = settings.arguments as Plan;
        return MaterialPageRoute(
          builder: (_) => ActivePlanPage(plan: plan),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}