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
      estimatedPrice: (json['estimatedPrice'] as num?)?.toInt(),
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
  'estimatedPrice': instance.estimatedPrice,
  'package': instance.package?.toJson(),
  'dailyMeals': instance.dailyMeals?.map((e) => e.toJson()).toList(),
};

DailyMealModel _$DailyMealModelFromJson(Map<String, dynamic> json) =>
    DailyMealModel(
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      day: json['day'] as String?,
      meal:
          json['meal'] == null
              ? null
              : DayMealModel.fromJson(json['meal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DailyMealModelToJson(DailyMealModel instance) =>
    <String, dynamic>{
      'date': instance.date?.toIso8601String(),
      'day': instance.day,
      'meal': instance.meal?.toJson(),
    };

DayMealModel _$DayMealModelFromJson(Map<String, dynamic> json) => DayMealModel(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  dietaryPreference: json['dietaryPreference'] as String?,
  price: (json['price'] as num?)?.toInt(),
  dishes: (json['dishes'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, MealDishModel.fromJson(e as Map<String, dynamic>)),
  ),
  image:
      json['image'] == null
          ? null
          : MealImageModel.fromJson(json['image'] as Map<String, dynamic>),
  isAvailable: json['isAvailable'] as bool?,
);

Map<String, dynamic> _$DayMealModelToJson(DayMealModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'dietaryPreference': instance.dietaryPreference,
      'price': instance.price,
      'dishes': instance.dishes?.map((k, e) => MapEntry(k, e.toJson())),
      'image': instance.image?.toJson(),
      'isAvailable': instance.isAvailable,
    };

MealDishModel _$MealDishModelFromJson(Map<String, dynamic> json) =>
    MealDishModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toInt(),
      dietaryPreference: json['dietaryPreference'] as String?,
      isAvailable: json['isAvailable'] as bool?,
      image:
          json['image'] == null
              ? null
              : MealImageModel.fromJson(json['image'] as Map<String, dynamic>),
      key: json['key'] as String?,
    );

Map<String, dynamic> _$MealDishModelToJson(MealDishModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'dietaryPreference': instance.dietaryPreference,
      'isAvailable': instance.isAvailable,
      'image': instance.image?.toJson(),
      'key': instance.key,
    };

MealImageModel _$MealImageModelFromJson(Map<String, dynamic> json) =>
    MealImageModel(
      id: json['id'] as String?,
      url: json['url'] as String?,
      key: json['key'] as String?,
      fileName: json['fileName'] as String?,
    );

Map<String, dynamic> _$MealImageModelToJson(MealImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'key': instance.key,
      'fileName': instance.fileName,
    };
