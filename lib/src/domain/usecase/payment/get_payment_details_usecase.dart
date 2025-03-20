import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

class GetPaymentDetailsUseCase implements UseCaseWithParams<Payment, String> {
  final PaymentRepository repository;

  GetPaymentDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, Payment>> call(String params) {
    return repository.getPaymentDetails(params);
  }
}