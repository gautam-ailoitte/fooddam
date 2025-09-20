// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DishModel _$DishModelFromJson(Map<String, dynamic> json) => DishModel(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  dietaryPreference: json['dietaryPreference'] as String?,
  isAvailable: json['isAvailable'] as bool?,
  image:
      json['image'] == null
          ? null
          : PackageImageModel.fromJson(json['image'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DishModelToJson(DishModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'dietaryPreference': instance.dietaryPreference,
  'isAvailable': instance.isAvailable,
  'image': instance.image?.toJson(),
};
