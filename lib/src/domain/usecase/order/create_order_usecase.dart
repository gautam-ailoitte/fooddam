// lib/src/domain/usecase/order/create_order_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order;
import 'package:foodam/src/domain/repo/order_repo.dart';

class CreateOrderParams {
  final String subscriptionId;
  final DateTime deliveryDate;
  final Map<String, dynamic> deliveryAddress;
  final List<Map<String, dynamic>> meals;
  final String? cloudKitchenId;
  final double totalAmount;
  final String? deliveryInstructions;

  CreateOrderParams({
    required this.subscriptionId,
    required this.deliveryDate,
    required this.deliveryAddress,
    required this.meals,
    this.cloudKitchenId,
    required this.totalAmount,
    this.deliveryInstructions,
  });
}

class CreateOrderUseCase extends UseCaseWithParams<order.Order, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, order.Order>> call(CreateOrderParams params) {
    return repository.createOrder(
      subscriptionId: params.subscriptionId,
      deliveryDate: params.deliveryDate,
      deliveryAddress: params.deliveryAddress,
      meals: params.meals,
      cloudKitchenId: params.cloudKitchenId,
      totalAmount: params.totalAmount,
      deliveryInstructions: params.deliveryInstructions,
    );
  }
}
