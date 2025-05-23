// lib/src/data/model/subscription_list_model.dart
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/user_model.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SubscriptionListModel {
  final String? id;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? durationDays;
  final int? noOfPersons;
  final int? weeks; // Just count for list API
  final int? totalSlots;
  final String? subscriptionStatus;
  final double? subscriptionPrice;
  final Map<String, dynamic>? cloudKitchen;
  final Map<String, dynamic>? paymentDetails;
  final AddressModel? address;
  final UserModel? user;
  final String? instructions;

  SubscriptionListModel({
    this.id,
    this.startDate,
    this.endDate,
    this.durationDays,
    this.noOfPersons,
    this.weeks,
    this.totalSlots,
    this.subscriptionStatus,
    this.subscriptionPrice,
    this.cloudKitchen,
    this.paymentDetails,
    this.address,
    this.user,
    this.instructions,
  });

  factory SubscriptionListModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionListModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionListModelToJson(this);

  // Mapper to convert model to entity (basic subscription for list)
  Subscription toEntity() {
    final paymentStatus = _mapStringToPaymentStatus(
      paymentDetails?['paymentStatus'] as String? ?? 'pending',
    );

    final status = _mapStringToSubscriptionStatus(
      subscriptionStatus ?? 'pending',
    );

    bool isPaused = subscriptionStatus?.toLowerCase() == 'paused';

    return Subscription(
      id: id ?? '',
      startDate: startDate ?? DateTime.now(),
      endDate: endDate,
      durationDays: durationDays ?? 7,
      noOfPersons: noOfPersons ?? 1,
      weeks: null, // No detailed weeks data in list
      totalSlots: totalSlots ?? 0,
      paymentStatus: paymentStatus,
      isPaused: isPaused,
      status: status,
      cloudKitchen: cloudKitchen?['name'] as String?,
      paymentDetails: paymentDetails,
      address: address?.toEntity() ?? Address(id: '', street: '', city: '', state: '', zipCode: ''),
      user: user?.toEntity(),
      instructions: instructions,
      subscriptionPrice: subscriptionPrice ?? 0,
    );
  }

  // Helper methods for enum conversion
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
}