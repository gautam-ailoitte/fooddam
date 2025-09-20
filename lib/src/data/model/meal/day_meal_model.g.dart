// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayMealModel _$DayMealModelFromJson(Map<String, dynamic> json) => DayMealModel(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  dietaryPreference: json['dietaryPreference'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  dishes:
      json['dishes'] == null
          ? null
          : MealDishesModel.fromJson(json['dishes'] as Map<String, dynamic>),
  image:
      json['image'] == null
          ? null
          : PackageImageModel.fromJson(json['image'] as Map<String, dynamic>),
  isAvailable: json['isAvailable'] as bool?,
);

Map<String, dynamic> _$DayMealModelToJson(DayMealModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'dietaryPreference': instance.dietaryPreference,
      'price': instance.price,
      'dishes': instance.dishes?.toJson(),
      'image': instance.image?.toJson(),
      'isAvailable': instance.isAvailable,
    };
