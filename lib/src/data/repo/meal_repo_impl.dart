import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';

class MealRepositoryImpl implements MealRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MealRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Meal>>> getAvailableMeals() async {
    if (await networkInfo.isConnected) {
      try {
        final meals = await remoteDataSource.getAvailableMeals();
        await localDataSource.cacheAvailableMeals(meals);
        return Right(meals);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedMeals = await localDataSource.getAvailableMeals();
        if (cachedMeals != null) {
          return Right(cachedMeals);
        } else {
          return Left(NetworkFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Meal>> getMealDetails(String mealId) async {
    if (await networkInfo.isConnected) {
      try {
        final meal = await remoteDataSource.getMealDetails(mealId);
        await localDataSource.cacheMeal(meal);
        return Right(meal);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      try {
        final cachedMeal = await localDataSource.getMeal(mealId);
        if (cachedMeal != null) {
          return Right(cachedMeal);
        } else {
          return Left(NetworkFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByType(String type) async {
    if (await networkInfo.isConnected) {
      try {
        final meals = await remoteDataSource.getMealsByType(type);
        return Right(meals);
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
  Future<Either<Failure, List<Meal>>> getMealsByDietaryPreference(String preference) async {
    if (await networkInfo.isConnected) {
      try {
        final meals = await remoteDataSource.getMealsByDietaryPreference(preference);
        return Right(meals);
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
  Future<Either<Failure, List<Dish>>> getDishes() async {
    if (await networkInfo.isConnected) {
      try {
        final dishes = await remoteDataSource.getDishes();
        return Right(dishes);
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
  Future<Either<Failure, Dish>> getDishDetails(String dishId) async {
    if (await networkInfo.isConnected) {
      try {
        final dish = await remoteDataSource.getDishDetails(dishId);
        return Right(dish);
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

