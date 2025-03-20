

import 'package:foodam/src/domain/entities/nutritional_entity.dart';

class NutritionalInfoModel extends NutritionalInfo {
  const NutritionalInfoModel({
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
  });

  factory NutritionalInfoModel.fromJson(Map<String, dynamic> json) {
    return NutritionalInfoModel(
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

