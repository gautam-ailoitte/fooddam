// lib/src/domain/usecase/order/get_order_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order;
import 'package:foodam/src/domain/repo/order_repo.dart';

class GetOrderByIdUseCase extends UseCaseWithParams<order.Order, String> {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  @override
  Future<Either<Failure, order.Order>> call(String orderId) {
    return repository.getOrderById(orderId);
  }
}