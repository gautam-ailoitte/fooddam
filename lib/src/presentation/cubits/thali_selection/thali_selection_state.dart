// lib/src/presentation/cubits/meal_plan/thali_selection_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';

abstract class ThaliSelectionState extends Equatable {
  const ThaliSelectionState();
  
  @override
  List<Object?> get props => [];
}

class ThaliSelectionInitial extends ThaliSelectionState {}

class ThaliSelectionLoading extends ThaliSelectionState {}

class ThaliSelecting extends ThaliSelectionState {
  final MealDistribution currentSlot;
  final List<Meal> availableMeals;
  final Meal? selectedMeal;
  
  const ThaliSelecting({
    required this.currentSlot,
    required this.availableMeals,
    this.selectedMeal,
  });
  
  @override
  List<Object?> get props => [currentSlot, availableMeals, selectedMeal];
}

class ThaliSelectionCompleted extends ThaliSelectionState {
  final Map<String, List<MealDistribution>> finalDistribution;
  
  const ThaliSelectionCompleted(this.finalDistribution);
  
  @override
  List<Object?> get props => [finalDistribution];
}

class ThaliSelectionError extends ThaliSelectionState {
  final String message;
  
  const ThaliSelectionError(this.message);
  
  @override
  List<Object?> get props => [message];
}