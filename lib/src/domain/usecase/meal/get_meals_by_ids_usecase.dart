// lib/src/domain/usecase/meal/get_meals_by_ids_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_repo.dart';

class GetMealsByIdsUseCase extends UseCaseWithParams<List<Meal>, List<String>> {
  final MealRepository repository;

  GetMealsByIdsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call(List<String> mealIds) {
    return repository.getMealsByIds(mealIds);
  }
}