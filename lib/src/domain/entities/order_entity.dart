// lib/src/domain/entities/order_entity.dart

import 'package:equatable/equatable.dart';
import 'address_entity.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded
}

class OrderedMeal extends Equatable {
  final String mealType; // breakfast, lunch, dinner
  final String dietPreference; // vegetarian, non-vegetarian, etc.
  final int quantity;

  const OrderedMeal({
    required this.mealType,
    required this.dietPreference,
    required this.quantity,
  });

  @override
  List<Object?> get props => [mealType, dietPreference, quantity];
}

class Order extends Equatable {
  final String id;
  final String orderNumber;
  final String userId;
  final String subscriptionId;
  final DateTime deliveryDate;
  final Address deliveryAddress;
  final String? cloudKitchenId;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double totalAmount;
  final List<OrderedMeal> meals;
  final String? deliveryInstructions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.subscriptionId,
    required this.deliveryDate,
    required this.deliveryAddress,
    this.cloudKitchenId,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.meals,
    this.deliveryInstructions,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    userId,
    subscriptionId,
    deliveryDate,
    deliveryAddress,
    cloudKitchenId,
    status,
    paymentStatus,
    totalAmount,
    meals,
    deliveryInstructions,
    createdAt,
    updatedAt,
  ];
}