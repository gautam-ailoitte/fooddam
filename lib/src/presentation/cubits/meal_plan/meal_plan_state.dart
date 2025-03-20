// lib/src/presentation/cubits/meal_plan/meal_plan_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';

abstract class MealPlanSelectionState extends Equatable {
  const MealPlanSelectionState();
  
  @override
  List<Object?> get props => [];
}

class MealPlanSelectionInitial extends MealPlanSelectionState {}

class MealPlanSelectionLoading extends MealPlanSelectionState {}

class MealPlanTypeSelected extends MealPlanSelectionState {
  final SubscriptionPlan selectedPlan;
  
  const MealPlanTypeSelected(this.selectedPlan);
  
  @override
  List<Object?> get props => [selectedPlan];
}

class MealPlanDurationSelected extends MealPlanSelectionState {
  final SubscriptionPlan selectedPlan;
  final String duration; // String representation e.g. "7 days"
  final int mealCount; // Number of meals selected
  final int durationDays; // Actual number of days for duration
  
  const MealPlanDurationSelected({
    required this.selectedPlan,
    required this.duration,
    required this.mealCount,
    required this.durationDays,
  });
  
  @override
  List<Object?> get props => [selectedPlan, duration, mealCount, durationDays];
}

class MealPlanDatesSelected extends MealPlanSelectionState {
  final SubscriptionPlan selectedPlan;
  final String duration;
  final int mealCount;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  
  const MealPlanDatesSelected({
    required this.selectedPlan,
    required this.duration,
    required this.mealCount,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object?> get props => [selectedPlan, duration, mealCount, durationDays, startDate, endDate];
}

class MealPlanCompleted extends MealPlanSelectionState {
  final MealPlanSelection mealPlanSelection;
  
  const MealPlanCompleted(this.mealPlanSelection);
  
  @override
  List<Object?> get props => [mealPlanSelection];
}

class MealPlanSelectionError extends MealPlanSelectionState {
  final String message;
  
  const MealPlanSelectionError(this.message);
  
  @override
  List<Object?> get props => [message];
}