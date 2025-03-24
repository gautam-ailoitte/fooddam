// lib/src/presentation/cubits/meal/meal_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

abstract class MealState extends Equatable {
  const MealState();
  
  @override
  List<Object?> get props => [];
}

class MealInitial extends MealState {}

class MealLoading extends MealState {}

class MealLoaded extends MealState {
  final Meal meal;
  
  const MealLoaded({required this.meal});
  
  @override
  List<Object?> get props => [meal];
}

class MealListLoaded extends MealState {
  final List<Meal> meals;
  
  const MealListLoaded({required this.meals});
  
  @override
  List<Object?> get props => [meals];
  
  bool get isEmpty => meals.isEmpty;
  
  int get mealCount => meals.length;
  
  // Helper to get meal by ID
  Meal? getMealById(String id) {
    try {
      return meals.firstWhere((meal) => meal.id == id);
    } catch (_) {
      return null;
    }
  }
}

class MealError extends MealState {
  final String message;
  
  const MealError(this.message);
  
  @override
  List<Object?> get props => [message];
}