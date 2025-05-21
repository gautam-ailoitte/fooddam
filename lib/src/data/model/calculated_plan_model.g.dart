// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculated_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculatedPlanModel _$CalculatedPlanModelFromJson(Map<String, dynamic> json) =>
    CalculatedPlanModel(
      dietaryPreference: json['dietaryPreference'] as String?,
      requestedWeek: json['requestedWeek'] as String?,
      actualSystemWeek: (json['actualSystemWeek'] as num?)?.toInt(),
      startDate:
          json['startDate'] == null
              ? null
              : DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] == null
              ? null
              : DateTime.parse(json['endDate'] as String),
      package:
          json['package'] == null
              ? null
              : PackageModel.fromJson(json['package'] as Map<String, dynamic>),
      dailyMeals:
          (json['dailyMeals'] as List<dynamic>?)
              ?.map((e) => DailyMealModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$CalculatedPlanModelToJson(
  CalculatedPlanModel instance,
) => <String, dynamic>{
  'dietaryPreference': instance.dietaryPreference,
  'requestedWeek': instance.requestedWeek,
  'actualSystemWeek': instance.actualSystemWeek,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'package': instance.package?.toJson(),
  'dailyMeals': instance.dailyMeals?.map((e) => e.toJson()).toList(),
};

DailyMealModel _$DailyMealModelFromJson(Map<String, dynamic> json) =>
    DailyMealModel(
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      slot:
          json['slot'] == null
              ? null
              : DailySlotModel.fromJson(json['slot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DailyMealModelToJson(DailyMealModel instance) =>
    <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'slot': instance.slot?.toJson(),
    };

DailySlotModel _$DailySlotModelFromJson(Map<String, dynamic> json) =>
    DailySlotModel(
      day: json['day'] as String?,
      meal:
          json['meal'] == null
              ? null
              : DayMealModel.fromJson(json['meal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DailySlotModelToJson(DailySlotModel instance) =>
    <String, dynamic>{'day': instance.day, 'meal': instance.meal?.toJson()};
