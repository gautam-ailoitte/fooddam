// lib/src/domain/entities/meal_order_entity.dart
import 'package:equatable/equatable.dart';

enum OrderStatus {
  coming,   // Meal is on the way
  delivered, // Meal has been delivered
  notChosen, // No meal chosen for this slot
  noMeal,    // No meal scheduled for this slot
}

class MealOrder extends Equatable {
  final String id;
  final String subscriptionId;
  final String mealId;
  final String mealName;
  final String mealType; // Breakfast, Lunch, Dinner
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime expectedTime;
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
  
  // Helper to check if this is for today
  bool get isForToday {
    final now = DateTime.now();
    return orderDate.year == now.year && 
           orderDate.month == now.month && 
           orderDate.day == now.day;
  }
  
  // Helper to check if the meal is upcoming (not delivered yet)
  bool get isUpcoming => status == OrderStatus.coming;
  
  // Helper to check if the meal has been delivered
  bool get isDelivered => status == OrderStatus.delivered;
  
  // Helper to check if it's breakfast
  bool get isBreakfast => mealType == 'Breakfast';
  
  // Helper to check if it's lunch
  bool get isLunch => mealType == 'Lunch';
  
  // Helper to check if it's dinner
  bool get isDinner => mealType == 'Dinner';
}