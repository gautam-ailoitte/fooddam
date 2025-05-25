// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String?,
  orderNumber: json['orderNumber'] as String?,
  deliveryDate:
      json['deliveryDate'] == null
          ? null
          : DateTime.parse(json['deliveryDate'] as String),
  status: json['status'] as String?,
  user:
      json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
  timing: json['timing'] as String?,
  address:
      json['address'] == null
          ? null
          : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
  deliveryInstructions: json['deliveryInstructions'] as String?,
  dish:
      json['dish'] == null
          ? null
          : DishModel.fromJson(json['dish'] as Map<String, dynamic>),
  cloudKitchen:
      json['cloudKitchen'] == null
          ? null
          : CloudKitchenModel.fromJson(
            json['cloudKitchen'] as Map<String, dynamic>,
          ),
  noOfPersons: (json['noOfPersons'] as num?)?.toInt(),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'deliveryDate': instance.deliveryDate?.toIso8601String(),
      'status': instance.status,
      'user': instance.user?.toJson(),
      'timing': instance.timing,
      'address': instance.address?.toJson(),
      'deliveryInstructions': instance.deliveryInstructions,
      'dish': instance.dish?.toJson(),
      'cloudKitchen': instance.cloudKitchen?.toJson(),
      'noOfPersons': instance.noOfPersons,
    };
