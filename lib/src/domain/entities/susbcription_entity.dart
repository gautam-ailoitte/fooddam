// lib/src/domain/entities/subscription_entity.dart
// This replaces the previous plan_entity.dart

import 'package:equatable/equatable.dart';
import 'address_entity.dart';
import 'dish_entity.dart'; // For DietaryPreference

enum SubscriptionDuration {
  sevenDays,
  fourteenDays,
  twentyEightDays,
  monthly,
  quarterly,
  halfYearly,
  yearly, days30
}

enum SubscriptionStatus {
  active,
  paused,
  cancelled,
  expired
}

class MealPreference extends Equatable {
  final String mealType; // breakfast, lunch, dinner
  final List<DietaryPreference> preferences;
  final int quantity;
  final List<String>? excludedIngredients;

  const MealPreference({
    required this.mealType,
    required this.preferences,
    required this.quantity,
    this.excludedIngredients,
  });

  @override
  List<Object?> get props => [mealType, preferences, quantity, excludedIngredients];
}

class DeliverySchedule extends Equatable {
  final List<int> daysOfWeek; // 1-7 representing Monday-Sunday
  final String preferredTimeSlot; // e.g., "morning", "afternoon", "evening"
  
  const DeliverySchedule({
    required this.daysOfWeek,
    required this.preferredTimeSlot,
  });
  
  @override
  List<Object?> get props => [daysOfWeek, preferredTimeSlot];
}

class Subscription extends Equatable {
  final String id;
  final String userId;
  final SubscriptionDuration duration;
  final DateTime startDate;
  final DateTime endDate;
  final SubscriptionStatus status;
  final double basePrice;
  final double totalPrice;
  final bool isCustomized;
  final List<MealPreference> mealPreferences;
  final DeliverySchedule deliverySchedule;
  final Address deliveryAddress;
  final String? paymentMethodId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.basePrice,
    required this.totalPrice,
    required this.isCustomized,
    required this.mealPreferences,
    required this.deliverySchedule,
    required this.deliveryAddress,
    this.paymentMethodId,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == SubscriptionStatus.active;
  
  int get durationInDays {
    switch (duration) {
      case SubscriptionDuration.sevenDays:
        return 7;
      case SubscriptionDuration.fourteenDays:
        return 14;
      case SubscriptionDuration.twentyEightDays:
        return 28;
      case SubscriptionDuration.monthly:
        return 30;
      case SubscriptionDuration.quarterly:
        return 90;
      case SubscriptionDuration.halfYearly:
        return 180;
      case SubscriptionDuration.yearly:
        return 365;
      case SubscriptionDuration.days30:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    duration,
    startDate,
    endDate,
    status,
    basePrice,
    totalPrice,
    isCustomized,
    mealPreferences,
    deliverySchedule,
    deliveryAddress,
    paymentMethodId,
    createdAt,
    updatedAt,
  ];
}