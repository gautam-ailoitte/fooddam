// lib/src/data/model/order_model.dart
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/user_model.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';

class OrderModel {
  final MealModel meal;
  final String timing;
  final UserModel? user;
  final AddressModel? address;
  final String subscriptionId;
  final DateTime date;
  final OrderStatus status;
  final DateTime? deliveredAt;

  static final LoggerService _logger = LoggerService();

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
    try {
      _logger.d('===== Creating OrderModel from JSON =====', tag: 'OrderModel');

      // Debug the entire JSON input
      _logger.d('Input JSON: $json', tag: 'OrderModel');
      _logger.d('JSON keys: ${json.keys.join(', ')}', tag: 'OrderModel');

      // Check for necessary meal data
      if (json['meal'] == null) {
        _logger.e('Meal data is missing in order JSON', tag: 'OrderModel');
        throw Exception('Missing required meal data in order JSON');
      }

      if (json['meal'] is! Map) {
        _logger.e('Meal data is not a Map: ${json['meal']}', tag: 'OrderModel');
        throw Exception('Meal data is not in the expected format');
      }

      // Debug meal JSON
      _logger.d('Meal JSON: ${json['meal']}', tag: 'OrderModel');

      // Parse Meal Model
      final mealJson = Map<String, dynamic>.from(json['meal'] as Map);
      _logger.d('Creating MealModel from: $mealJson', tag: 'OrderModel');

      final mealModel = MealModel.fromJson(mealJson);
      _logger.d(
        'MealModel created successfully: ${mealModel.name}',
        tag: 'OrderModel',
      );

      // Parse user if available
      UserModel? userModel;
      if (json['user'] != null &&
          json['user'] is Map &&
          (json['user'] as Map).isNotEmpty) {
        _logger.d('Processing user data: ${json['user']}', tag: 'OrderModel');
        try {
          userModel = UserModel.fromJson(
            Map<String, dynamic>.from(json['user']),
          );
          _logger.d('UserModel created successfully', tag: 'OrderModel');
        } catch (e) {
          _logger.e('Error creating UserModel: $e', tag: 'OrderModel');
          // Continue without user data
        }
      }

      // Parse address if available
      AddressModel? addressModel;
      if (json['address'] != null &&
          json['address'] is Map &&
          (json['address'] as Map).isNotEmpty) {
        _logger.d(
          'Processing address data: ${json['address']}',
          tag: 'OrderModel',
        );
        try {
          addressModel = AddressModel.fromJson(
            Map<String, dynamic>.from(json['address']),
          );
          _logger.d('AddressModel created successfully', tag: 'OrderModel');
        } catch (e) {
          _logger.e('Error creating AddressModel: $e', tag: 'OrderModel');
          // Continue without address data
        }
      }

      // Safely get subscriptionId with fallback
      final String subscriptionId = json['subscriptionId'] ?? '';
      _logger.d('SubscriptionId: $subscriptionId', tag: 'OrderModel');

      // Parse the date with validation
      DateTime orderDate;
      try {
        if (json['deliveryDate'] != null) {
          _logger.d(
            'Parsing deliveryDate: ${json['deliveryDate']}',
            tag: 'OrderModel',
          );
          orderDate = DateTime.parse(json['deliveryDate']);
        } else if (json['date'] != null) {
          // Fallback to 'date' for backward compatibility
          _logger.d('Parsing date: ${json['date']}', tag: 'OrderModel');
          orderDate = DateTime.parse(json['date']);
        } else {
          _logger.w(
            'Date is missing, using current date as fallback',
            tag: 'OrderModel',
          );
          orderDate = DateTime.now();
        }
      } catch (e) {
        _logger.e('Error parsing date: $e', tag: 'OrderModel');
        _logger.w('Using current date as fallback', tag: 'OrderModel');
        orderDate = DateTime.now();
      }

      // Safe timing extraction
      String timing = 'lunch'; // Default
      if (json['timing'] != null) {
        timing = json['timing'].toString();
      } else {
        _logger.w(
          'Timing is missing, using "lunch" as default',
          tag: 'OrderModel',
        );
      }
      _logger.d('Timing: $timing', tag: 'OrderModel');

      // Determine status based on date and current time
      final OrderStatus orderStatus = _determineOrderStatus(orderDate, timing);
      _logger.d('Determined order status: $orderStatus', tag: 'OrderModel');

      _logger.d('OrderModel creation complete', tag: 'OrderModel');

      return OrderModel(
        meal: mealModel,
        timing: timing,
        user: userModel,
        address: addressModel,
        subscriptionId: subscriptionId,
        date: orderDate,
        status: orderStatus,
        deliveredAt:
            orderStatus == OrderStatus.delivered ? DateTime.now() : null,
      );
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
