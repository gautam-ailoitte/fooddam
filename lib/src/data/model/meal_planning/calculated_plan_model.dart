// lib/src/data/models/meal_planning/calculated_plan_model.dart
import 'package:foodam/src/data/model/package/package_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'calculated_plan_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CalculatedPlanModel {
  final String? dietaryPreference;
  final String? requestedWeek;
  final int? actualSystemWeek;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? estimatedPrice;
  final PackageModel? package;
  final List<DailyMealModel>? dailyMeals;

  CalculatedPlanModel({
    this.dietaryPreference,
    this.requestedWeek,
    this.actualSystemWeek,
    this.startDate,
    this.endDate,
    this.estimatedPrice,
    this.package,
    this.dailyMeals,
  });

  factory CalculatedPlanModel.fromJson(Map<String, dynamic> json) =>
      _$CalculatedPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$CalculatedPlanModelToJson(this);
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
}

@JsonSerializable(explicitToJson: true)
class DayMealModel {
  final String? id;
  final String? name;
  final String? description;
  final String? dietaryPreference;
  final int? price;
  final Map<String, MealDishModel>? dishes;
  final MealImageModel? image;
  final bool? isAvailable;

  DayMealModel({
    this.id,
    this.name,
    this.description,
    this.dietaryPreference,
    this.price,
    this.dishes,
    this.image,
    this.isAvailable,
  });

  factory DayMealModel.fromJson(Map<String, dynamic> json) =>
      _$DayMealModelFromJson(json);

  Map<String, dynamic> toJson() => _$DayMealModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MealDishModel {
  final String? id;
  final String? name;
  final String? description;
  final int? price;
  final String? dietaryPreference;
  final bool? isAvailable;
  final MealImageModel? image;
  final String? key;

  MealDishModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.dietaryPreference,
    this.isAvailable,
    this.image,
    this.key,
  });

  factory MealDishModel.fromJson(Map<String, dynamic> json) =>
      _$MealDishModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealDishModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MealImageModel {
  final String? id;
  final String? url;
  final String? key;
  final String? fileName;

  MealImageModel({this.id, this.url, this.key, this.fileName});

  factory MealImageModel.fromJson(Map<String, dynamic> json) =>
      _$MealImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealImageModelToJson(this);
}
