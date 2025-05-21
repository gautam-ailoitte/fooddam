import 'package:json_annotation/json_annotation.dart';

part 'price_option_model.g.dart';

@JsonSerializable()
class PriceOptionModel {
  final int? numberOfMeals;
  final double? price;

  PriceOptionModel({this.numberOfMeals, this.price});

  factory PriceOptionModel.fromJson(Map<String, dynamic> json) =>
      _$PriceOptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PriceOptionModelToJson(this);
}
