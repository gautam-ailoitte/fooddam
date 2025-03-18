// lib/src/domain/usecase/order/get_user_orders_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order;
import 'package:foodam/src/domain/repo/order_repo.dart';

class GetUserOrdersParams {
  final order.OrderStatus? status;
  final int limit;
  final int skip;

  GetUserOrdersParams({
    this.status,
    this.limit = 10,
    this.skip = 0,
  });
}

class GetUserOrdersUseCase extends UseCaseWithParams<List<order.Order>, GetUserOrdersParams> {
  final OrderRepository repository;

  GetUserOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<order.Order>>> call(GetUserOrdersParams params) {
    return repository.getUserOrders(
      status: params.status,
      limit: params.limit,
      skip: params.skip,
    );
  }
}