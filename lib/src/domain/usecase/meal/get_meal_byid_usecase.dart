import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';

class GetMealByIdUseCase implements UseCaseWithParams<Meal, String> {
  final MealRepository repository;

  GetMealByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Meal>> call(String mealId) {
    return repository.getMealById(mealId);
  }
}