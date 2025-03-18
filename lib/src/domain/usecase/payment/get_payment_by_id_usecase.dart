// lib/src/domain/usecase/payment/get_payment_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

class GetPaymentByIdUseCase extends UseCaseWithParams<Payment, String> {
  final PaymentRepository repository;

  GetPaymentByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Payment>> call(String paymentId) {
    return repository.getPaymentById(paymentId);
  }
}