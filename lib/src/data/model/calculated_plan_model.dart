import 'package:foodam/src/data/model/package/package_model.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:json_annotation/json_annotation.dart';

import 'meal/day_meal_model.dart';

part 'calculated_plan_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CalculatedPlanModel {
  final String? dietaryPreference;
  final String? requestedWeek;
  final int? actualSystemWeek;
  final DateTime? startDate;
  final DateTime? endDate;
  final PackageModel? package;
  final List<DailyMealModel>? dailyMeals;

  CalculatedPlanModel({
    this.dietaryPreference,
    this.requestedWeek,
    this.actualSystemWeek,
    this.startDate,
    this.endDate,
    this.package,
    this.dailyMeals,
  });

  factory CalculatedPlanModel.fromJson(Map<String, dynamic> json) =>
      _$CalculatedPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatedPlanModelToJson(this);

  CalculatedPlan toEntity() {
    return CalculatedPlan(
      dietaryPreference: dietaryPreference,
      requestedWeek: requestedWeek,
      actualSystemWeek: actualSystemWeek,
      startDate: startDate,
      endDate: endDate,
      package: package?.toEntity(),
      dailyMeals: dailyMeals?.map((meal) => meal.toEntity()).toList(),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DailyMealModel {
  final DateTime? date;
  final String? day;
  final DayMealModel? meal;

  DailyMealModel({this.date, this.day, this.meal});

  factory DailyMealModel.fromJson(Map<String, dynamic> json) =>
      _$DailyMealModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyMealModelToJson(this);

  DailyMeal toEntity() {
    return DailyMeal(date: date, day: day, meal: meal?.toEntity());
  }
}
