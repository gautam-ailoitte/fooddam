// lib/src/domain/usecase/meal/get_meals_by_dish_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_repo.dart';

class GetMealsByDishIdUseCase extends UseCaseWithParams<List<Meal>, String> {
  final MealRepository repository;

  GetMealsByDishIdUseCase(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call(String dishId) {
    return repository.getMealsByDishId(dishId);
  }
}
