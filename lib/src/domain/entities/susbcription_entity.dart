import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/entities/week_plan.dart';

class Subscription extends Equatable {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int durationDays;
  final int noOfPersons;
  final List<WeekPlan>? weeks;
  final int totalSlots;
  final PaymentStatus paymentStatus;
  final bool isPaused;
  final SubscriptionStatus status;
  final String? cloudKitchen;
  final Map<String, dynamic>? paymentDetails;
  final Address address;
  final User? user;
  final String? instructions;
  final double subscriptionPrice;

  const Subscription({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.durationDays,
    required this.noOfPersons,
    this.weeks,
    required this.totalSlots,
    required this.paymentStatus,
    required this.isPaused,
    required this.status,
    this.cloudKitchen,
    this.paymentDetails,
    required this.address,
    this.user,
    this.instructions,
    required this.subscriptionPrice,
  });

  @override
  List<Object?> get props => [
    id,
    startDate,
    endDate,
    durationDays,
    noOfPersons,
    weeks,
    totalSlots,
    paymentStatus,
    isPaused,
    status,
    cloudKitchen,
    paymentDetails,
    address,
    user,
    instructions,
    subscriptionPrice,
  ];

  // Helper methods
  bool get isActive => status == SubscriptionStatus.active && !isPaused;

  bool get isPending => status == SubscriptionStatus.pending;

  int get totalWeeks => weeks?.length ?? 0;

  int get remainingDays {
    if (endDate == null) {
      return 0;
    }

    final now = DateTime.now();
    if (now.isAfter(endDate!)) {
      return 0;
    }

    return endDate!.difference(now).inDays;
  }

  DateTime? get calculatedEndDate {
    if (endDate != null) {
      return endDate;
    }

    return startDate.add(Duration(days: durationDays));
  }

  bool get isPaid => paymentStatus == PaymentStatus.paid;
}

enum PaymentStatus { pending, paid, failed, refunded }

enum SubscriptionStatus { pending, active, paused, cancelled, expired }
