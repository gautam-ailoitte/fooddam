// lib/src/data/repo/subscription_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/meal_slot_model.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final LoggerService _logger = LoggerService();

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions() async {
    try {
      // Try to get from cache first
      final cachedSubscriptions =
          await localDataSource.getActiveSubscriptions();
      if (cachedSubscriptions != null) {
        _logger.d('Using cached subscriptions');

        // Fetch fresh data in the background
        _fetchAndCacheActiveSubscriptions();

        return Right(cachedSubscriptions.map((sub) => sub.toEntity()).toList());
      }

      // If not in cache, fetch directly
      return _fetchAndReturnActiveSubscriptions();
    } on CacheException {
      return _fetchAndReturnActiveSubscriptions();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // Helper method to fetch and return active subscriptions
  Future<Either<Failure, List<Subscription>>>
  _fetchAndReturnActiveSubscriptions() async {
    try {
      final subscriptions = await remoteDataSource.getActiveSubscriptions();
      await localDataSource.cacheActiveSubscriptions(subscriptions);
      return Right(subscriptions.map((sub) => sub.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error in getActiveSubscriptions', error: e);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // Background update of subscriptions
  Future<void> _fetchAndCacheActiveSubscriptions() async {
    try {
      final subscriptions = await remoteDataSource.getActiveSubscriptions();
      await localDataSource.cacheActiveSubscriptions(subscriptions);
      _logger.d('Updated subscription cache');
    } catch (e) {
      _logger.w('Background subscription cache update failed: $e');
    }
  }

  @override
  Future<Either<Failure, Subscription>> getSubscriptionById(
    String subscriptionId,
  ) async {
    try {
      // Try getting from cache first
      final cachedSubscription = await localDataSource.getSubscription(
        subscriptionId,
      );
      if (cachedSubscription != null) {
        _logger.d('Using cached subscription for ID: $subscriptionId');

        // Fetch fresh data in the background
        _fetchAndCacheSubscriptionById(subscriptionId);

        return Right(cachedSubscription.toEntity());
      }

      // If not in cache, fetch directly
      return _fetchAndReturnSubscriptionById(subscriptionId);
    } on CacheException {
      return _fetchAndReturnSubscriptionById(subscriptionId);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // Helper method to fetch and return a specific subscription
  Future<Either<Failure, Subscription>> _fetchAndReturnSubscriptionById(
    String subscriptionId,
  ) async {
    try {
      final subscription = await remoteDataSource.getSubscriptionById(
        subscriptionId,
      );
      await localDataSource.cacheSubscription(subscription);
      return Right(subscription.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error in getSubscriptionById', error: e);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // Background update of specific subscription
  Future<void> _fetchAndCacheSubscriptionById(String subscriptionId) async {
    try {
      final subscription = await remoteDataSource.getSubscriptionById(
        subscriptionId,
      );
      await localDataSource.cacheSubscription(subscription);
      _logger.d('Updated cache for subscription ID: $subscriptionId');
    } catch (e) {
      _logger.w('Background subscription cache update failed: $e');
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

  @override
  Future<Either<Failure, List<String>>> createSubscription({
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    required int personCount,
    String? instructions,
    required List<Map<String, String>> slots,
  }) async {
    try {
      // Convert slots format for API
      final mealSlots =
          slots
              .map(
                (slot) => MealSlotModel(
                  day: slot['day']!,
                  timing: slot['timing']!,
                  mealId: slot['meal'],
                ),
              )
              .toList();

      final successMessage = await remoteDataSource.createSubscription(
        packageId: packageId,
        startDate: startDate,
        durationDays: durationDays,
        addressId: addressId,
        instructions: instructions,
        slots: mealSlots,
        personCount: personCount,
      );

      // Update the active subscriptions cache
      try {
        final activeSubscriptions =
            await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
      } catch (e) {
        _logger.w('Failed to update subscription cache after creation');
      }

      return Right(successMessage);
    } on NetworkException catch (e) {
      // For offline creation, cache draft subscription data for later
      try {
        await localDataSource.cacheDraftSubscription({
          'packageId': packageId,
          'startDate': startDate.toIso8601String(),
          'durationDays': durationDays,
          'addressId': addressId,
          'instructions': instructions,
          'slots': slots,
        });

        return Left(
          NetworkFailure(
            'No internet connection. Subscription saved as draft.',
          ),
        );
      } catch (e) {
        return Left(CacheFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error in createSubscription', error: e);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSubscription(
    String subscriptionId,
    List<Map<String, String>> slots,
  ) async {
    try {
      // Convert slots format for API
      final mealSlots =
          slots
              .map(
                (slot) => MealSlotModel(
                  day: slot['day']!,
                  timing: slot['timing']!,
                  mealId: slot['meal'],
                ),
              )
              .toList();

      await remoteDataSource.updateSubscription(subscriptionId, mealSlots);

      // Update local cache
      try {
        final subscription = await remoteDataSource.getSubscriptionById(
          subscriptionId,
        );
        await localDataSource.cacheSubscription(subscription);

        // Update active subscriptions cache
        final activeSubscriptions =
            await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
      } catch (e) {
        _logger.w('Failed to update subscription cache after update');
      }

      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error in updateSubscription', error: e);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription(
    String subscriptionId,
  ) async {
    try {
      await remoteDataSource.cancelSubscription(subscriptionId);

      // Update active subscriptions cache
      try {
        final activeSubscriptions =
            await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
      } catch (e) {
        _logger.w('Failed to update subscription cache after cancellation');
      }

      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error in cancelSubscription', error: e);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pauseSubscription(String subscriptionId) async {
    try {
      await remoteDataSource.pauseSubscription(subscriptionId);

      // Update active subscriptions cache
      try {
        final activeSubscriptions =
            await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
      } catch (e) {
        _logger.w('Failed to update subscription cache after pause');
      }

      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error in pauseSubscription', error: e);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resumeSubscription(
    String subscriptionId,
  ) async {
    try {
      await remoteDataSource.resumeSubscription(subscriptionId);

      // Update active subscriptions cache
      try {
        final activeSubscriptions =
            await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
      } catch (e) {
        _logger.w('Failed to update subscription cache after resume');
      }

      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      _logger.e('Unexpected error in resumeSubscription', error: e);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
