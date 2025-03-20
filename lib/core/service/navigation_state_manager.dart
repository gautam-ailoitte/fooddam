// lib/core/service/navigation_state_manager.dart
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';

/// Service to manage navigation state and flow validation
/// Prevents invalid navigation paths and maintains state consistency
class NavigationStateManager {
  static final NavigationStateManager _instance = NavigationStateManager._internal();
  factory NavigationStateManager() => _instance;
  NavigationStateManager._internal();

  final LoggerService _logger = LoggerService();
  
  // Current navigation path state
  final List<String> _navigationHistory = [];
  
  // Valid navigation flow paths
  final Map<String, List<String>> _validPreviousScreens = {
    AppRoutes.splash: [],
    AppRoutes.login: [AppRoutes.splash],
    AppRoutes.home: [AppRoutes.login, AppRoutes.splash, AppRoutes.paymentSummary],
    AppRoutes.planSelection: [AppRoutes.home],
    AppRoutes.planDuration: [AppRoutes.planSelection, AppRoutes.mealDistribution],
    AppRoutes.mealDistribution: [AppRoutes.planDuration, AppRoutes.paymentSummary],
    AppRoutes.paymentSummary: [AppRoutes.mealDistribution],
  };
  
  // State caching for flow
  SubscriptionPlan? _selectedPlan;
  int? _mealCount;
  int? _durationDays;
  DateTime? _startDate;
  DateTime? _endDate;
  MealPlanSelection? _completedPlanSelection;
  
  // Reset all navigation state
  void resetNavigationState() {
    _navigationHistory.clear();
    _selectedPlan = null;
    _mealCount = null;
    _durationDays = null;
    _startDate = null;
    _endDate = null;
    _completedPlanSelection = null;
    _logger.i('Navigation state reset');
  }
  
  // Add route to history
  void addToHistory(String route) {
    // If we're navigating to a route already in history, 
    // remove everything after that route
    int existingIndex = _navigationHistory.indexOf(route);
    if (existingIndex != -1) {
      _navigationHistory.removeRange(existingIndex + 1, _navigationHistory.length);
    } else {
      _navigationHistory.add(route);
    }
    _logger.i('Added to navigation history: $route');
    _logger.d('Current navigation path: ${_navigationHistory.join(' -> ')}');
  }
  
  // Check if navigation is valid
  bool isValidNavigation(String currentRoute, String targetRoute, {bool isBackNavigation = false}) {
    // Home route is always accessible
    if (targetRoute == AppRoutes.home) {
      return true;
    }
    
    // If going back, check if the target route exists in history
    if (isBackNavigation) {
      int currentIndex = _navigationHistory.indexOf(currentRoute);
      if (currentIndex > 0 && _navigationHistory[currentIndex - 1] == targetRoute) {
        return true;
      }
    }
    
    // Check if the current route is a valid previous screen for the target
    final validPrevious = _validPreviousScreens[targetRoute] ?? [];
    bool isValid = validPrevious.contains(currentRoute);
    
    if (!isValid) {
      _logger.w('Invalid navigation attempt: $currentRoute -> $targetRoute');
    }
    
    return isValid;
  }
  
  // Save plan selection state
  void savePlanSelectionState(SubscriptionPlan plan) {
    _selectedPlan = plan;
    _logger.i('Saved plan selection: ${plan.name}');
  }
  
  // Get saved plan
  SubscriptionPlan? getSavedPlan() {
    return _selectedPlan;
  }
  
  // Save duration selection state
  void saveDurationState(int mealCount, int durationDays) {
    _mealCount = mealCount;
    _durationDays = durationDays;
    _logger.i('Saved duration selection: $mealCount meals for $durationDays days');
  }
  
  // Get saved meal count
  int? getSavedMealCount() {
    return _mealCount;
  }
  
  // Get saved duration days
  int? getSavedDurationDays() {
    return _durationDays;
  }
  
  // Save date selection state
  void saveDateSelectionState(DateTime startDate, DateTime endDate) {
    _startDate = startDate;
    _endDate = endDate;
    _logger.i('Saved date selection: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
  }
  
  // Get saved start date
  DateTime? getSavedStartDate() {
    return _startDate;
  }
  
  // Get saved end date
  DateTime? getSavedEndDate() {
    return _endDate;
  }
  
  // Save completed plan selection
  void saveCompletedPlanSelection(MealPlanSelection planSelection) {
    _completedPlanSelection = planSelection;
    _logger.i('Saved completed plan selection');
  }
  
  // Get saved completed plan selection
  MealPlanSelection? getSavedCompletedPlanSelection() {
    return _completedPlanSelection;
  }
  
  // Check if we have all required state for a specific route
  bool hasRequiredStateForRoute(String route) {
    switch (route) {
      case AppRoutes.planSelection:
        return true; // No prerequisites for plan selection
      case AppRoutes.planDuration:
        return _selectedPlan != null;
      case AppRoutes.mealDistribution:
        return _selectedPlan != null && _mealCount != null && 
               _durationDays != null && _startDate != null && _endDate != null;
      case AppRoutes.paymentSummary:
        return _completedPlanSelection != null;
      default:
        return true; // No state requirements for other routes
    }
  }
  
  // Get required route to complete before accessing target route
  String? getRequiredPreviousRoute(String targetRoute) {
    if (!hasRequiredStateForRoute(targetRoute)) {
      switch (targetRoute) {
        case AppRoutes.planDuration:
          return AppRoutes.planSelection;
        case AppRoutes.mealDistribution:
          if (_selectedPlan == null) return AppRoutes.planSelection;
          return AppRoutes.planDuration;
        case AppRoutes.paymentSummary:
          return AppRoutes.mealDistribution;
        default:
          return null;
      }
    }
    return null;
  }
}