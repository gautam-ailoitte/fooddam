// lib/src/data/models/meal_planning/subscription_request_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'subscription_request_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SubscriptionRequestModel {
  final DateTime startDate;
  final String address;
  final String instructions;
  final int noOfPersons;
  final List<WeekRequestDataModel> weeks;

  SubscriptionRequestModel({
    required this.startDate,
    required this.address,
    required this.instructions,
    required this.noOfPersons,
    required this.weeks,
  });

  factory SubscriptionRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionRequestModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WeekRequestDataModel {
  final String dietaryPreference;
  final List<String> slots;

  WeekRequestDataModel({required this.dietaryPreference, required this.slots});

  factory WeekRequestDataModel.fromJson(Map<String, dynamic> json) =>
      _$WeekRequestDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeekRequestDataModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SubscriptionResponseModel {
  final String? id;
  final String? status;
  final String? message;
  final DateTime? createdAt;
  final double? totalAmount;
  final Map<String, dynamic>? additionalData;

  SubscriptionResponseModel({
    this.id,
    this.status,
    this.message,
    this.createdAt,
    this.totalAmount,
    this.additionalData,
  });

  factory SubscriptionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionResponseModelToJson(this);
}
