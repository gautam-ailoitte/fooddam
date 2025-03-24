// lib/src/domain/entities/subscription_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';

class Subscription extends Equatable {
  final String id;
  final DateTime startDate;
  final int durationDays;
  final String packageId;
  final Address address;
  final String? instructions;
  final List<MealSlot> slots;
  final PaymentStatus paymentStatus;
  final bool isPaused;
  final SubscriptionStatus status;
  final String? cloudKitchen;

  const Subscription({
    required this.id,
    required this.startDate,
    required this.durationDays,
    required this.packageId,
    required this.address,
    this.instructions,
    required this.slots,
    required this.paymentStatus,
    required this.isPaused,
    required this.status,
    this.cloudKitchen,
  });

  @override
  List<Object?> get props => [
        id,
        startDate,
        durationDays,
        packageId,
        address,
        instructions,
        slots,
        paymentStatus,
        isPaused,
        status,
        cloudKitchen,
      ];
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

enum SubscriptionStatus {
  pending,
  active,
  paused,
  cancelled,
  expired,
}
