// lib/src/data/repo/subscription_repo_impl.dart (UPDATED - Removed Local Data Source)
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final RemoteDataSource remoteDataSource;
  final LoggerService _logger = LoggerService();

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, PaginatedSubscriptions>> getSubscriptions({
    int? page,
    int? limit,
  }) async {
    try {
      final response = await remoteDataSource.getSubscriptions(
        page: page,
        limit: limit,
      );

      return Right(
        PaginatedSubscriptions(
          subscriptions: response.items.map((sub) => sub.toEntity()).toList(),
          pagination: response.pagination.toEntity(),
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions() async {
    try {
      final subscriptionListModels =
      await remoteDataSource.getActiveSubscriptions();
      final subscriptions =
      subscriptionListModels.map((model) => model.toEntity()).toList();
      return Right(subscriptions);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subscription>> getSubscriptionById(
      String subscriptionId,
      ) async {
    try {
      final subscriptionDetailModel = await remoteDataSource
          .getSubscriptionById(subscriptionId);
      return Right(subscriptionDetailModel.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ResourceNotFoundException catch (e) {
      return Left(ResourceNotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subscription>> createSubscription({
    required DateTime startDate,
    required DateTime endDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required int noOfPersons,
    required List<WeekSubscriptionRequest> weeks,
  }) async {
    try {
      // Convert domain WeekSubscription to data layer WeekSubscriptionRequest
      final weekRequests =
      weeks.map((week) {
        return WeekSubscriptionRequest(
          packageId: week.packageId,
          slots: week.slots,
        );
      }).toList();

      final subscriptionDetailModel = await remoteDataSource.createSubscription(
        startDate: startDate,
        endDate: endDate,
        durationDays: durationDays,
        addressId: addressId,
        instructions: instructions,
        noOfPersons: noOfPersons,
        weeks: weekRequests,
      );

      return Right(subscriptionDetailModel.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription(
      String subscriptionId,
      ) async {
    try {
      await remoteDataSource.cancelSubscription(subscriptionId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pauseSubscription(String subscriptionId) async {
    try {
      await remoteDataSource.pauseSubscription(subscriptionId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resumeSubscription(
      String subscriptionId,
      ) async {
    try {
      await remoteDataSource.resumeSubscription(subscriptionId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedOrders>> getUpcomingOrders({
    int? page,
    int? limit,
    String? dayContext,
  }) async {
    try {
      final response = await remoteDataSource.getUpcomingOrders(
        page: page,
        limit: limit,
        dayContext: dayContext,
      );

      return Right(
        PaginatedOrders(
          orders: response.items.map((order) => order.toEntity()).toList(),
          pagination: response.pagination.toEntity(),
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error in getUpcomingOrders', error: e);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedOrders>> getPastOrders({
    int? page,
    int? limit,
    String? dayContext,
  }) async {
    try {
      final response = await remoteDataSource.getPastOrders(
        page: page,
        limit: limit,
        dayContext: dayContext,
      );

      return Right(
        PaginatedOrders(
          orders: response.items.map((order) => order.toEntity()).toList(),
          pagination: response.pagination.toEntity(),
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error in getPastOrders', error: e);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}