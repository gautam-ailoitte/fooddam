import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/repo/order_repo.dart';

class CancelOrderUseCase extends UseCaseWithParams<void, String> {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String orderId) {
    return repository.cancelOrder(orderId);
  }
}