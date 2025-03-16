// Plan repository for handling meal plans
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';

abstract class PlanRepository {
  /// Get all available plan templates
  Future<Either<Failure, List<Plan>>> getAvailablePlans();

  /// Get user's active plan if exists
  Future<Either<Failure, Plan?>> getActivePlan();

  /// Create a new plan for the user
  Future<Either<Failure, Plan>> createPlan(Plan plan);

  /// Customize a plan
  Future<Either<Failure, Plan>> customizePlan(Plan plan);

  /// Cache a draft plan
  Future<Either<Failure, void>> cacheDraftPlan(Plan plan);

  /// Get the draft plan
  Future<Either<Failure, Plan?>> getDraftPlan();

  /// Clear the draft plan
  Future<Either<Failure, void>> clearDraftPlan();

  /// Save a plan and proceed to payment
  Future<Either<Failure, String>> savePlanAndGetPaymentUrl(Plan plan);

  /// Save a draft plan
  Future<Either<Failure, Plan>> saveDraftPlan(Plan plan);
  
  /// Get draft plan or create new from template
  Future<Either<Failure, Plan>> getDraftPlanOrCreateNew(Plan template);
  
  /// Reset plan to default meals
  Future<Either<Failure, Plan>> resetPlanToDefaults(Plan plan);
  
  /// Update a meal in a plan
  Future<Either<Failure, Plan>> updateMealInPlan({
    required Plan plan,
    required DayOfWeek day, 
    required MealType type, 
    required Thali thali
  });
}