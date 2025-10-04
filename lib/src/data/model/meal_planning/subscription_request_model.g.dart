// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionRequestModel _$SubscriptionRequestModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionRequestModel(
  startDate: DateTime.parse(json['startDate'] as String),
  address: json['address'] as String,
  instructions: json['instructions'] as String,
  noOfPersons: (json['noOfPersons'] as num).toInt(),
  weeks:
      (json['weeks'] as List<dynamic>)
          .map((e) => WeekRequestDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$SubscriptionRequestModelToJson(
  SubscriptionRequestModel instance,
) => <String, dynamic>{
  'startDate': instance.startDate.toIso8601String(),
  'address': instance.address,
  'instructions': instance.instructions,
  'noOfPersons': instance.noOfPersons,
  'weeks': instance.weeks.map((e) => e.toJson()).toList(),
};

WeekRequestDataModel _$WeekRequestDataModelFromJson(
  Map<String, dynamic> json,
) => WeekRequestDataModel(
  dietaryPreference: json['dietaryPreference'] as String,
  slots: (json['slots'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$WeekRequestDataModelToJson(
  WeekRequestDataModel instance,
) => <String, dynamic>{
  'dietaryPreference': instance.dietaryPreference,
  'slots': instance.slots,
};

SubscriptionResponseModel _$SubscriptionResponseModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionResponseModel(
  id: json['id'] as String?,
  status: json['status'] as String?,
  message: json['message'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  totalAmount: (json['totalAmount'] as num?)?.toDouble(),
  additionalData: json['additionalData'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SubscriptionResponseModelToJson(
  SubscriptionResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'message': instance.message,
  'createdAt': instance.createdAt?.toIso8601String(),
  'totalAmount': instance.totalAmount,
  'additionalData': instance.additionalData,
};
