// lib/src/data/repositories/order_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order_entity;
import 'package:foodam/src/domain/repo/order_repo.dart';

class OrderRepositoryImpl implements OrderRepository {
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, order_entity.Order>> createOrder({
    required String subscriptionId,
    required DateTime deliveryDate,
    required Map<String, dynamic> deliveryAddress,
    required List<Map<String, dynamic>> meals,
    String? cloudKitchenId,
    required double totalAmount,
    String? deliveryInstructions,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final order = await remoteDataSource.createOrder(
          subscriptionId: subscriptionId,
          deliveryDate: deliveryDate,
          deliveryAddress: deliveryAddress,
          meals: meals,
          cloudKitchenId: cloudKitchenId,
          totalAmount: totalAmount,
          deliveryInstructions: deliveryInstructions,
        );
        return Right(order);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<order_entity.Order>>> getUserOrders({
    order_entity.OrderStatus? status,
    int limit = 10,
    int skip = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getUserOrders(
          status: status,
          limit: limit,
          skip: skip,
        );
        return Right(orders);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, order_entity.Order>> getOrderById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final order = await remoteDataSource.getOrderById(id);
        return Right(order);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, order_entity.Order>> updateOrderStatus(String id, order_entity.OrderStatus status) async {
    if (await networkInfo.isConnected) {
      try {
        final order = await remoteDataSource.updateOrderStatus(id, status);
        return Right(order);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.cancelOrder(id);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<order_entity.Order>>> getUpcomingOrders() async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getUserOrders();
        
        // Filter orders with future delivery dates or pending/preparing status
        final upcomingOrders = orders.where((order) => 
          order.deliveryDate.isAfter(DateTime.now()) || 
          order.status == order_entity.OrderStatus.pending ||
          order.status == order_entity.OrderStatus.confirmed ||
          order.status == order_entity.OrderStatus.preparing
        ).toList();
        
        return Right(upcomingOrders);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<order_entity.Order>>> getOrderHistory() async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getUserOrders();
        
        // Filter orders with past delivery dates and completed status
        final historyOrders = orders.where((order) => 
          order.deliveryDate.isBefore(DateTime.now()) && 
          (order.status == order_entity.OrderStatus.delivered || 
           order.status == order_entity.OrderStatus.cancelled)
        ).toList();
        
        return Right(historyOrders);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}