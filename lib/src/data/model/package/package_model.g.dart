// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageModel _$PackageModelFromJson(Map<String, dynamic> json) => PackageModel(
  index: (json['index'] as num?)?.toInt(),
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  week: (json['week'] as num?)?.toInt(),
  totalPrice: (json['totalPrice'] as num?)?.toDouble(),
  dietaryPreference: json['dietaryPreference'] as String?,
  image:
      json['image'] == null
          ? null
          : PackageImageModel.fromJson(json['image'] as Map<String, dynamic>),
  noOfSlots: (json['noOfSlots'] as num?)?.toInt(),
  isActive: json['isActive'] as bool?,
  slots:
      (json['slots'] as List<dynamic>?)
          ?.map((e) => PackageSlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PackageModelToJson(PackageModel instance) =>
    <String, dynamic>{
      'index': instance.index,
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'week': instance.week,
      'totalPrice': instance.totalPrice,
      'dietaryPreference': instance.dietaryPreference,
      'image': instance.image?.toJson(),
      'noOfSlots': instance.noOfSlots,
      'isActive': instance.isActive,
      'slots': instance.slots?.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
