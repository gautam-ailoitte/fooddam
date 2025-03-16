// lib/src/data/repo/plan_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/local_data_source.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/models/daily_meal_model.dart';
import 'package:foodam/src/data/models/plan_model.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';
import 'package:foodam/src/domain/repo/plan_repo.dart';

class PlanRepositoryImpl implements PlanRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PlanRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Plan>> createPlan(Plan plan) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePlan = await remoteDataSource.createPlan(_convertToPlanModel(plan));
        return Right(remotePlan);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Plan>>> getAvailablePlans() async {
    if (await networkInfo.isConnected) {
      try {
        final remotePlans = await remoteDataSource.getAvailablePlans();
        
        // Cache plans for offline use
        await localDataSource.cachePlans(remotePlans);
        
        return Right(remotePlans);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localPlans = await localDataSource.getLastPlans();
        return Right(localPlans);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Plan?>> getActivePlan() async {
    if (await networkInfo.isConnected) {
      try {
        final remotePlan = await remoteDataSource.getActivePlan();
        
        if (remotePlan != null) {
          await localDataSource.cacheActivePlan(remotePlan);
        }
        
        return Right(remotePlan);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localPlan = await localDataSource.getLastActivePlan();
        return Right(localPlan);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, String>> savePlanAndGetPaymentUrl(Plan plan) async {
    if (await networkInfo.isConnected) {
      try {
        final paymentUrl = await remoteDataSource.savePlanAndGetPaymentUrl(_convertToPlanModel(plan));
        return Right(paymentUrl);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Plan>> customizePlan(Plan plan) async {
    try {
      // Convert to PlanModel if it's not already
      final planModel = _convertToPlanModel(plan);
      
      // In a real app, this would call the remote data source
      // For the demo, we'll just return the converted plan
      return Right(planModel);
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Plan?>> getDraftPlan() async {
    try {
      final draftPlan = await localDataSource.getDraftPlan();
      return Right(draftPlan);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cacheDraftPlan(Plan plan) async {
    try {
      await localDataSource.cacheDraftPlan(_convertToPlanModel(plan));
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearDraftPlan() async {
    try {
      await localDataSource.clearDraftPlan();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  @override
  Future<Either<Failure, Plan>> saveDraftPlan(Plan plan) async {
    try {
      final planModel = _convertToPlanModel(plan);
      await localDataSource.cacheDraftPlan(planModel);
      return Right(planModel);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  @override
  Future<Either<Failure, Plan>> getDraftPlanOrCreateNew(Plan template) async {
    try {
      final draftPlan = await localDataSource.getDraftPlan();
      if (draftPlan != null) {
        return Right(draftPlan);
      }
      
      // Create new plan from template
      final newPlan = _convertToPlanModel(template).copyWith(
        isDraft: true,
        isCustomized: false,
      );
      
      await localDataSource.cacheDraftPlan(newPlan);
      return Right(newPlan);
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
  
  @override
  Future<Either<Failure, Plan>> resetPlanToDefaults(Plan plan) async {
    try {
      if (await networkInfo.isConnected) {
        final resetPlan = await remoteDataSource.resetPlanToDefaults(plan.id);
        return Right(resetPlan);
      } else {
        // Fallback to a simple reset by copying the plan with empty meals
        final resetPlan = _convertToPlanModel(plan).copyWith(
          mealsByDay: {},
          isCustomized: false,
        );
        return Right(resetPlan);
      }
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
  
  @override
  Future<Either<Failure, Plan>> updateMealInPlan({
    required Plan plan,
    required DayOfWeek day,
    required MealType type,
    required Thali thali,
  }) async {
    try {
      // Convert to PlanModel
      final planModel = _convertToPlanModel(plan);
      
      // Get or create a DailyMealsModel for the day
      final mealsByDayModel = Map<DayOfWeek, DailyMealsModel>.from(planModel.mealsByDay);
      final dailyMeals = mealsByDayModel[day] ?? DailyMealsModel();
      
      // Create an updated DailyMealsModel based on the meal type
      late DailyMealsModel updatedDailyMeals;
      
      switch (type) {
        case MealType.breakfast:
          updatedDailyMeals = DailyMealsModel(
            breakfast: thali,
            lunch: dailyMeals.lunch,
            dinner: dailyMeals.dinner,
          );
          break;
        case MealType.lunch:
          updatedDailyMeals = DailyMealsModel(
            breakfast: dailyMeals.breakfast,
            lunch: thali,
            dinner: dailyMeals.dinner,
          );
          break;
        case MealType.dinner:
          updatedDailyMeals = DailyMealsModel(
            breakfast: dailyMeals.breakfast,
            lunch: dailyMeals.lunch,
            dinner: thali,
          );
          break;
      }
      
      // Update the map
      mealsByDayModel[day] = updatedDailyMeals;
      
      // Create the updated plan
      final updatedPlan = planModel.copyWith(
        mealsByDay: mealsByDayModel,
        isCustomized: true,
      );
      
      return Right(updatedPlan);
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
  
  // Helper method to convert Plan to PlanModel
  PlanModel _convertToPlanModel(Plan plan) {
    if (plan is PlanModel) {
      return plan;
    }
    
    // Create new map with DailyMealsModel instances
    final mealsByDayModel = <DayOfWeek, DailyMealsModel>{};
    
    plan.mealsByDay.forEach((day, dailyMeals) {
      mealsByDayModel[day] = _convertToDailyMealsModel(dailyMeals);
    });
    
    return PlanModel(
      id: plan.id,
      name: plan.name,
      isVeg: plan.isVeg,
      duration: plan.duration,
      startDate: plan.startDate,
      endDate: plan.endDate,
      mealsByDay: mealsByDayModel,
      basePrice: plan.basePrice,
      isCustomized: plan.isCustomized,
      isDraft: plan.isDraft,
    );
  }
  
  // Helper method to convert DailyMeals to DailyMealsModel
  DailyMealsModel _convertToDailyMealsModel(DailyMeals dailyMeals) {
    if (dailyMeals is DailyMealsModel) {
      return dailyMeals;
    }
    
    return DailyMealsModel(
      breakfast: dailyMeals.breakfast,
      lunch: dailyMeals.lunch,
      dinner: dailyMeals.dinner,
    );
  }
}