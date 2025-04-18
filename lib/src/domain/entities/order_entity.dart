// lib/src/domain/entities/order_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

/// Status of an order
enum OrderStatus {
  /// Order is scheduled and on the way
  coming,

  /// Order has been delivered
  delivered,

  /// No meal chosen for this order
  notChosen,

  /// No meal scheduled for this order
  noMeal,
}

/// Represents an upcoming or past meal order
class Order extends Equatable {
  /// The meal details
  final Meal meal;

  /// Meal timing (breakfast, lunch, dinner)
  final String timing;

  /// ID of the subscription this order belongs to
  final String subscriptionId;

  /// Date of the order
  final DateTime date;

  /// Current status of the order
  final OrderStatus status;

  /// Actual delivery time (null if not delivered yet)
  final DateTime? deliveredAt;

  const Order({
    required this.meal,
    required this.timing,
    required this.subscriptionId,
    required this.date,
    required this.status,
    this.deliveredAt,
  });

  @override
  List<Object?> get props => [
    meal,
    timing,
    subscriptionId,
    date,
    status,
    deliveredAt,
  ];

  // Helper methods

  /// Check if this is a breakfast meal
  bool get isBreakfast => timing.toLowerCase() == 'breakfast';

  /// Check if this is a lunch meal
  bool get isLunch => timing.toLowerCase() == 'lunch';

  /// Check if this is a dinner meal
  bool get isDinner => timing.toLowerCase() == 'dinner';

  /// Check if this meal is upcoming (not delivered yet)
  bool get isUpcoming => status == OrderStatus.coming;

  /// Check if this meal has been delivered
  bool get isDelivered => status == OrderStatus.delivered;

  /// Get the number of minutes until delivery
  int get minutesUntilDelivery {
    if (isDelivered) return 0;

    final now = DateTime.now();

    // Estimate delivery time based on meal timing
    DateTime expectedDelivery;
    if (isBreakfast) {
      expectedDelivery = DateTime(date.year, date.month, date.day, 8, 0);
    } else if (isLunch) {
      expectedDelivery = DateTime(date.year, date.month, date.day, 12, 30);
    } else {
      expectedDelivery = DateTime(date.year, date.month, date.day, 19, 0);
    }

    if (now.isAfter(expectedDelivery)) return 0;
    return expectedDelivery.difference(now).inMinutes;
  }

  /// Get the formatted meal type (Breakfast, Lunch, Dinner)
  String get mealType =>
      timing.substring(0, 1).toUpperCase() + timing.substring(1);

  /// Check if this order is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Copy with new values
  Order copyWith({
    Meal? meal,
    String? timing,
    String? subscriptionId,
    DateTime? date,
    OrderStatus? status,
    DateTime? deliveredAt,
  }) {
    return Order(
      meal: meal ?? this.meal,
      timing: timing ?? this.timing,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      date: date ?? this.date,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
