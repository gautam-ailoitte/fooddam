// lib/src/domain/repositories/meal_planning_repository.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/meal_planning/calculated_plan_entity.dart';
import 'package:foodam/src/domain/entities/meal_planning/subscription_request_entity.dart';

abstract class MealPlanningRepository {
  Future<Either<Failure, CalculatedPlan>> getCalculatedPlan({
    required String dietaryPreference,
    required int week,
    required DateTime startDate,
  });

  Future<Either<Failure, SubscriptionResponse>> createSubscription({
    required SubscriptionRequest request,
  });
}
