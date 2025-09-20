import 'package:foodam/src/domain/entities/meal/meal_slot_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_slot_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MealSlotModel {
  final String? day;
  final DateTime? date;
  final String? timing;
  final String? meal; // API uses 'meal' field for dish ID

  MealSlotModel({this.day, this.date, this.timing, this.meal});

  factory MealSlotModel.fromJson(Map<String, dynamic> json) =>
      _$MealSlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealSlotModelToJson(this);

  // For API requests (subscription creation)
  Map<String, dynamic> toRequestJson() {
    return {
      'day': day?.toLowerCase(),
      'date': date?.toUtc().toIso8601String(),
      'timing': timing?.toLowerCase(),
      'meal': meal, // dish ID
    };
  }

  // Convert to entity
  MealSlot toEntity() {
    return MealSlot(
      day: day,
      date: date,
      timing: timing,
      dishId: meal, // Convert 'meal' field to dishId
    );
  }

  // Convert from entity
  factory MealSlotModel.fromEntity(MealSlot entity) {
    return MealSlotModel(
      day: entity.day,
      date: entity.date,
      timing: entity.timing,
      meal: entity.dishId, // Convert dishId to 'meal' field
    );
  }
}
