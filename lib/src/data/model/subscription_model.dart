
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/meal_slot_model.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

class SubscriptionModel {
  final String id;
  final DateTime startDate;
  final int durationDays;
  final String packageId;
  final AddressModel address;
  final String? instructions;
  final List<MealSlotModel> slots;
  final PaymentStatus paymentStatus;
  final bool isPaused;
  final SubscriptionStatus status;
  final String? cloudKitchen;

  SubscriptionModel({
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

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      durationDays: json['durationDays'] ?? 7, // Default to 7 days if not specified
      packageId: json['package'],
      address: AddressModel.fromJson(json['address']),
      instructions: json['instructions'],
      slots: (json['slots'] as List)
          .map((slot) => MealSlotModel.fromJson(slot))
          .toList(),
      paymentStatus: _mapStringToPaymentStatus(json['paymentDetails']['paymentStatus']),
      isPaused: json['pauseDetails']['isPaused'],
      status: _mapStringToSubscriptionStatus(json['subscriptionStatus']),
      cloudKitchen: json['cloudKitchen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'durationDays': durationDays,
      'package': packageId,
      'address': address.toJson(),
      'instructions': instructions,
      'slots': slots.map((slot) => slot.toJson()).toList(),
      'paymentDetails': {
        'paymentStatus': _mapPaymentStatusToString(paymentStatus),
      },
      'pauseDetails': {
        'isPaused': isPaused,
      },
      'subscriptionStatus': _mapSubscriptionStatusToString(status),
      'cloudKitchen': cloudKitchen,
    };
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

  static SubscriptionStatus _mapStringToSubscriptionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return SubscriptionStatus.pending;
      case 'active':
        return SubscriptionStatus.active;
      case 'paused':
        return SubscriptionStatus.paused;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'expired':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.pending;
    }
  }

  static String _mapSubscriptionStatusToString(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pending:
        return 'pending';
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

  // Mapper to convert model to entity
  Subscription toEntity() {
    return Subscription(
      id: id,
      startDate: startDate,
      durationDays: durationDays,
      packageId: packageId,
      address: address.toEntity(),
      instructions: instructions,
      slots: slots.map((slot) => slot.toEntity()).toList(),
      paymentStatus: paymentStatus,
      isPaused: isPaused,
      status: status,
      cloudKitchen: cloudKitchen,
    );
  }

  // Mapper to convert entity to model
  factory SubscriptionModel.fromEntity(Subscription entity) {
    return SubscriptionModel(
      id: entity.id,
      startDate: entity.startDate,
      durationDays: entity.durationDays,
      packageId: entity.packageId,
      address: AddressModel.fromEntity(entity.address),
      instructions: entity.instructions,
      slots: entity.slots
          .map((slot) => MealSlotModel.fromEntity(slot))
          .toList(),
      paymentStatus: entity.paymentStatus,
      isPaused: entity.isPaused,
      status: entity.status,
      cloudKitchen: entity.cloudKitchen,
    );
  }
}