// lib/src/domain/entities/susbcription_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

class Subscription extends Equatable {
  final String id;
  final DateTime startDate;
  final int durationDays;
  final String packageId;
  final Package? package;
  final Address address;
  final String? instructions;
  final List<MealSlot> slots;
  final PaymentStatus paymentStatus;
  final bool isPaused;
  final SubscriptionStatus status;
  final String? cloudKitchen;
  final Map<String, dynamic>? paymentDetails;

  const Subscription({
    required this.id,
    required this.startDate,
    required this.durationDays,
    required this.packageId,
    this.package,
    required this.address,
    this.instructions,
    required this.slots,
    required this.paymentStatus,
    required this.isPaused,
    required this.status,
    this.cloudKitchen,
    this.paymentDetails,
  });

  @override
  List<Object?> get props => [
        id,
        startDate,
        durationDays,
        packageId,
        package,
        address,
        instructions,
        slots,
        paymentStatus,
        isPaused,
        status,
        cloudKitchen,
        paymentDetails,
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
