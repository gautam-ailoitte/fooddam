// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayMealModel _$DayMealModelFromJson(Map<String, dynamic> json) => DayMealModel(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  dietaryPreferences:
      (json['dietaryPreferences'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  isAvailable: json['isAvailable'] as bool?,
  image: json['image'] as Map<String, dynamic>?,
  mealDishes: (json['dishes'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, DishModel.fromJson(e as Map<String, dynamic>)),
  ),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DayMealModelToJson(DayMealModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'dietaryPreferences': instance.dietaryPreferences,
      'isAvailable': instance.isAvailable,
      'image': instance.image,
      'dishes': instance.mealDishes?.map((k, e) => MapEntry(k, e.toJson())),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
