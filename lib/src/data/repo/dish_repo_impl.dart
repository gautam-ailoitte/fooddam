// lib/src/data/repositories/dish_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/dish_repository.dart';

class DishRepositoryImpl implements DishRepository {
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DishRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Dish>>> getDishes({
    FoodCategory? category,
    DietaryPreference? dietaryPreference,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    int skip = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final dishes = await remoteDataSource.getDishes(
          category: category,
          dietaryPreference: dietaryPreference,
          minPrice: minPrice,
          maxPrice: maxPrice,
          limit: limit,
          skip: skip,
        );
        return Right(dishes);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Dish>> getDishById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final dish = await remoteDataSource.getDishById(id);
        return Right(dish);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Dish>>> searchDishes(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final dishes = await remoteDataSource.searchDishes(query);
        return Right(dishes);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Dish>>> getDishesByIds(List<String> ids) async {
    if (await networkInfo.isConnected) {
      try {
        final dishes = await remoteDataSource.getDishesByIds(ids);
        return Right(dishes);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Dish>>> getDishesByCategory(FoodCategory category) async {
    if (await networkInfo.isConnected) {
      try {
        final dishes = await remoteDataSource.getDishes(category: category);
        return Right(dishes);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Dish>>> getDishesByDietaryPreference(DietaryPreference preference) async {
    if (await networkInfo.isConnected) {
      try {
        final dishes = await remoteDataSource.getDishes(dietaryPreference: preference);
        return Right(dishes);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}