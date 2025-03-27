// lib/src/data/repo/subscripton_repo_imp.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/meal_slot_model.dart';
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
        // Convert slots format for API
        final mealSlots = slots.map((slot) => MealSlotModel(
          day: slot['day']!,
          timing: slot['timing']!,
        )).toList();
        
        final subscription = await remoteDataSource.createSubscription(
          packageId: packageId,
          startDate: startDate,
          durationDays: durationDays,
          addressId: addressId,
          instructions: instructions,
          slots: mealSlots,
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
        // Convert slots format for API
        final mealSlots = slots.map((slot) => MealSlotModel(
          day: slot['day']!,
          timing: slot['timing']!,
          mealId: slot['meal'],
        )).toList();
        
        await remoteDataSource.updateSubscription(subscriptionId, mealSlots);
        
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
  Future<Either<Failure, void>> pauseSubscription(String subscriptionId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.pauseSubscription(subscriptionId);
        
        // Update local cache
        // final subscription = await remoteDataSource.getSubscriptionById(subscriptionId);
        // await localDataSource.cacheSubscription(subscription);
        
        // Update active subscriptions cache
        // final activeSubscriptions = await remoteDataSource.getActiveSubscriptions();
        // await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
        
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
        
        // // Update local cache
        // final subscription = await remoteDataSource.getSubscriptionById(subscriptionId);
        // await localDataSource.cacheSubscription(subscription);
        
        // // Update active subscriptions cache
        // final activeSubscriptions = await remoteDataSource.getActiveSubscriptions();
        // await localDataSource.cacheActiveSubscriptions(activeSubscriptions);
        
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
}