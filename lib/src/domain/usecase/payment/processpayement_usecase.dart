import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

class ProcessPaymentUseCase implements UseCaseWithParams<Payment, PaymentParams> {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, Payment>> call(PaymentParams params) {
    return repository.processPayment(
      params.subscriptionId,
      params.amount,
      params.method,
    );
  }
}

class PaymentParams {
  final String subscriptionId;
  final double amount;
  final PaymentMethod method;

  PaymentParams({
    required this.subscriptionId,
    required this.amount,
    required this.method,
  });
}