// lib/src/data/model/order_model.dart
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

import '../../domain/entities/order_entity.dart';

class OrderModel {
  final MealModel meal;
  final String timing;
  final UserModel? user;
  final AddressModel? address;
  final String subscriptionId;
  final DateTime date;
  final OrderStatus status;
  final DateTime? deliveredAt;

  OrderModel({
    required this.meal,
    required this.timing,
    this.user,
    this.address,
    required this.subscriptionId,
    required this.date,
    this.status = OrderStatus.coming, // Default status
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final mealJson = json['meal'] as Map<String, dynamic>;
    final mealModel = MealModel.fromJson(mealJson);

    // Parse user if available
    UserModel? userModel;
    if (json['user'] != null &&
        json['user'] is Map &&
        (json['user'] as Map).isNotEmpty) {
      userModel = UserModel.fromJson(Map<String, dynamic>.from(json['user']));
    }

    // Parse address if available
    AddressModel? addressModel;
    if (json['address'] != null &&
        json['address'] is Map &&
        (json['address'] as Map).isNotEmpty) {
      addressModel = AddressModel.fromJson(
        Map<String, dynamic>.from(json['address']),
      );
    }

    // Parse the date
    final DateTime orderDate =
        json['date'] != null ? DateTime.parse(json['date']) : DateTime.now();

    // Determine status based on date and current time
    final OrderStatus orderStatus = _determineOrderStatus(
      orderDate,
      json['timing'],
    );

    return OrderModel(
      meal: mealModel,
      timing: json['timing'],
      user: userModel,
      address: addressModel,
      subscriptionId: json['subscriptionId'] ?? '',
      date: orderDate,
      status: orderStatus,
      deliveredAt: orderStatus == OrderStatus.delivered ? DateTime.now() : null,
    );
  }

  // Helper method to determine order status based on date and timing
  static OrderStatus _determineOrderStatus(DateTime orderDate, String timing) {
    final now = DateTime.now();

    // If the date is in the past, mark as delivered
    if (orderDate.isBefore(now) && !_isToday(orderDate)) {
      return OrderStatus.delivered;
    }

    // If it's today, check the timing
    if (_isToday(orderDate)) {
      final int hour = now.hour;

      // Estimate delivery time based on meal timing
      if (timing.toLowerCase() == 'breakfast' && hour >= 11) {
        return OrderStatus.delivered;
      } else if (timing.toLowerCase() == 'lunch' && hour >= 16) {
        return OrderStatus.delivered;
      } else if (timing.toLowerCase() == 'dinner' && hour >= 22) {
        return OrderStatus.delivered;
      }
    }

    // If none of the above conditions are met, the order is coming
    return OrderStatus.coming;
  }

  // Helper to check if a date is today
  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Map<String, dynamic> toJson() {
    return {
      'meal': meal.toJson(),
      'timing': timing,
      'user': user?.toJson(),
      'address': address?.toJson(),
      'subscriptionId': subscriptionId,
      'date': date.toIso8601String(),
    };
  }

  // Mapper to convert model to entity
  Order toEntity() {
    return Order(
      meal: meal.toEntity(),
      timing: timing,
      subscriptionId: subscriptionId,
      date: date,
      status: status,
      deliveredAt: deliveredAt,
    );
  }

  // Mapper to convert entity to model
  factory OrderModel.fromEntity(Order entity) {
    return OrderModel(
      meal: MealModel.fromEntity(entity.meal),
      timing: entity.timing,
      subscriptionId: entity.subscriptionId,
      date: entity.date,
      status: entity.status,
      deliveredAt: entity.deliveredAt,
    );
  }
}
