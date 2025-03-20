import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';

class GetMealsByDietaryPreferenceUseCase implements UseCaseWithParams<List<Meal>, String> {
  final MealRepository repository;

  GetMealsByDietaryPreferenceUseCase(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call(String params) {
    return repository.getMealsByDietaryPreference(params);
  }
}
