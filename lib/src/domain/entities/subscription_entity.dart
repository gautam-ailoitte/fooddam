// lib/src/domain/entities/subscription.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';

class Subscription extends Equatable {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String planId;
  final Address deliveryAddress;
  final String deliveryInstructions;
  final PaymentStatus paymentStatus;
  final bool isPaused;
  final SubscriptionPlan subscriptionPlan;
  final SubscriptionStatus status;

  const Subscription({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.planId,
    required this.deliveryAddress,
    required this.deliveryInstructions,
    required this.paymentStatus,
    required this.isPaused,
    required this.subscriptionPlan,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        startDate,
        endDate,
        planId,
        deliveryAddress,
        deliveryInstructions,
        paymentStatus,
        isPaused,
        subscriptionPlan,
        status,
      ];
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

enum SubscriptionStatus {
  active,
  paused,
  cancelled,
  expired,
}