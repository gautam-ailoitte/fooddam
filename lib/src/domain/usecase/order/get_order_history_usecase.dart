import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order;
import 'package:foodam/src/domain/repo/order_repo.dart';

class GetOrderHistoryUseCase extends UseCase<List<order.Order>> {
  final OrderRepository repository;

  GetOrderHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<order.Order>>> call() {
    return repository.getOrderHistory();
  }
}