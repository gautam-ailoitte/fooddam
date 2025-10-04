// lib/src/domain/entities/meal_planning/subscription_request_entity.dart
import 'package:equatable/equatable.dart';

class SubscriptionRequest extends Equatable {
  final DateTime startDate;
  final String address;
  final String instructions;
  final int noOfPersons;
  final List<WeekRequestData> weeks;

  const SubscriptionRequest({
    required this.startDate,
    required this.address,
    required this.instructions,
    required this.noOfPersons,
    required this.weeks,
  });

  @override
  List<Object?> get props => [
    startDate,
    address,
    instructions,
    noOfPersons,
    weeks,
  ];
}

class WeekRequestData extends Equatable {
  final String dietaryPreference;
  final List<String> slots;

  const WeekRequestData({required this.dietaryPreference, required this.slots});

  @override
  List<Object?> get props => [dietaryPreference, slots];
}

class SubscriptionResponse extends Equatable {
  final String? id;
  final String? status;
  final String? message;
  final DateTime? createdAt;
  final double? totalAmount;
  final Map<String, dynamic>? additionalData;

  const SubscriptionResponse({
    this.id,
    this.status,
    this.message,
    this.createdAt,
    this.totalAmount,
    this.additionalData,
  });

  @override
  List<Object?> get props => [
    id,
    status,
    message,
    createdAt,
    totalAmount,
    additionalData,
  ];
}
