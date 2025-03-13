// Updated AppRouter
import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/views/active_plan_page.dart';
import 'package:foodam/src/presentation/views/home_page.dart';
import 'package:foodam/src/presentation/views/login_page.dart';
import 'package:foodam/src/presentation/views/meal_customization_page.dart' as meal_page;
import 'package:foodam/src/presentation/views/payment_page.dart';
import 'package:foodam/src/presentation/views/plan_details_page.dart';
import 'package:foodam/src/presentation/views/plan_selection_page.dart';
import 'package:foodam/src/presentation/views/thali_selection_page.dart';


// app_router.dart
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginPage());
        
      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage());
        
      case '/plan-selection':
        return MaterialPageRoute(builder: (_) => PlanSelectionPage());
        
      case '/plan-details':
        return MaterialPageRoute(builder: (_) => PlanDetailsPage());
        
      case '/thali-selection':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ThaliSelectionPage(
            dayOfWeek: args['dayOfWeek'],
            mealType: args['mealType'],
          ),
        );
        
      case '/meal-customization':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => meal_page.MealCustomizationPage(
            thali: args['thali'],
            dayOfWeek: args['dayOfWeek'],
            mealType: args['mealType'],
          ),
        );
        
      case '/payment':
        return MaterialPageRoute(builder: (_) => PaymentPage());
        
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