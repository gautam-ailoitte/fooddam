// lib/src/data/model/order_model.dart (UPDATED)
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/cloud_kitchen_model.dart';
import 'package:foodam/src/data/model/user_model.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

import 'dish/dish_model.dart';

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderModel {
  final String? id;
  final String? orderNumber;
  final DateTime? deliveryDate;
  final String? status;
  final UserModel? user;
  final String? timing;
  final AddressModel? address;
  final String? deliveryInstructions;
  final DishModel? dish;
  final CloudKitchenModel? cloudKitchen;
  final int? noOfPersons;

  static final LoggerService _logger = LoggerService();

  OrderModel({
    this.id,
    this.orderNumber,
    this.deliveryDate,
    this.status,
    this.user,
    this.timing,
    this.address,
    this.deliveryInstructions,
    this.dish,
    this.cloudKitchen,
    this.noOfPersons,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      _logger.d('===== Creating OrderModel from JSON =====', tag: 'OrderModel');
      _logger.d('Input JSON keys: ${json.keys.join(', ')}', tag: 'OrderModel');

      // Parse delivery date with UTC to local conversion
      DateTime? parsedDeliveryDate;
      if (json['deliveryDate'] != null) {
        try {
          final utcDate = DateTime.parse(json['deliveryDate']);
          // Convert UTC to local time
          parsedDeliveryDate = utcDate.toLocal();
          _logger.d(
            'Parsed delivery date: UTC=${json['deliveryDate']}, Local=$parsedDeliveryDate',
            tag: 'OrderModel',
          );
        } catch (e) {
          _logger.e('Error parsing deliveryDate: $e', tag: 'OrderModel');
        }
      }

      // Parse dish (required field)
      DishModel? dishModel;
      if (json['dish'] != null && json['dish'] is Map) {
        try {
          dishModel = DishModel.fromJson(
            Map<String, dynamic>.from(json['dish']),
          );
          _logger.d(
            'DishModel parsed successfully: ${dishModel.name}',
            tag: 'OrderModel',
          );
        } catch (e) {
          _logger.e('Error parsing dish: $e', tag: 'OrderModel');
        }
      }

      // Parse user (optional)
      UserModel? userModel;
      if (json['user'] != null && json['user'] is Map) {
        try {
          userModel = UserModel.fromJson(
            Map<String, dynamic>.from(json['user']),
          );
          _logger.d('UserModel parsed successfully', tag: 'OrderModel');
        } catch (e) {
          _logger.e('Error parsing user: $e', tag: 'OrderModel');
        }
      }

      // Parse address (optional)
      AddressModel? addressModel;
      if (json['address'] != null && json['address'] is Map) {
        try {
          addressModel = AddressModel.fromJson(
            Map<String, dynamic>.from(json['address']),
          );
          _logger.d('AddressModel parsed successfully', tag: 'OrderModel');
        } catch (e) {
          _logger.e('Error parsing address: $e', tag: 'OrderModel');
        }
      }

      // Parse cloud kitchen (optional)
      CloudKitchenModel? cloudKitchenModel;
      if (json['cloudKitchen'] != null && json['cloudKitchen'] is Map) {
        try {
          cloudKitchenModel = CloudKitchenModel.fromJson(
            Map<String, dynamic>.from(json['cloudKitchen']),
          );
          _logger.d('CloudKitchenModel parsed successfully', tag: 'OrderModel');
        } catch (e) {
          _logger.e('Error parsing cloudKitchen: $e', tag: 'OrderModel');
        }
      }

      final orderModel = OrderModel(
        id: json['id']?.toString(),
        orderNumber: json['orderNumber']?.toString(),
        deliveryDate: parsedDeliveryDate,
        status: json['status']?.toString(),
        user: userModel,
        timing: json['timing']?.toString(),
        address: addressModel,
        deliveryInstructions: json['deliveryInstructions']?.toString(),
        dish: dishModel,
        cloudKitchen: cloudKitchenModel,
        noOfPersons:
            json['noOfPersons'] is int
                ? json['noOfPersons']
                : int.tryParse(json['noOfPersons']?.toString() ?? '1') ?? 1,
      );

      _logger.d('OrderModel creation complete', tag: 'OrderModel');
      return orderModel;
    } catch (e, stackTrace) {
      _logger.e(
        'Error creating OrderModel from JSON',
        error: e,
        tag: 'OrderModel',
      );
      _logger.e('Stack trace: $stackTrace', tag: 'OrderModel');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  /// Convert API status string to OrderStatus enum
  static OrderStatus _mapStringToOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ontheway':
      case 'on_the_way':
      case 'on-the-way':
        return OrderStatus.onTheWay;
      default:
        return OrderStatus.pending; // Default fallback
    }
  }

  /// Convert OrderStatus enum to API string
  static String _mapOrderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.onTheWay:
        return 'onTheWay';
    }
  }

  /// Mapper to convert model to entity
  Order toEntity() {
    return Order(
      id: id,
      orderNumber: orderNumber,
      dish: dish?.toEntity(),
      timing: timing,
      user: user?.toEntity(),
      address: address?.toEntity(),
      deliveryDate: deliveryDate,
      status: _mapStringToOrderStatus(status),
      deliveryInstructions: deliveryInstructions,
      cloudKitchen: cloudKitchen?.toEntity(),
      noOfPersons: noOfPersons,
    );
  }

  /// Mapper to convert entity to model
  factory OrderModel.fromEntity(Order entity) {
    return OrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      dish: entity.dish != null ? DishModel.fromEntity(entity.dish!) : null,
      timing: entity.timing,
      user: entity.user != null ? UserModel.fromEntity(entity.user!) : null,
      address:
          entity.address != null
              ? AddressModel.fromEntity(entity.address!)
              : null,
      deliveryDate: entity.deliveryDate,
      status:
          entity.status != null
              ? _mapOrderStatusToString(entity.status!)
              : null,
      deliveryInstructions: entity.deliveryInstructions,
      cloudKitchen:
          entity.cloudKitchen != null
              ? CloudKitchenModel.fromEntity(entity.cloudKitchen!)
              : null,
      noOfPersons: entity.noOfPersons,
    );
  }
}
