// lib/src/data/repositories/meal_planning_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/data/datasource/meal_planning_data_source.dart';
import 'package:foodam/src/data/repo/meal_planning_repository_conv.dart';
import 'package:foodam/src/domain/entities/meal_planning/calculated_plan_entity.dart';
import 'package:foodam/src/domain/entities/meal_planning/subscription_request_entity.dart';
import 'package:foodam/src/domain/repo/meal_planning_repository.dart';

class MealPlanningRepositoryImpl implements MealPlanningRepository {
  final MealPlanningDataSource remoteDataSource;

  MealPlanningRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CalculatedPlan>> getCalculatedPlan({
    required String dietaryPreference,
    required int week,
    required DateTime startDate,
  }) async {
    try {
      final response = await remoteDataSource.getCalculatedPlan(
        dietaryPreference: dietaryPreference,
        week: week,
        startDate: startDate,
      );

      return Right(
        MealPlanningRepositoryConv.convertCalculatedPlanModelToEntity(response),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SubscriptionResponse>> createSubscription({
    required SubscriptionRequest request,
  }) async {
    try {
      final requestModel =
          MealPlanningRepositoryConv.convertSubscriptionRequestEntityToModel(
            request,
          );

      final response = await remoteDataSource.createSubscription(
        request: requestModel,
      );

      return Right(
        MealPlanningRepositoryConv.convertSubscriptionResponseModelToEntity(
          response,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
