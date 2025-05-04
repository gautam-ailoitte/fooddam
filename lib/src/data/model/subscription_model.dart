// lib/src/data/model/subscription_model.dart
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/package_model.dart';
import 'package:foodam/src/data/model/user_model.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

import 'meal_slot_model.dart';

class SubscriptionModel {
  final String id;
  final DateTime startDate;
  final int durationDays;
  final String packageId;
  final PackageModel? package;
  final AddressModel address;
  final String? instructions;
  final List<MealSlotModel> slots;
  final PaymentStatus paymentStatus;
  final bool isPaused;
  final SubscriptionStatus status;
  final String? cloudKitchen;
  final Map<String, dynamic>? paymentDetails;
  final int noOfSlots;
  final UserModel? user;
  final double? subscriptionPrice;

  SubscriptionModel({
    required this.id,
    required this.startDate,
    this.durationDays = 7,
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
    this.noOfSlots = 21, // Default 21 slots (7 days x 3 meals)
    this.user,
    this.subscriptionPrice,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    // Handle address
    AddressModel addressModel;
    if (json['address'] is Map) {
      addressModel = AddressModel.fromJson(
        Map<String, dynamic>.from(json['address']),
      );
    } else if (json['address'] is String) {
      addressModel = AddressModel(
        id: json['address'] as String,
        street: 'Address not loaded',
        city: 'Unknown',
        state: 'Unknown',
        zipCode: 'Unknown',
      );
    } else {
      addressModel = AddressModel(
        id: 'unknown',
        street: 'Unknown address',
        city: 'Unknown',
        state: 'Unknown',
        zipCode: 'Unknown',
      );
    }

    // Handle package
    PackageModel? packageModel;
    String packageId = 'unknown';

    if (json['package'] is Map) {
      final packageData = Map<String, dynamic>.from(json['package']);
      packageId = packageData['id'] ?? 'unknown';
      packageModel = PackageModel.fromJson(packageData);
    } else if (json['package'] is String) {
      packageId = json['package'];
    }

    // Handle payment status from paymentDetails
    final paymentDetails =
        json['paymentDetails'] is Map
            ? Map<String, dynamic>.from(json['paymentDetails'])
            : {'paymentStatus': 'pending'};

    final paymentStatusStr =
        paymentDetails['paymentStatus'] as String? ?? 'pending';

    // Handle user
    UserModel? userModel;
    if (json['user'] is Map) {
      userModel = UserModel.fromJson(Map<String, dynamic>.from(json['user']));
    }

    // Handle slots - adapt to new date-based format
    List<MealSlotModel> mealSlots = [];

    // Check if slots is provided in the API response
    if (json['slots'] is List) {
      mealSlots =
          (json['slots'] as List).map((slot) {
            if (slot is Map) {
              final slotMap = Map<String, dynamic>.from(slot);
              print("hiiiiii❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️");
              // Ensure meal is properly parsed
              MealModel? meal;
              if (slotMap['meal'] is Map) {
                meal = MealModel.fromJson(
                  Map<String, dynamic>.from(slotMap['meal']),
                );
              }

              return MealSlotModel(
                day: _getDayFromDate(slotMap['date']),
                timing: slotMap['timing'] ?? 'unknown',
                mealId: slotMap['meal'] is Map ? slotMap['meal']['id'] : null,
                meal: meal,
              );
            }
            return MealSlotModel(
              day: 'unknown',
              timing: 'unknown',
              mealId: null,
              meal: null,
            );
          }).toList();
    }
    // Parse subscription status
    final statusStr = json['subscriptionStatus'] as String? ?? 'pending';
    final isPaused = statusStr.toLowerCase() == 'paused';

    double? subscriptionPrice;
    if (json['subscriptionPrice'] != null) {
      subscriptionPrice =
          (json['subscriptionPrice'] is int)
              ? (json['subscriptionPrice'] as int).toDouble()
              : (json['subscriptionPrice'] as num).toDouble();
    }

    return SubscriptionModel(
      id: json['id'] ?? '',
      startDate:
          json['startDate'] is String
              ? DateTime.parse(json['startDate'])
              : DateTime.now(),
      durationDays: json['durationDays'] ?? 7,
      packageId: packageId,
      package: packageModel,
      address: addressModel,
      instructions: json['instructions'] as String?,
      slots: mealSlots,
      paymentStatus: _mapStringToPaymentStatus(paymentStatusStr),
      isPaused: isPaused,
      status: _mapStringToSubscriptionStatus(statusStr),
      cloudKitchen:
          json['cloudKitchen'] is Map
              ? json['cloudKitchen']['name']
              : json['cloudKitchen'],
      paymentDetails: paymentDetails,
      noOfSlots: json['noOfSlots'] ?? 21,
      user: userModel,
      subscriptionPrice: subscriptionPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'durationDays': durationDays,
      'package': package?.toJson() ?? packageId,
      'address': address.toJson(),
      'instructions': instructions,
      'slots': slots.map((slot) => slot.toJson()).toList(),
      'paymentDetails':
          paymentDetails ??
          {'paymentStatus': _mapPaymentStatusToString(paymentStatus)},
      'subscriptionStatus': _mapSubscriptionStatusToString(status),
      'cloudKitchen': cloudKitchen,
      'noOfSlots': noOfSlots,
      'user': user?.toJson(),
      'subscriptionPrice': subscriptionPrice,
    };
  }

  static String _getDayFromDate(String? dateStr) {
    if (dateStr == null) return 'unknown';
    try {
      final date = DateTime.parse(dateStr);
      final days = [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ];
      // DateTime.weekday returns 1 for Monday, 2 for Tuesday, etc.
      return days[date.weekday - 1];
    } catch (e) {
      return 'unknown';
    }
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
      package: package?.toEntity(),
      address: address.toEntity(),
      instructions: instructions,
      slots: slots.map((slot) => slot.toEntity()).toList(),
      paymentStatus: paymentStatus,
      isPaused: isPaused,
      status: status,
      cloudKitchen: cloudKitchen,
      paymentDetails: paymentDetails,
      noOfSlots: noOfSlots,
      user: user?.toEntity(),
      subscriptionPrice: subscriptionPrice,
    );
  }

  // Mapper to convert entity to model
  factory SubscriptionModel.fromEntity(Subscription entity) {
    return SubscriptionModel(
      id: entity.id,
      startDate: entity.startDate,
      durationDays: entity.durationDays,
      packageId: entity.packageId,
      package:
          entity.package != null
              ? PackageModel.fromEntity(entity.package!)
              : null,
      address: AddressModel.fromEntity(entity.address),
      instructions: entity.instructions,
      slots:
          entity.slots.map((slot) => MealSlotModel.fromEntity(slot)).toList(),
      paymentStatus: entity.paymentStatus,
      isPaused: entity.isPaused,
      status: entity.status,
      cloudKitchen: entity.cloudKitchen,
      paymentDetails: entity.paymentDetails,
      noOfSlots: entity.noOfSlots,
      user: entity.user != null ? UserModel.fromEntity(entity.user!) : null,
      subscriptionPrice: entity.subscriptionPrice,
    );
  }
}
