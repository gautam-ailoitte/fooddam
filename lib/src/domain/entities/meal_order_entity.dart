

// lib/src/domain/entities/meal_order.dart
import 'package:equatable/equatable.dart';

class MealOrder extends Equatable {
  final String id;
  final String subscriptionId;
  final DateTime deliveryDate;
  final String mealType; // breakfast, lunch, dinner
  final String mealId;
  final String mealName;
  final OrderStatus status;
  final DateTime? deliveredAt;
  final DateTime expectedTime;

  const MealOrder({
    required this.id,
    required this.subscriptionId,
    required this.deliveryDate,
    required this.mealType,
    required this.mealId,
    required this.mealName,
    required this.status,
    this.deliveredAt,
    required this.expectedTime,
  });

  @override
  List<Object?> get props => [
        id,
        subscriptionId,
        deliveryDate,
        mealType,
        mealId,
        mealName,
        status,
        deliveredAt,
        expectedTime,
      ];
}

enum OrderStatus {
  coming,
  delivered,
  noMeal,
  notChosen,
}