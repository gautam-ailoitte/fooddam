// lib/src/data/models/daily_meal_model.dart
import 'package:foodam/src/data/models/thali_model.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';

class DailyMealsModel extends DailyMeals {
  DailyMealsModel({
    super.breakfast,
    super.lunch,
    super.dinner,
  });

  factory DailyMealsModel.fromJson(Map<String, dynamic> json) {
    return DailyMealsModel(
      breakfast: json['breakfast'] != null ? ThaliModel.fromJson(json['breakfast']) : null,
      lunch: json['lunch'] != null ? ThaliModel.fromJson(json['lunch']) : null,
      dinner: json['dinner'] != null ? ThaliModel.fromJson(json['dinner']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast != null ? (breakfast as ThaliModel).toJson() : null,
      'lunch': lunch != null ? (lunch as ThaliModel).toJson() : null,
      'dinner': dinner != null ? (dinner as ThaliModel).toJson() : null,
    };
  }
  
  @override
  DailyMealsModel copyWith({
    Thali? breakfast,
    Thali? lunch,
    Thali? dinner,
  }) {
    return DailyMealsModel(
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
    );
  }
}