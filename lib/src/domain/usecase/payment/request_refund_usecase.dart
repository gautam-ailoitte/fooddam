// lib/src/domain/usecase/payment/request_refund_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

class RequestRefundParams {
  final String paymentId;
  final double amount;
  final String reason;

  RequestRefundParams({
    required this.paymentId,
    required this.amount,
    required this.reason,
  });
}

class RequestRefundUseCase extends UseCaseWithParams<Payment, RequestRefundParams> {
  final PaymentRepository repository;

  RequestRefundUseCase(this.repository);

  @override
  Future<Either<Failure, Payment>> call(RequestRefundParams params) {
    return repository.requestRefund(
      params.paymentId,
      params.amount,
      params.reason,
    );
  }
}