// lib/src/domain/usecase/payment/process_payment_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

class ProcessPaymentParams {
  final String orderId;
  final PaymentMethod paymentMethod;
  final String? couponCode;
  final Map<String, dynamic>? paymentDetails;

  ProcessPaymentParams({
    required this.orderId,
    required this.paymentMethod,
    this.couponCode,
    this.paymentDetails,
  });
}

class ProcessPaymentUseCase extends UseCaseWithParams<Payment, ProcessPaymentParams> {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, Payment>> call(ProcessPaymentParams params) {
    return repository.processPayment(
      orderId: params.orderId,
      paymentMethod: params.paymentMethod,
      couponCode: params.couponCode,
      paymentDetails: params.paymentDetails,
    );
  }
}