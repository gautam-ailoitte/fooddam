import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions() async {
    if (await networkInfo.isConnected) {
      try {
        final subscriptions = await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(subscriptions);
        return Right(subscriptions.map((sub) => sub.toEntity()).toList());
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedSubscriptions = await localDataSource.getActiveSubscriptions();
        if (cachedSubscriptions != null) {
          return Right(cachedSubscriptions.map((sub) => sub.toEntity()).toList());
        } else {
          return Left(NetworkFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Subscription>> getSubscriptionById(String subscriptionId) async {
    if (await networkInfo.isConnected) {
      try {
        final subscription = await remoteDataSource.getSubscriptionById(subscriptionId);
        await localDataSource.cacheSubscription(subscription);
        return Right(subscription.toEntity());
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedSubscription = await localDataSource.getSubscription(subscriptionId);
        if (cachedSubscription != null) {
          return Right(cachedSubscription.toEntity());
        } else {
          return Left(NetworkFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Subscription>> createSubscription({
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required List<Map<String, String>> slots,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final subscription = await remoteDataSource.createSubscription(
          packageId: packageId,
          startDate: startDate,
          durationDays: durationDays,
          addressId: addressId,
          instructions: instructions,
          slots: slots,
        );
        
        // Cache the new subscription
        await localDataSource.cacheSubscription(subscription);
        
        // Update the active subscriptions cache
        final activeSubscriptions = await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
        
        return Right(subscription.toEntity());
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      // Cache draft subscription data for later
      try {
        await localDataSource.cacheDraftSubscription({
          'packageId': packageId,
          'startDate': startDate.toIso8601String(),
          'durationDays': durationDays,
          'addressId': addressId,
          'instructions': instructions,
          'slots': slots,
        });
        return Left(NetworkFailure());
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, void>> updateSubscription(String subscriptionId, List<Map<String, String>> slots) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateSubscription(subscriptionId, slots);
        
        // Update local cache
        final subscription = await remoteDataSource.getSubscriptionById(subscriptionId);
        await localDataSource.cacheSubscription(subscription);
        
        // Update active subscriptions cache
        final activeSubscriptions = await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
        
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription(String subscriptionId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.cancelSubscription(subscriptionId);
        
        // Update active subscriptions cache
        final activeSubscriptions = await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
        
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> pauseSubscription(String subscriptionId, DateTime untilDate) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.pauseSubscription(subscriptionId, untilDate);
        
        // Update local cache
        final subscription = await remoteDataSource.getSubscriptionById(subscriptionId);
        await localDataSource.cacheSubscription(subscription);
        
        // Update active subscriptions cache
        final activeSubscriptions = await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
        
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resumeSubscription(String subscriptionId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.resumeSubscription(subscriptionId);
        
        // Update local cache
        final subscription = await remoteDataSource.getSubscriptionById(subscriptionId);
        await localDataSource.cacheSubscription(subscription);
        
        // Update active subscriptions cache
        final activeSubscriptions = await remoteDataSource.getActiveSubscriptions();
        await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
        
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  // This is not in the original interface, but would be needed for meal orders
  // Future<Either<Failure, List<MealOrder>>> getMealOrdersByDate(DateTime date) async {
  //   return Left(UnexpectedFailure()); // Placeholder
  // }

  // // This is not in the original interface, but would be needed for meal orders
  // Future<Either<Failure, List<MealOrder>>> getMealOrdersBySubscription(String subscriptionId) async {
  //   return Left(UnexpectedFailure()); // Placeholder
  // }

  // // This is not in the original interface, but would be needed for today's meal orders
  // Future<Either<Failure, List<MealOrder>>> getTodayMealOrders() async {
  //   return Left(UnexpectedFailure()); // Placeholder
  // }
}