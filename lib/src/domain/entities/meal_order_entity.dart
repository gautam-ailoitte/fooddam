// lib/src/domain/entities/meal_order_entity.dart

import 'package:equatable/equatable.dart';

/// Status of a meal order
enum OrderStatus {
  /// Meal is scheduled and on the way
  coming,
  
  /// Meal has been delivered
  delivered,
  
  /// No meal chosen for this slot by the user
  notChosen,
  
  /// No meal scheduled for this slot
  noMeal,
}

/// Represents a meal order for today
///
/// This entity is constructed on the client-side based on
/// subscription data and the current day's meal schedule.
class MealOrder extends Equatable {
  /// Unique identifier for the order (client-generated)
  final String id;
  
  /// ID of the subscription this meal belongs to
  final String subscriptionId;
  
  /// ID of the meal
  final String mealId;
  
  /// Name of the meal
  final String mealName;
  
  /// Type of meal (Breakfast, Lunch, Dinner)
  final String mealType;
  
  /// Current status of the order
  final OrderStatus status;
  
  /// Date of the order (today's date)
  final DateTime orderDate;
  
  /// Expected delivery time
  final DateTime expectedTime;
  
  /// Actual delivery time (null if not delivered yet)
  final DateTime? deliveredAt;

  const MealOrder({
    required this.id,
    required this.subscriptionId,
    required this.mealId,
    required this.mealName,
    required this.mealType,
    required this.status,
    required this.orderDate,
    required this.expectedTime,
    this.deliveredAt,
  });

  @override
  List<Object?> get props => [
    id,
    subscriptionId,
    mealId,
    mealName,
    mealType,
    status,
    orderDate,
    expectedTime,
    deliveredAt,
  ];
  
  // Helper methods
  
  /// Check if this is a breakfast meal
  bool get isBreakfast => mealType.toLowerCase() == 'breakfast';
  
  /// Check if this is a lunch meal
  bool get isLunch => mealType.toLowerCase() == 'lunch';
  
  /// Check if this is a dinner meal
  bool get isDinner => mealType.toLowerCase() == 'dinner';
  
  /// Check if this meal is upcoming (not delivered yet)
  bool get isUpcoming => status == OrderStatus.coming;
  
  /// Check if this meal has been delivered
  bool get isDelivered => status == OrderStatus.delivered;
  
  /// Get the number of minutes until delivery
  int get minutesUntilDelivery {
    if (isDelivered) return 0;
    
    final now = DateTime.now();
    return expectedTime.difference(now).inMinutes;
  }
  
  /// Copy with new values
  MealOrder copyWith({
    String? id,
    String? subscriptionId,
    String? mealId,
    String? mealName,
    String? mealType,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? expectedTime,
    DateTime? deliveredAt,
  }) {
    return MealOrder(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      mealId: mealId ?? this.mealId,
      mealName: mealName ?? this.mealName,
      mealType: mealType ?? this.mealType,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      expectedTime: expectedTime ?? this.expectedTime,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}