// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      id: json['id'] as String?,
      startDate:
          json['startDate'] == null
              ? null
              : DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] == null
              ? null
              : DateTime.parse(json['endDate'] as String),
      durationDays: (json['durationDays'] as num?)?.toInt(),
      noOfPersons: (json['noOfPersons'] as num?)?.toInt(),
      weeks:
          (json['weeks'] as List<dynamic>?)
              ?.map((e) => WeekPlanModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalSlots: (json['totalSlots'] as num?)?.toInt(),
      subscriptionStatus: json['subscriptionStatus'] as String?,
      subscriptionPrice: (json['subscriptionPrice'] as num?)?.toDouble(),
      cloudKitchen: json['cloudKitchen'] as Map<String, dynamic>?,
      paymentDetails: json['paymentDetails'] as Map<String, dynamic>?,
      address:
          json['address'] == null
              ? null
              : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
      user:
          json['user'] == null
              ? null
              : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      instructions: json['instructions'] as String?,
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'durationDays': instance.durationDays,
      'noOfPersons': instance.noOfPersons,
      'weeks': instance.weeks?.map((e) => e.toJson()).toList(),
      'totalSlots': instance.totalSlots,
      'subscriptionStatus': instance.subscriptionStatus,
      'subscriptionPrice': instance.subscriptionPrice,
      'cloudKitchen': instance.cloudKitchen,
      'paymentDetails': instance.paymentDetails,
      'address': instance.address?.toJson(),
      'user': instance.user?.toJson(),
      'instructions': instance.instructions,
    };
