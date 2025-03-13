// lib/src/domain/repo/user_repo.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

// Authentication repository
abstract class AuthRepository {
  /// Login user with email and password
  Future<Either<Failure, User>> login(String email, String password);

  /// Check if user is logged in
  Future<Either<Failure, bool>> isLoggedIn();

  /// Get the current logged in user
  Future<Either<Failure, User>> getCurrentUser();

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Check if user has active subscription
  Future<Either<Failure, bool>> hasActiveSubscription();
}

// Meal repository for managing meal-related operations
abstract class MealRepository {
  /// Get all available meal options for a specific meal type
  Future<Either<Failure, List<Meal>>> getMealOptions(MealType type);

  /// Get all available thali options for a specific meal type
  Future<Either<Failure, List<Thali>>> getThaliOptions(MealType type);

  /// Customize a thali by adding or removing meals
  Future<Either<Failure, Thali>> customizeThali(
    Thali thali,
    List<Meal> selectedMeals,
  );
  
  /// Get default thali for a meal type and preferred thali type
  Future<Either<Failure, Thali>> getDefaultThali(MealType type, ThaliType preferredType);
  
  /// Reset a thali to its default meals
  Future<Either<Failure, Thali>> resetThaliToDefault(Thali thali);
  
  /// Compare two thalis to check if they have the same meals
  Future<Either<Failure, bool>> compareThalis(Thali thali1, Thali thali2);
}

// Plan repository for handling meal plans
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