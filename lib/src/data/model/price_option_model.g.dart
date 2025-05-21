// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceOptionModel _$PriceOptionModelFromJson(Map<String, dynamic> json) =>
    PriceOptionModel(
      numberOfMeals: (json['numberOfMeals'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PriceOptionModelToJson(PriceOptionModel instance) =>
    <String, dynamic>{
      'numberOfMeals': instance.numberOfMeals,
      'price': instance.price,
    };
