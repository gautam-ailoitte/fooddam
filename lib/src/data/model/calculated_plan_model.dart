import 'package:foodam/src/data/model/package/package_model.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:json_annotation/json_annotation.dart';

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

  // Mapper to convert model to entity
  CalculatedPlan toEntity() {
    return CalculatedPlan(
      dietaryPreference: dietaryPreference ?? '',
      requestedWeek: requestedWeek ?? '',
      actualSystemWeek: actualSystemWeek ?? 0,
      startDate: startDate ?? DateTime.now(),
      endDate: endDate ?? DateTime.now(),
      package: package?.toEntity(),
      dailyMeals: dailyMeals?.map((meal) => meal.toEntity()).toList() ?? [],
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DailyMealModel {
  final DateTime? date;
  final DailySlotModel? slot;

  DailyMealModel({this.date, this.slot});

  factory DailyMealModel.fromJson(Map<String, dynamic> json) =>
      _$DailyMealModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyMealModelToJson(this);

  // Mapper to convert model to entity
  DailyMeal toEntity() {
    return DailyMeal(
      date: date ?? DateTime.now(),
      slot: slot?.toEntity() ?? DailySlot(day: '', meal: null),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DailySlotModel {
  final String? day;
  final DayMealModel? meal;

  DailySlotModel({this.day, this.meal});

  factory DailySlotModel.fromJson(Map<String, dynamic> json) =>
      _$DailySlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailySlotModelToJson(this);

  // Mapper to convert model to entity
  DailySlot toEntity() {
    return DailySlot(day: day ?? '', meal: meal?.toEntity());
  }
}
