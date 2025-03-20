import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

class GetPaymentHistoryUseCase implements UseCase<List<Payment>> {
  final PaymentRepository repository;

  GetPaymentHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Payment>>> call() {
    return repository.getPaymentHistory();
  }
}