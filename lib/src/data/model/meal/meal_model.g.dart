// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealModel _$MealModelFromJson(Map<String, dynamic> json) => MealModel(
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
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MealModelToJson(MealModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'dietaryPreference': instance.dietaryPreference,
  'price': instance.price,
  'dishes': instance.dishes?.toJson(),
  'image': instance.image?.toJson(),
  'isAvailable': instance.isAvailable,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
