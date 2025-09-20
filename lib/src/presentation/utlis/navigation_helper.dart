// lib/src/presentation/utils/navigation_helper.dart
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

import '../../domain/entities/meal/meal_entity.dart';

// Simulate navigation without actual implementation
class NavigationHelper {
  final LoggerService _logger = LoggerService();

  void navigateToHome() {
    _logger.i('Navigating to home screen', tag: 'NAVIGATION');
    _simulateNavigation(AppRoutes.home);
  }

  void navigateToLogin() {
    _logger.i('Navigating to login screen', tag: 'NAVIGATION');
    _simulateNavigation(AppRoutes.login);
  }

  void navigateToPlanSelection() {
    _logger.i('Navigating to plan selection screen', tag: 'NAVIGATION');
    _simulateNavigation(AppRoutes.planSelection);
  }

  void navigateToMealCustomization(Meal meal, String mealType, DateTime date) {
    _logger.i(
      'Navigating to meal customization screen: ${meal.id}',
      tag: 'NAVIGATION',
    );
    _simulateNavigation(
      AppRoutes.mealCustomization,
      arguments: {'meal': meal, 'mealType': mealType, 'date': date},
    );
  }

  void navigateToActivePlan(Subscription subscription) {
    _logger.i(
      'Navigating to active plan screen: ${subscription.id}',
      tag: 'NAVIGATION',
    );
    _simulateNavigation(
      AppRoutes.activePlan,
      arguments: {'subscription': subscription},
    );
  }

  void _simulateNavigation(String route, {Map<String, dynamic>? arguments}) {
    _logger.d('Navigation simulation: $route', tag: 'NAVIGATION');
    if (arguments != null) {
      _logger.d('Navigation arguments: $arguments', tag: 'NAVIGATION');
    }
  }
}
