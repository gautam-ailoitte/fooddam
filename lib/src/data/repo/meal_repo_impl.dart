// lib/src/data/repositories/meal_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_repo.dart';

class MealRepositoryImpl implements MealRepository {
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MealRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Meal>>> getMeals({
    DietaryPreference? dietaryPreference,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    int skip = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final meals = await remoteDataSource.getMeals(
          dietaryPreference: dietaryPreference,
          minPrice: minPrice,
          maxPrice: maxPrice,
          limit: limit,
          skip: skip,
        );
        return Right(meals);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Meal>> getMealById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final meal = await remoteDataSource.getMealById(id);
        return Right(meal);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> searchMeals(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final meals = await remoteDataSource.searchMeals(query);
        return Right(meals);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByDietaryPreference(DietaryPreference preference) async {
    if (await networkInfo.isConnected) {
      try {
        final meals = await remoteDataSource.getMealsByDietaryPreference(preference);
        return Right(meals);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByDishId(String dishId) async {
    if (await networkInfo.isConnected) {
      try {
        final meals = await remoteDataSource.getMeals();
        
        // Filter meals that contain the specified dish
        final filteredMeals = meals.where((meal) => meal.containsDish(dishId)).toList();
        
        return Right(filteredMeals);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByIds(List<String> ids) async {
    if (await networkInfo.isConnected) {
      try {
        // Get all meals and filter by IDs
        // This is a workaround since our remote data source doesn't have a specific method for this
        final allMeals = await remoteDataSource.getMeals(limit: 1000);
        final filteredMeals = allMeals.where((meal) => ids.contains(meal.id)).toList();
        
        return Right(filteredMeals);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}