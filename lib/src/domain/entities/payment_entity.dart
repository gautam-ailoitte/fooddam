// lib/src/domain/entities/payment_entity.dart

import 'package:equatable/equatable.dart';
import 'order_entity.dart'; // For PaymentStatus

enum PaymentMethod {
  creditCard,
  debitCard,
  paypal,
  bankTransfer
}

class Payment extends Equatable {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final String? transactionId;
  final Map<String, dynamic>? paymentGatewayResponse;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    this.currency = 'USD',
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.paymentGatewayResponse,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    userId,
    amount,
    currency,
    paymentMethod,
    status,
    transactionId,
    paymentGatewayResponse,
    createdAt,
    updatedAt,
  ];
}

class Coupon extends Equatable {
  final String id;
  final String code;
  final String discountType; // "percentage" or "fixed"
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    required this.validFrom,
    required this.validUntil,
    this.usageLimit,
    required this.usageCount,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    discountType,
    discountValue,
    minOrderAmount,
    maxDiscountAmount,
    validFrom,
    validUntil,
    usageLimit,
    usageCount,
    isActive,
    createdAt,
    updatedAt,
  ];
}