
import 'package:foodam/src/domain/entities/meal_order_entity.dart';

class MealOrderModel extends MealOrder {
  const MealOrderModel({
    required super.id,
    required super.subscriptionId,
    required super.deliveryDate,
    required super.mealType,
    required super.mealId,
    required super.mealName,
    required super.status,
    super.deliveredAt,
    required super.expectedTime,
  });

  factory MealOrderModel.fromJson(Map<String, dynamic> json) {
    return MealOrderModel(
      id: json['id'],
      subscriptionId: json['subscriptionId'],
      deliveryDate: DateTime.parse(json['deliveryDate']),
      mealType: json['mealType'],
      mealId: json['mealId'],
      mealName: json['mealName'],
      status: _mapStringToOrderStatus(json['status']),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      expectedTime: DateTime.parse(json['expectedTime']),
    );
  }

  static OrderStatus _mapStringToOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'coming':
        return OrderStatus.coming;
      case 'delivered':
        return OrderStatus.delivered;
      case 'no_meal':
        return OrderStatus.noMeal;
      case 'not_chosen':
        return OrderStatus.notChosen;
      default:
        return OrderStatus.coming;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'deliveryDate': deliveryDate.toIso8601String(),
      'mealType': mealType,
      'mealId': mealId,
      'mealName': mealName,
      'status': _mapOrderStatusToString(status),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'expectedTime': expectedTime.toIso8601String(),
    };
  }

  static String _mapOrderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.coming:
        return 'coming';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.noMeal:
        return 'no_meal';
      case OrderStatus.notChosen:
        return 'not_chosen';
    }
  }
}

