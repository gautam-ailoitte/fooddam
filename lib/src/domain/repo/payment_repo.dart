// lib/src/domain/repo/payment_repository.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, Payment>> processPayment(String subscriptionId, double amount, PaymentMethod method);
  Future<Either<Failure, List<Payment>>> getPaymentHistory();
  Future<Either<Failure, Payment>> getPaymentDetails(String paymentId);
}