// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_kitchen_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudKitchenModel _$CloudKitchenModelFromJson(Map<String, dynamic> json) =>
    CloudKitchenModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      address:
          json['address'] == null
              ? null
              : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CloudKitchenModelToJson(CloudKitchenModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address?.toJson(),
    };
