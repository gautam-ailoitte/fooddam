// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_dishes_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealDishesModel _$MealDishesModelFromJson(Map<String, dynamic> json) =>
    MealDishesModel(
      breakfast:
          json['breakfast'] == null
              ? null
              : DishModel.fromJson(json['breakfast'] as Map<String, dynamic>),
      lunch:
          json['lunch'] == null
              ? null
              : DishModel.fromJson(json['lunch'] as Map<String, dynamic>),
      dinner:
          json['dinner'] == null
              ? null
              : DishModel.fromJson(json['dinner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MealDishesModelToJson(MealDishesModel instance) =>
    <String, dynamic>{
      'breakfast': instance.breakfast?.toJson(),
      'lunch': instance.lunch?.toJson(),
      'dinner': instance.dinner?.toJson(),
    };
