// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_slot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageSlotModel _$PackageSlotModelFromJson(Map<String, dynamic> json) =>
    PackageSlotModel(
      day: json['day'] as String?,
      meal:
          json['meal'] == null
              ? null
              : MealModel.fromJson(json['meal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PackageSlotModelToJson(PackageSlotModel instance) =>
    <String, dynamic>{'day': instance.day, 'meal': instance.meal?.toJson()};
