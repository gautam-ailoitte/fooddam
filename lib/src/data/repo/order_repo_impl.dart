// lib/src/data/repo/order_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order_entity;
import 'package:foodam/src/domain/repo/order_repo.dart';

class OrderRepositoryImpl implements OrderRepository {
  final RemoteDataSource remoteDataSource;
  final LoggerService _logger = LoggerService();

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedOrders>> getUpcomingOrders({
    int? page,
    int? limit,
    String? dayContext,
  }) async {
    try {
      _logger.d(
        'Getting upcoming orders: page=$page, limit=$limit, dayContext=$dayContext',
        tag: 'OrderRepository',
      );

      final response = await remoteDataSource.getUpcomingOrders(
        page: page,
        limit: limit,
        dayContext: dayContext ?? 'upcoming3days',
      );

      final orders = response.items.map((model) => model.toEntity()).toList();

      _logger.i(
        'Successfully fetched ${orders.length} upcoming orders',
        tag: 'OrderRepository',
      );

      return Right(
        PaginatedOrders(
          orders: orders,
          pagination: response.pagination.toEntity(),
        ),
      );
    } on NetworkException catch (e) {
      _logger.e(
        'Network error fetching upcoming orders',
        error: e,
        tag: 'OrderRepository',
      );
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      _logger.e(
        'Server error fetching upcoming orders',
        error: e,
        tag: 'OrderRepository',
      );
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e(
        'Unexpected error fetching upcoming orders',
        error: e,
        tag: 'OrderRepository',
      );
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedOrders>> getPastOrders({
    int? page,
    int? limit,
  }) async {
    try {
      _logger.d(
        'Getting past orders: page=$page, limit=$limit',
        tag: 'OrderRepository',
      );

      final response = await remoteDataSource.getPastOrders(
        page: page,
        limit: limit,
      );

      // Filter to only include past orders (before today)
      final allOrders =
          response.items.map((model) => model.toEntity()).toList();
      final pastOrders = allOrders.where((order) => order.isPast).toList();

      _logger.i(
        'Successfully fetched ${pastOrders.length} past orders out of ${allOrders.length} total',
        tag: 'OrderRepository',
      );

      return Right(
        PaginatedOrders(
          orders: pastOrders,
          pagination: response.pagination.toEntity(),
        ),
      );
    } on NetworkException catch (e) {
      _logger.e(
        'Network error fetching past orders',
        error: e,
        tag: 'OrderRepository',
      );
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      _logger.e(
        'Server error fetching past orders',
        error: e,
        tag: 'OrderRepository',
      );
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e(
        'Unexpected error fetching past orders',
        error: e,
        tag: 'OrderRepository',
      );
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<order_entity.Order>>> getTodayOrders() async {
    try {
      _logger.d('Getting today\'s orders', tag: 'OrderRepository');

      // Get upcoming orders which includes today's orders
      final upcomingResult = await getUpcomingOrders(
        dayContext: 'upcoming3days',
        limit: 50, // Get more to ensure we capture all today's orders
      );

      return upcomingResult.fold((failure) => Left(failure), (paginatedOrders) {
        // Filter to only today's orders
        final todayOrders =
            paginatedOrders.orders.where((order) => order.isToday).toList();

        _logger.i(
          'Successfully extracted ${todayOrders.length} today\'s orders',
          tag: 'OrderRepository',
        );

        return Right(todayOrders);
      });
    } catch (e) {
      _logger.e(
        'Unexpected error fetching today\'s orders',
        error: e,
        tag: 'OrderRepository',
      );
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedOrders>> getAllOrders({
    int? page,
    int? limit,
  }) async {
    try {
      _logger.d(
        'Getting all orders: page=$page, limit=$limit',
        tag: 'OrderRepository',
      );

      // Use the past orders endpoint as it returns all orders
      final response = await remoteDataSource.getPastOrders(
        page: page,
        limit: limit,
      );

      final orders = response.items.map((model) => model.toEntity()).toList();

      _logger.i(
        'Successfully fetched ${orders.length} total orders',
        tag: 'OrderRepository',
      );

      return Right(
        PaginatedOrders(
          orders: orders,
          pagination: response.pagination.toEntity(),
        ),
      );
    } on NetworkException catch (e) {
      _logger.e(
        'Network error fetching all orders',
        error: e,
        tag: 'OrderRepository',
      );
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      _logger.e(
        'Server error fetching all orders',
        error: e,
        tag: 'OrderRepository',
      );
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e(
        'Unexpected error fetching all orders',
        error: e,
        tag: 'OrderRepository',
      );
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
