import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';

// lib/src/data/repositories/meal_repository_impl.dart

class MealRepositoryImpl implements MealRepository {
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MealRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Meal>> getMealById(String mealId) async {
    if (await networkInfo.isConnected) {
      try {
        final mealModel = await remoteDataSource.getMealById(mealId);
        return Right(mealModel.toEntity());
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
  Future<Either<Failure, Dish>> getDishById(String dishId) async {
    if (await networkInfo.isConnected) {
      try {
        final dishModel = await remoteDataSource.getDishById(dishId);
        return Right(dishModel.toEntity());
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
