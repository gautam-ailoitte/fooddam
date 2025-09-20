// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_slot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealSlotModel _$MealSlotModelFromJson(Map<String, dynamic> json) =>
    MealSlotModel(
      day: json['day'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      timing: json['timing'] as String?,
      meal: json['meal'] as String?,
    );

Map<String, dynamic> _$MealSlotModelToJson(MealSlotModel instance) =>
    <String, dynamic>{
      'day': instance.day,
      'date': instance.date?.toIso8601String(),
      'timing': instance.timing,
      'meal': instance.meal,
    };
