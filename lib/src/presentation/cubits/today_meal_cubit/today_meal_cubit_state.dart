// lib/src/presentation/cubits/meal/today_meal_state.dart

import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';

/// Base state for today's meal states
abstract class TodayMealState extends Equatable {
  const TodayMealState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when no meal data has been loaded
class TodayMealInitial extends TodayMealState {
  const TodayMealInitial();
}

/// Loading state when fetching today's meals
class TodayMealLoading extends TodayMealState {
  const TodayMealLoading();
}

/// Refreshing state when refreshing today's meals but keeping current data visible
class TodayMealRefreshing extends TodayMealLoaded {
  const TodayMealRefreshing({
    required super.meals,
    required super.mealsByType,
    required super.currentMealPeriod,
  });
}

/// Loaded state with today's meals data
class TodayMealLoaded extends TodayMealState {
  final List<MealOrder> meals;
  final Map<String, List<MealOrder>> mealsByType;
  final String currentMealPeriod;
  
  const TodayMealLoaded({
    required this.meals,
    required this.mealsByType,
    required this.currentMealPeriod,
  });
  
  @override
  List<Object?> get props => [meals, mealsByType, currentMealPeriod];
  
  // Helper getters
  
  bool get hasMealsToday => meals.isNotEmpty;
  
  bool get hasBreakfast => mealsByType['Breakfast']?.isNotEmpty ?? false;
  bool get hasLunch => mealsByType['Lunch']?.isNotEmpty ?? false;
  bool get hasDinner => mealsByType['Dinner']?.isNotEmpty ?? false;
  
  int get breakfastCount => mealsByType['Breakfast']?.length ?? 0;
  int get lunchCount => mealsByType['Lunch']?.length ?? 0;
  int get dinnerCount => mealsByType['Dinner']?.length ?? 0;
  
  bool get hasUpcomingDeliveries => 
      meals.any((meal) => meal.status == OrderStatus.coming);
  
  List<MealOrder> get upcomingDeliveries => 
      meals.where((meal) => meal.status == OrderStatus.coming).toList();
      
  List<MealOrder> get deliveredMeals => 
      meals.where((meal) => meal.status == OrderStatus.delivered).toList();
      
  bool get hasMealsForCurrentPeriod => 
      mealsByType[currentMealPeriod]?.isNotEmpty ?? false;
  
  List<MealOrder> get currentPeriodMeals => 
      mealsByType[currentMealPeriod] ?? [];
      
  // Get meals for a specific type
  List<MealOrder> getMealsByType(String type) => mealsByType[type] ?? [];
}

/// Error state for today's meal operations
class TodayMealError extends TodayMealState {
  final String message;
  
  const TodayMealError({required this.message});
  
  @override
  List<Object?> get props => [message];
}