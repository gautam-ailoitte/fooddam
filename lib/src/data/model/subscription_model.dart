

import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/plan_model.dart' ;
import 'package:foodam/src/domain/entities/subscription_entity.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.startDate,
    required super.endDate,
    required super.planId,
    required super.deliveryAddress,
    required super.deliveryInstructions,
    required super.paymentStatus,
    required super.isPaused,
    required super.subscriptionPlan,
    required super.status,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      planId: json['planId'],
      deliveryAddress: AddressModel.fromJson(json['deliveryAddress']),
      deliveryInstructions: json['deliveryInstructions'] ?? '',
      paymentStatus: _mapStringToPaymentStatus(json['paymentDetails']['paymentStatus']),
      isPaused: json['pauseDetails']['isPaused'],
      subscriptionPlan: SubscriptionPlanModel.fromJson(json['subscriptionPlan']),
      status: _mapStringToSubscriptionStatus(json['subscriptionStatus']),
    );
  }

  static PaymentStatus _mapStringToPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  static SubscriptionStatus _mapStringToSubscriptionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'paused':
        return SubscriptionStatus.paused;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'expired':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'planId': planId,
      'deliveryAddress': (deliveryAddress as AddressModel).toJson(),
      'deliveryInstructions': deliveryInstructions,
      'paymentDetails': {
        'paymentStatus': _mapPaymentStatusToString(paymentStatus),
      },
      'pauseDetails': {
        'isPaused': isPaused,
      },
      'subscriptionPlan': (subscriptionPlan as SubscriptionPlanModel).toJson(),
      'subscriptionStatus': _mapSubscriptionStatusToString(status),
    };
  }

  static String _mapPaymentStatusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }

  static String _mapSubscriptionStatusToString(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'active';
      case SubscriptionStatus.paused:
        return 'paused';
      case SubscriptionStatus.cancelled:
        return 'cancelled';
      case SubscriptionStatus.expired:
        return 'expired';
    }
  }
}

