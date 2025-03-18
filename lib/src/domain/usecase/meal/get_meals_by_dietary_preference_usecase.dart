// lib/src/domain/usecase/meal/get_meals_by_dietary_preference_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_repo.dart';

class GetMealsByDietaryPreferenceUseCase extends UseCaseWithParams<List<Meal>, DietaryPreference> {
  final MealRepository repository;

  GetMealsByDietaryPreferenceUseCase(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call(DietaryPreference preference) {
    return repository.getMealsByDietaryPreference(preference);
  }
}
