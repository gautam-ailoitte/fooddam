// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageModel _$PackageModelFromJson(Map<String, dynamic> json) => PackageModel(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  week: (json['week'] as num?)?.toInt(),
  priceRange:
      json['priceRange'] == null
          ? null
          : PriceRangeModel.fromJson(
            json['priceRange'] as Map<String, dynamic>,
          ),
  price:
      (json['price'] as List<dynamic>?)
          ?.map((e) => PriceOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  dietaryPreferences:
      (json['dietaryPreferences'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  image: json['image'] as Map<String, dynamic>?,
  noOfSlots: (json['noOfSlots'] as num?)?.toInt(),
  isActive: json['isActive'] as bool?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  slots:
      (json['slots'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
);

Map<String, dynamic> _$PackageModelToJson(PackageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'week': instance.week,
      'priceRange': instance.priceRange?.toJson(),
      'price': instance.price?.map((e) => e.toJson()).toList(),
      'dietaryPreferences': instance.dietaryPreferences,
      'image': instance.image,
      'noOfSlots': instance.noOfSlots,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'slots': instance.slots,
    };
