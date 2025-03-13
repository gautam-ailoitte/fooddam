// lib/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/models/user_model.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/domain/repo/user_repo.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(email, password);
        await localDataSource.cacheUser(userModel);
        return Right(userModel);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final hasToken = await localDataSource.hasToken();
      return Right(hasToken);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getLastUser();
      return Right(userModel);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasActiveSubscription() async {
    if (await networkInfo.isConnected) {
      try {
        final hasSubscription =
            await remoteDataSource.checkSubscriptionStatus();
        return Right(hasSubscription);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final user = await localDataSource.getLastUser();
        return Right(user.hasActivePlan);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}

// lib/data/repositories/meal_repository_impl.dart

// lib/src/data/repo/meal_repo_impl.dart

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
  Future<Either<Failure, List<Meal>>> getMealOptions(MealType type) async {
    if (await networkInfo.isConnected) {
      try {
        final meals = await remoteDataSource.getMealOptions(type);
        await localDataSource.cacheMealOptions(type, meals);
        return Right(meals);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final meals = await localDataSource.getLastMealOptions(type);
        return Right(meals);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<Thali>>> getThaliOptions(MealType type) async {
    if (await networkInfo.isConnected) {
      try {
        final thalis = await remoteDataSource.getThaliOptions(type);
        await localDataSource.cacheThaliOptions(type, thalis);
        return Right(thalis);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final thalis = await localDataSource.getLastThaliOptions(type);
        return Right(thalis);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
 // In meal_repository_impl.dart
@override
Future<Either<Failure, Thali>> customizeThali(
  Thali thali,
  List<Meal> selectedMeals,
) async {
  try {
    // Print debug info
    print('Repository: Customizing thali ${thali.id} with ${selectedMeals.length} meals');
    
    // Make sure we're creating the right type
    final ThaliModel customizedThali = thali is ThaliModel 
        ? ThaliModel(
            id: thali.id,
            name: 'Customized ${thali.name}',
            type: thali.type,
            basePrice: thali.basePrice,
            defaultMeals: thali.defaultMeals,
            selectedMeals: selectedMeals,
            maxCustomizations: thali.maxCustomizations,
          )
        : ThaliModel(
            id: thali.id,
            name: 'Customized Thali',
            type: thali.type,
            basePrice: thali.basePrice,
            defaultMeals: thali is ThaliModel ? thali.defaultMeals : [],
            selectedMeals: selectedMeals,
            maxCustomizations: thali.maxCustomizations,
          );
    
    // Cache the customized thali if applicable
    await localDataSource.cacheCustomizedThali(customizedThali);
      
    print('Repository: Customization complete for thali ${customizedThali.id}');
    return Right(customizedThali);
  } catch (e) {
    print('Repository: Error customizing thali: ${e.toString()}');
    return Left(UnexpectedFailure());
  }
}
  
  // New methods
  
  @override
  Future<Either<Failure, Thali>> getDefaultThali(MealType type, ThaliType preferredType) async {
    try {
      // First try to get thali options from remote or cached data
      final thaliOptionsResult = await getThaliOptions(type);
      
      return thaliOptionsResult.fold(
        (failure) => Left(failure),
        (thalis) {
          // Find the thali matching the preferred type
          try {
            final defaultThali = thalis.firstWhere(
              (thali) => thali.type == preferredType,
              orElse: () => thalis.first, // Fallback to first thali if preferred not found
            );
            return Right(defaultThali);
          } catch (e) {
            return Left(UnexpectedFailure());
          }
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
  
  @override
  Future<Either<Failure, Thali>> resetThaliToDefault(Thali thali) async {
    try {
      // Get thali options for this meal type
      final thaliOptionsResult = await getThaliOptions(thali.type as MealType);
      
      return thaliOptionsResult.fold(
        (failure) => Left(failure),
        (thalis) {
          // Find the matching default thali based on ID or type
          try {
            final defaultThali = thalis.firstWhere(
              (t) => t.id == thali.id || t.type == thali.type,
              orElse: () => thalis.first, // Fallback to first thali if not found
            );
            return Right(defaultThali);
          } catch (e) {
            return Left(UnexpectedFailure());
          }
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
  
  @override
  Future<Either<Failure, bool>> compareThalis(Thali thali1, Thali thali2) async {
    try {
      // Use the helper method in Thali to compare the meals
      if (thali1 is ThaliModel && thali2 is ThaliModel) {
        final haveSameMeals = thali1.hasSameMeals(thali2);
        return Right(haveSameMeals);
      } else {
        // If different types, do manual comparison
        if (thali1.selectedMeals.length != thali2.selectedMeals.length) {
          return Right(false);
        }
        
        // Sort both lists by ID to ensure consistent comparison
        final sortedMeals1 = List<Meal>.from(thali1.selectedMeals)
          ..sort((a, b) => a.id.compareTo(b.id));
        final sortedMeals2 = List<Meal>.from(thali2.selectedMeals)
          ..sort((a, b) => a.id.compareTo(b.id));
        
        // Compare each meal by ID
        for (int i = 0; i < sortedMeals1.length; i++) {
          if (sortedMeals1[i].id != sortedMeals2[i].id) {
            return Right(false);
          }
        }
        
        return Right(true);
      }
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
// lib/data/repositories/plan_repository_impl.dart

// lib/src/data/repo/plan_repo_impl.dart




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
  Future<Either<Failure, List<Plan>>> getAvailablePlans() async {
    if (await networkInfo.isConnected) {
      try {
        final plans = await remoteDataSource.getAvailablePlans();
        await localDataSource.cachePlans(plans);
        return Right(plans);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final plans = await localDataSource.getLastPlans();
        return Right(plans);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Plan?>> getActivePlan() async {
    if (await networkInfo.isConnected) {
      try {
        final plan = await remoteDataSource.getActivePlan();
        if (plan != null) {
          await localDataSource.cacheActivePlan(plan);
        }
        return Right(plan);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final plan = await localDataSource.getLastActivePlan();
        return Right(plan);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Plan>> createPlan(Plan plan) async {
    if (await networkInfo.isConnected) {
      try {
        final createdPlan = await remoteDataSource.createPlan(
          plan as PlanModel,
        );
        await localDataSource.cacheDraftPlan(createdPlan);
        return Right(createdPlan);
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
      await localDataSource.cacheDraftPlan(plan as PlanModel);
      return Right(plan);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> savePlanAndGetPaymentUrl(Plan plan) async {
    if (await networkInfo.isConnected) {
      try {
        final paymentUrl = await remoteDataSource.savePlanAndGetPaymentUrl(
          plan as PlanModel,
        );
        return Right(paymentUrl);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cacheDraftPlan(Plan plan) async {
    try {
      // Convert Plan to PlanModel if needed
      final planModel =
          plan is PlanModel
              ? plan
              : PlanModel(
                id: plan.id,
                name: plan.name,
                isVeg: plan.isVeg,
                duration: plan.duration,
                startDate: plan.startDate,
                endDate: plan.endDate,
                mealsByDay: plan.mealsByDay,
                basePrice: plan.basePrice,
                isCustomized: plan.isCustomized,
                isDraft: plan.isDraft,
              );

      await localDataSource.cacheDraftPlan(planModel);
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, PlanModel?>> getDraftPlan() async {
    try {
      final draftPlan = await localDataSource.getDraftPlan();
      return Right(draftPlan);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearDraftPlan() async {
    try {
      await localDataSource.clearDraftPlan();
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
  
  @override
  Future<Either<Failure, Plan>> saveDraftPlan(Plan plan) {
    try {
      final updatedPlan = plan.copyWith(isDraft: true);
      return Future.value(Right(updatedPlan));
    } catch (e) {
      return Future.value(Left(UnexpectedFailure()));
    }
  }
  
  // New methods
  
  @override
  Future<Either<Failure, Plan>> getDraftPlanOrCreateNew(Plan template) async {
    try {
      // First try to get existing draft
      final draftResult = await getDraftPlan();
      
      return draftResult.fold(
        (failure) async {
          // No draft found or error, create new from template
          final createResult = await createPlan(template);
          return createResult.fold(
            (failure) => Left(failure),
            (newPlan) => Right(newPlan),
          );
        },
        (existingDraft) {
          // Draft found, return it
          if (existingDraft != null) {
            return Right(existingDraft);
          } else {
            // No draft but no error, create new
            return createPlan(template);
          }
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
  
  @override
  Future<Either<Failure, Plan>> resetPlanToDefaults(Plan plan) async {
    if (await networkInfo.isConnected) {
      try {
        // Use remote data source to reset plan
        final resetPlan = await remoteDataSource.resetPlanToDefaults(plan.id);
        await localDataSource.cacheDraftPlan(resetPlan);
        return Right(resetPlan);
      } on ServerException {
        // Fallback to local reset if server fails
        return _localResetPlan(plan);
      }
    } else {
      // Use local data for offline reset
      return _localResetPlan(plan);
    }
  }
  
  // Helper method for local plan reset
  Future<Either<Failure, Plan>> _localResetPlan(Plan plan) async {
    try {
      // Get all available plans to find the matching template
      final plansResult = await getAvailablePlans();
      
      return plansResult.fold(
        (failure) => Left(failure),
        (plans) {
          // Find matching template by properties
          final template = plans.firstWhere(
            (p) => p.id == plan.id || 
                   (p.isVeg == plan.isVeg && p.duration == plan.duration),
            orElse: () => plan,
          );
          
          // Create a new plan with reset meals but keep the ID
          final resetPlan = template.copyWith(
            id: plan.id,
            isDraft: true,
          );
          
          // Cache the reset plan
          localDataSource.cacheDraftPlan(resetPlan as PlanModel);
          
          return Right(resetPlan);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
  
  @override
  Future<Either<Failure, Plan>> updateMealInPlan({
    required Plan plan,
    required DayOfWeek day, 
    required MealType type, 
    required Thali thali
  }) async {
    try {
      // Use the helper method in Plan to update the meal
      final updatedPlan = plan.updateMeal(
        day: day,
        mealType: type,
        thali: thali,
      );
      
      // Cache the updated plan
      if (updatedPlan is PlanModel) {
        await localDataSource.cacheDraftPlan(updatedPlan);
      } else {
        // Convert to PlanModel if needed
        final planModel = PlanModel(
          id: updatedPlan.id,
          name: updatedPlan.name,
          isVeg: updatedPlan.isVeg,
          duration: updatedPlan.duration,
          startDate: updatedPlan.startDate,
          endDate: updatedPlan.endDate,
          mealsByDay: updatedPlan.mealsByDay,
          basePrice: updatedPlan.basePrice,
          isCustomized: updatedPlan.isCustomized,
          isDraft: updatedPlan.isDraft,
        );
        await localDataSource.cacheDraftPlan(planModel);
      }
      
      return Right(updatedPlan);
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}

   //