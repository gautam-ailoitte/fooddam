import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/user_model.dart';
import 'package:foodam/src/data/model/week_plan_model.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SubscriptionModel {
  final String? id;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? durationDays;
  final int? noOfPersons;
  final List<WeekPlanModel>? weeks;
  final int? totalSlots;
  final String? subscriptionStatus;
  final double? subscriptionPrice;
  final Map<String, dynamic>? cloudKitchen;
  final Map<String, dynamic>? paymentDetails;
  final AddressModel? address;
  final UserModel? user;
  final String? instructions;

  SubscriptionModel({
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

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);

  // Mapper to convert model to entity
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
      weeks: weeks?.map((week) => week.toEntity()).toList() ?? [],
      totalSlots: totalSlots ?? 0,
      paymentStatus: paymentStatus,
      isPaused: isPaused,
      status: status,
      cloudKitchen: cloudKitchen?['name'] as String?,
      paymentDetails: paymentDetails,
      address:
          address?.toEntity() ??
          Address(id: '', street: '', city: '', state: '', zipCode: ''),
      user: user?.toEntity(),
      instructions: instructions,
      subscriptionPrice: subscriptionPrice ?? 0,
    );
  }

  // Mapper to convert entity to model
  factory SubscriptionModel.fromEntity(Subscription entity) {
    return SubscriptionModel(
      id: entity.id,
      startDate: entity.startDate,
      endDate: entity.endDate,
      durationDays: entity.durationDays,
      noOfPersons: entity.noOfPersons,
      weeks:
          entity.weeks?.map((week) => WeekPlanModel.fromEntity(week)).toList(),
      totalSlots: entity.totalSlots,
      subscriptionStatus: _mapSubscriptionStatusToString(entity.status),
      subscriptionPrice: entity.subscriptionPrice,
      paymentDetails: entity.paymentDetails,
      address: AddressModel.fromEntity(entity.address),
      user: entity.user != null ? UserModel.fromEntity(entity.user!) : null,
      instructions: entity.instructions,
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
}
