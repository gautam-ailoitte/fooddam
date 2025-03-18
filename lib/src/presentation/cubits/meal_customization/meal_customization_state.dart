// lib/src/presentation/cubits/meal_customization/meal_customization_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

abstract class MealCustomizationState extends Equatable {
  const MealCustomizationState();

  @override
  List<Object?> get props => [];
}

class MealCustomizationInitial extends MealCustomizationState {}

class MealCustomizationLoading extends MealCustomizationState {}

class MealCustomizationError extends MealCustomizationState {
  final String message;

  const MealCustomizationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class MealsLoaded extends MealCustomizationState {
  final List<Meal> meals;

  const MealsLoaded({required this.meals});

  @override
  List<Object?> get props => [meals];
}

class MealCustomizationReady extends MealCustomizationState {
  final Meal meal;
  final Map<String, List<String>> selectedDishIds;
  final Map<String, List<Dish>> availableAdditionalDishes;
  final double totalCustomizationPrice;

  const MealCustomizationReady({
    required this.meal,
    required this.selectedDishIds,
    required this.availableAdditionalDishes,
    required this.totalCustomizationPrice,
  });

  @override
  List<Object?> get props => [meal, selectedDishIds, availableAdditionalDishes, totalCustomizationPrice];
}

class MealCustomizationCompleted extends MealCustomizationState {
  final Meal meal;
  final Map<String, List<String>> selectedDishIds;
  final double totalCustomizationPrice;
  final double totalPrice;

  const MealCustomizationCompleted({
    required this.meal,
    required this.selectedDishIds,
    required this.totalCustomizationPrice,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [meal, selectedDishIds, totalCustomizationPrice, totalPrice];
}