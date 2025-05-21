// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeekPlanModel _$WeekPlanModelFromJson(Map<String, dynamic> json) =>
    WeekPlanModel(
      package:
          json['package'] == null
              ? null
              : PackageModel.fromJson(json['package'] as Map<String, dynamic>),
      week: (json['week'] as num?)?.toInt(),
      slots:
          (json['slots'] as List<dynamic>?)
              ?.map((e) => MealSlotModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$WeekPlanModelToJson(WeekPlanModel instance) =>
    <String, dynamic>{
      'package': instance.package?.toJson(),
      'week': instance.week,
      'slots': instance.slots?.map((e) => e.toJson()).toList(),
    };
