import 'package:json_annotation/json_annotation.dart';

part 'price_range_model.g.dart';

@JsonSerializable()
class PriceRangeModel {
  final double? min;
  final double? max;

  PriceRangeModel({this.min, this.max});

  factory PriceRangeModel.fromJson(Map<String, dynamic> json) =>
      _$PriceRangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$PriceRangeModelToJson(this);
}
