import 'package:foodam/src/domain/entities/meal_plan_selection.dart';

class MealPlanSelectionModel extends MealPlanSelection {
  const MealPlanSelectionModel({
    required super.planType,
    required super.duration,
    required super.startDate,
    required super.endDate,
    required super.totalMeals,
    required Map<String, List<MealDistributionModel>> super.mealDistribution,
  });

  factory MealPlanSelectionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<MealDistributionModel>> mealDist = {};
    
    (json['mealDistribution'] as Map<String, dynamic>).forEach((key, value) {
      mealDist[key] = (value as List)
          .map((dist) => MealDistributionModel.fromJson(dist))
          .toList();
    });

    return MealPlanSelectionModel(
      planType: json['planType'],
      duration: json['duration'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalMeals: json['totalMeals'],
      mealDistribution: mealDist,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mealDist = {};
    
    (mealDistribution as Map<String, List<MealDistributionModel>>).forEach((key, value) {
      mealDist[key] = value.map((dist) => dist.toJson()).toList();
    });

    return {
      'planType': planType,
      'duration': duration,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalMeals': totalMeals,
      'mealDistribution': mealDist,
    };
  }
}

class MealDistributionModel extends MealDistribution {
  const MealDistributionModel({
    required super.mealType,
    required super.date,
    super.mealId,
  });

  factory MealDistributionModel.fromJson(Map<String, dynamic> json) {
    return MealDistributionModel(
      mealType: json['mealType'],
      date: DateTime.parse(json['date']),
      mealId: json['mealId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType,
      'date': date.toIso8601String(),
      'mealId': mealId,
    };
  }
}