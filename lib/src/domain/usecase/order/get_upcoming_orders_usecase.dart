// lib/src/domain/usecase/order/get_upcoming_orders_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order;
import 'package:foodam/src/domain/repo/order_repo.dart';

class GetUpcomingOrdersUseCase extends UseCase<List<order.Order>> {
  final OrderRepository repository;

  GetUpcomingOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<order.Order>>> call() {
    return repository.getUpcomingOrders();
  }
}