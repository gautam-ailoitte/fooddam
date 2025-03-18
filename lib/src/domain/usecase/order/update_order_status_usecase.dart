// lib/src/domain/usecase/order/update_order_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order;
import 'package:foodam/src/domain/repo/order_repo.dart';

class UpdateOrderStatusParams {
  final String orderId;
  final order.OrderStatus status;

  UpdateOrderStatusParams({
    required this.orderId,
    required this.status,
  });
}

class UpdateOrderStatusUseCase extends UseCaseWithParams<order.Order, UpdateOrderStatusParams> {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  @override
  Future<Either<Failure, order.Order>> call(UpdateOrderStatusParams params) {
    return repository.updateOrderStatus(params.orderId, params.status);
  }
}