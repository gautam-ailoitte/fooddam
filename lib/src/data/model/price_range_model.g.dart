// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_range_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceRangeModel _$PriceRangeModelFromJson(Map<String, dynamic> json) =>
    PriceRangeModel(
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PriceRangeModelToJson(PriceRangeModel instance) =>
    <String, dynamic>{'min': instance.min, 'max': instance.max};
