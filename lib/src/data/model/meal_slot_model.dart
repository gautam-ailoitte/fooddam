// lib/src/data/model/meal_slot_model.dart
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';

class MealSlotModel {
  final String day;
  final String timing;
  final MealModel? meal;
  final String? mealId;

  MealSlotModel({
    required this.day,
    required this.timing,
    this.meal,
    this.mealId,
  });

  factory MealSlotModel.fromJson(Map<String, dynamic> json) {
    return MealSlotModel(
      day: json['day'],
      timing: json['timing'],
      meal: json['meal'] != null && json['meal'] is Map
          ? MealModel.fromJson(json['meal'])
          : null,
      mealId: json['meal'] is String ? json['meal'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'timing': timing,
      'meal': meal?.toJson() ?? mealId,
    };
  }

  // For API request format used in subscribe endpoint
  Map<String, dynamic> toRequestJson() {
    return {
      'day': day,
      'timing': timing,
    };
  }

  // Mapper to convert model to entity
  MealSlot toEntity() {
    return MealSlot(
      day: day,
      timing: timing,
      meal: meal?.toEntity(),
      mealId: mealId ?? meal?.id,
    );
  }

  // Mapper to convert entity to model
  factory MealSlotModel.fromEntity(MealSlot entity) {
    return MealSlotModel(
      day: entity.day,
      timing: entity.timing,
      meal: entity.meal != null ? MealModel.fromEntity(entity.meal!) : null,
      mealId: entity.mealId,
    );
  }
}