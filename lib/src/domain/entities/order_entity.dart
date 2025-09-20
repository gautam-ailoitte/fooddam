// lib/src/domain/entities/order_entity.dart (UPDATED)
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/cloud_kitchen_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

import 'dish/dish_entity.dart';

/// Status of an order - Updated to match API response
enum OrderStatus {
  /// Order is pending/scheduled
  pending,

  /// Order has been delivered
  delivered,

  /// Order is cancelled
  cancelled,

  /// Order is being prepared
  preparing,

  /// Order is on the way
  onTheWay,
}

/// Represents an order from the API
class Order extends Equatable {
  /// Unique order ID
  final String? id;

  /// Human readable order number
  final String? orderNumber;

  /// The dish details (not meal)
  final Dish? dish;

  /// Meal timing (breakfast, lunch, dinner)
  final String? timing;

  /// User who placed the order
  final User? user;

  /// Delivery address
  final Address? address;

  /// Delivery date (converted to local time)
  final DateTime? deliveryDate;

  /// Current status of the order
  final OrderStatus? status;

  /// Special delivery instructions
  final String? deliveryInstructions;

  /// Cloud kitchen preparing the order
  final CloudKitchen? cloudKitchen;

  /// Number of persons this order serves
  final int? noOfPersons;

  const Order({
    this.id,
    this.orderNumber,
    this.dish,
    this.timing,
    this.user,
    this.address,
    this.deliveryDate,
    this.status,
    this.deliveryInstructions,
    this.cloudKitchen,
    this.noOfPersons,
  });

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    dish,
    timing,
    user,
    address,
    deliveryDate,
    status,
    deliveryInstructions,
    cloudKitchen,
    noOfPersons,
  ];

  // Helper methods

  /// Check if this is a breakfast order
  bool get isBreakfast => timing?.toLowerCase() == 'breakfast';

  /// Check if this is a lunch order
  bool get isLunch => timing?.toLowerCase() == 'lunch';

  /// Check if this is a dinner order
  bool get isDinner => timing?.toLowerCase() == 'dinner';

  /// Check if this order is pending
  bool get isPending => status == OrderStatus.pending;

  /// Check if this order has been delivered
  bool get isDelivered => status == OrderStatus.delivered;

  /// Check if this order is upcoming (pending and future date)
  bool get isUpcoming {
    if (status != OrderStatus.pending || deliveryDate == null) return false;
    final now = DateTime.now();
    return deliveryDate!.isAfter(now) || _isToday;
  }

  /// Get the formatted meal type (Breakfast, Lunch, Dinner)
  String get mealType {
    if (timing == null || timing!.isEmpty) return 'Meal';
    return timing!.substring(0, 1).toUpperCase() + timing!.substring(1);
  }

  /// Check if this order is for today
  bool get _isToday {
    if (deliveryDate == null) return false;
    final now = DateTime.now();
    return deliveryDate!.year == now.year &&
        deliveryDate!.month == now.month &&
        deliveryDate!.day == now.day;
  }

  /// Check if this order is for today (public getter)
  bool get isToday => _isToday;

  /// Check if this order is for tomorrow
  bool get isTomorrow {
    if (deliveryDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return deliveryDate!.year == tomorrow.year &&
        deliveryDate!.month == tomorrow.month &&
        deliveryDate!.day == tomorrow.day;
  }

  /// Check if this order is in the past
  bool get isPast {
    if (deliveryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(
      deliveryDate!.year,
      deliveryDate!.month,
      deliveryDate!.day,
    );
    return orderDate.isBefore(today);
  }

  /// Get estimated delivery time based on meal timing
  DateTime? get estimatedDeliveryTime {
    if (deliveryDate == null) return null;

    // Set time based on meal type
    int hour, minute;
    switch (timing?.toLowerCase()) {
      case 'breakfast':
        hour = 8;
        minute = 0;
        break;
      case 'lunch':
        hour = 12;
        minute = 30;
        break;
      case 'dinner':
        hour = 19;
        minute = 0;
        break;
      default:
        hour = 12;
        minute = 0;
    }

    return DateTime(
      deliveryDate!.year,
      deliveryDate!.month,
      deliveryDate!.day,
      hour,
      minute,
    );
  }

  /// Get the number of minutes until delivery
  int get minutesUntilDelivery {
    final estimatedTime = estimatedDeliveryTime;
    if (estimatedTime == null || isDelivered) return 0;

    final now = DateTime.now();
    if (now.isAfter(estimatedTime)) return 0;

    return estimatedTime.difference(now).inMinutes;
  }

  /// Get formatted status text
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return isToday ? 'Coming Today' : 'Scheduled';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case null:
        return 'Unknown';
    }
  }

  /// Get status color
  /// Note: In actual implementation, import proper colors from core
  String get statusColorName {
    switch (status) {
      case OrderStatus.pending:
        return 'warning';
      case OrderStatus.delivered:
        return 'success';
      case OrderStatus.cancelled:
        return 'error';
      case OrderStatus.preparing:
        return 'info';
      case OrderStatus.onTheWay:
        return 'primary';
      case null:
        return 'grey';
    }
  }

  /// Get formatted delivery date
  String get formattedDeliveryDate {
    if (deliveryDate == null) return 'Unknown date';

    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';

    // Format as "Mon, Jan 15"
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[deliveryDate!.weekday - 1];
    final month = months[deliveryDate!.month - 1];
    return '$weekday, $month ${deliveryDate!.day}';
  }

  /// Copy with new values
  Order copyWith({
    String? id,
    String? orderNumber,
    Dish? dish,
    String? timing,
    User? user,
    Address? address,
    DateTime? deliveryDate,
    OrderStatus? status,
    String? deliveryInstructions,
    CloudKitchen? cloudKitchen,
    int? noOfPersons,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      dish: dish ?? this.dish,
      timing: timing ?? this.timing,
      user: user ?? this.user,
      address: address ?? this.address,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      cloudKitchen: cloudKitchen ?? this.cloudKitchen,
      noOfPersons: noOfPersons ?? this.noOfPersons,
    );
  }
}
