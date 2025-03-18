// lib/src/domain/usecase/meal/search_meals_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_repo.dart';

class SearchMealsUseCase extends UseCaseWithParams<List<Meal>, String> {
  final MealRepository repository;

  SearchMealsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call(String query) {
    return repository.searchMeals(query);
  }
}