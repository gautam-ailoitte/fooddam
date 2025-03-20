// lib/src/presentation/cubits/meal_plan/meal_distribution_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';

abstract class MealDistributionState extends Equatable {
  const MealDistributionState();
  
  @override
  List<Object?> get props => [];
}

class MealDistributionInitial extends MealDistributionState {}

class MealDistributionLoading extends MealDistributionState {}

class MealDistributing extends MealDistributionState {
  final Map<String, int> mealTypeAllocation; // How many meals per type
  final Map<String, List<MealDistribution>> currentDistribution;
  final int totalMeals;
  final int distributedMeals;
  
  const MealDistributing({
    required this.mealTypeAllocation,
    required this.currentDistribution,
    required this.totalMeals,
    required this.distributedMeals,
  });
  
  @override
  List<Object?> get props => [mealTypeAllocation, currentDistribution, totalMeals, distributedMeals];
}

class MealDistributionCompleted extends MealDistributionState {
  final Map<String, List<MealDistribution>> distribution;
  
  const MealDistributionCompleted(this.distribution);
  
  @override
  List<Object?> get props => [distribution];
}

class MealDistributionError extends MealDistributionState {
  final String message;
  
  const MealDistributionError(this.message);
  
  @override
  List<Object?> get props => [message];
}