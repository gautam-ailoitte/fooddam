// lib/src/domain/repositories/payment_repository.dart

import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';

abstract class PaymentRepository {
  /// Process a payment for an order
  Future<Either<Failure, Payment>> processPayment({
    required String orderId,
    required PaymentMethod paymentMethod,
    String? couponCode,
    Map<String, dynamic>? paymentDetails,
  });

  /// Verify a coupon code
  Future<Either<Failure, Coupon>> verifyCoupon(String couponCode, double orderAmount);

  /// Get payment history for the current user
  Future<Either<Failure, List<Payment>>> getPaymentHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  });
  
  /// Get payment details by ID
  Future<Either<Failure, Payment>> getPaymentById(String id);
  
  /// Request a refund for a payment
  Future<Either<Failure, Payment>> requestRefund(String paymentId, double amount, String reason);
}