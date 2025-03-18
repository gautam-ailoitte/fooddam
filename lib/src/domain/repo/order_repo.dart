// lib/src/domain/repositories/order_repository.dart

import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order;

abstract class OrderRepository {
  /// Create a new order
  Future<Either<Failure, order.Order>> createOrder({
    required String subscriptionId,
    required DateTime deliveryDate,
    required Map<String, dynamic> deliveryAddress,
    required List<Map<String, dynamic>> meals,
    String? cloudKitchenId,
    required double totalAmount,
    String? deliveryInstructions,
  });

  /// Get orders for the current user
  Future<Either<Failure, List<Order>>> getUserOrders({
    order.OrderStatus? status,
    int limit = 10,
    int skip = 0,
  });

  /// Get order by ID
  Future<Either<Failure, Order>> getOrderById(String id);

  /// Update order status
  Future<Either<Failure, Order>> updateOrderStatus(String id, order.OrderStatus status);

  /// Cancel an order
  Future<Either<Failure, void>> cancelOrder(String id);
  
  /// Get upcoming orders for current user
  Future<Either<Failure, List<Order>>> getUpcomingOrders();
  
  /// Get order history for current user
  Future<Either<Failure, List<Order>>> getOrderHistory();
}