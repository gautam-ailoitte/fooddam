// Meal repository for managing meal-related operations
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';

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
