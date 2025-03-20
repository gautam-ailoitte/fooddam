import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/meal_plan_selection_model.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';
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
        return Right(subscriptions);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedSubscriptions = await localDataSource.getActiveSubscriptions();
        if (cachedSubscriptions != null) {
          return Right(cachedSubscriptions);
        } else {
          return Left(NetworkFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getSubscriptionPlans() async {
    if (await networkInfo.isConnected) {
      try {
        final plans = await remoteDataSource.getSubscriptionPlans();
        await localDataSource.cacheSubscriptionPlans(plans);
        return Right(plans);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedPlans = await localDataSource.getSubscriptionPlans();
        if (cachedPlans != null) {
          return Right(cachedPlans);
        } else {
          return Left(NetworkFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Subscription>> getSubscriptionDetails(String subscriptionId) async {
    if (await networkInfo.isConnected) {
      try {
        final subscription = await remoteDataSource.getSubscriptionDetails(subscriptionId);
        return Right(subscription);
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
  Future<Either<Failure, Subscription>> createSubscription(MealPlanSelection selection) async {
    if (await networkInfo.isConnected) {
      try {
        // Convert selection to model for serialization
        final selectionModel = selection as MealPlanSelectionModel;
        final subscriptionData = selectionModel.toJson();
        
        // Create subscription
        final subscription = await remoteDataSource.createSubscription(subscriptionData);
        
        // Clear draft after successful creation
        await localDataSource.clearDraftMealPlanSelection();
        
        return Right(subscription);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      // Cache draft plan even if offline
      try {
        final selectionModel = selection as MealPlanSelectionModel;
        await localDataSource.cacheDraftMealPlanSelection(selectionModel.toJson());
        return Left(NetworkFailure());
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription(String subscriptionId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.cancelSubscription(subscriptionId);
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
  Future<Either<Failure, void>> pauseSubscription(String subscriptionId, DateTime until) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.pauseSubscription(subscriptionId, until);
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
  Future<Either<Failure, List<MealOrder>>> getTodayMealOrders() async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getTodayMealOrders();
        await localDataSource.cacheTodayMealOrders(orders);
        return Right(orders);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedOrders = await localDataSource.getTodayMealOrders();
        if (cachedOrders != null) {
          return Right(cachedOrders);
        } else {
          return Left(NetworkFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<MealOrder>>> getMealOrdersByDate(DateTime date) async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getMealOrdersByDate(date);
        return Right(orders);
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
  Future<Either<Failure, List<MealOrder>>> getMealOrdersBySubscription(String subscriptionId) async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getMealOrdersBySubscription(subscriptionId);
        return Right(orders);
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
