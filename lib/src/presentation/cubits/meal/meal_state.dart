// lib/src/presentation/cubits/meal/meal_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';

/// Base state for all meal-related states
abstract class MealState extends Equatable {
  const MealState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when no meal data has been loaded
class MealInitial extends MealState {
  const MealInitial();
}

/// Loading state for meal operations
class MealLoading extends MealState {
  const MealLoading();
}

/// State for when a specific meal is loaded
class MealLoaded extends MealState {
  final Meal meal;
  
  const MealLoaded({required this.meal});
  
  @override
  List<Object?> get props => [meal];
}

/// State for when a list of meals is loaded
class MealListLoaded extends MealState {
  final List<Meal> meals;
  
  const MealListLoaded({required this.meals});
  
  @override
  List<Object?> get props => [meals];
  
  bool get isEmpty => meals.isEmpty;
  int get mealCount => meals.length;
  
  /// Get a meal by ID
  Meal? getMealById(String id) {
    try {
      return meals.firstWhere((meal) => meal.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// State for when today's meals are loaded
class TodayMealsLoaded extends MealState {
  final List<MealOrder> orders;
  final Map<String, List<MealOrder>> mealsByType;
  final String currentMealPeriod;
  
  const TodayMealsLoaded({
    required this.orders,
    required this.mealsByType,
    required this.currentMealPeriod,
  });
  
  @override
  List<Object?> get props => [orders, mealsByType, currentMealPeriod];
  
  bool get hasMealsToday => orders.isNotEmpty;
  
  bool get hasBreakfast => mealsByType['Breakfast']?.isNotEmpty ?? false;
  bool get hasLunch => mealsByType['Lunch']?.isNotEmpty ?? false;
  bool get hasDinner => mealsByType['Dinner']?.isNotEmpty ?? false;
  
  int get breakfastCount => mealsByType['Breakfast']?.length ?? 0;
  int get lunchCount => mealsByType['Lunch']?.length ?? 0;
  int get dinnerCount => mealsByType['Dinner']?.length ?? 0;
  
  bool get hasUpcomingDeliveries => 
      orders.any((order) => order.status == OrderStatus.coming);
  
  List<MealOrder> get upcomingDeliveries => 
      orders.where((order) => order.status == OrderStatus.coming).toList();
      
  List<MealOrder> get deliveredMeals => 
      orders.where((order) => order.status == OrderStatus.delivered).toList();
      
  bool get hasMealsForCurrentPeriod => 
      mealsByType[currentMealPeriod]?.isNotEmpty ?? false;
  
  List<MealOrder> get currentPeriodMeals => 
      mealsByType[currentMealPeriod] ?? [];
}

/// Error state for meal operations
class MealError extends MealState {
  final String message;
  
  const MealError({required this.message});
  
  @override
  List<Object?> get props => [message];
}