// lib/src/domain/usecase/payment/get_payment_history_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

class GetPaymentHistoryParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int limit;

  GetPaymentHistoryParams({
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 10,
  });
}

class GetPaymentHistoryUseCase extends UseCaseWithParams<List<Payment>, GetPaymentHistoryParams> {
  final PaymentRepository repository;

  GetPaymentHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Payment>>> call(GetPaymentHistoryParams params) {
    return repository.getPaymentHistory(
      startDate: params.startDate,
      endDate: params.endDate,
      page: params.page,
      limit: params.limit,
    );
  }
}