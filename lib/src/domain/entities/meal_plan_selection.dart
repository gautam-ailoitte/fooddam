// lib/src/domain/entities/meal_plan_selection.dart
import 'package:equatable/equatable.dart';

class MealPlanSelection extends Equatable {
  final String planType; // e.g., veg, non-veg, premium, delux
  final String duration; // e.g., weekly, biweekly, monthly
  final DateTime startDate;
  final DateTime endDate;
  final int totalMeals;
  final Map<String, List<MealDistribution>> mealDistribution;

  const MealPlanSelection({
    required this.planType,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.totalMeals,
    required this.mealDistribution,
  });

  @override
  List<Object?> get props => [
        planType,
        duration,
        startDate,
        endDate,
        totalMeals,
        mealDistribution,
      ];
}

class MealDistribution extends Equatable {
  final String mealType; // breakfast, lunch, dinner
  final DateTime date;
  final String? mealId;

  const MealDistribution({
    required this.mealType,
    required this.date,
    this.mealId,
  });

  @override
  List<Object?> get props => [mealType, date, mealId];
}
