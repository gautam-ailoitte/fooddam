import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';

class GetMealDetailsUseCase implements UseCaseWithParams<Meal, String> {
  final MealRepository repository;

  GetMealDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, Meal>> call(String params) {
    return repository.getMealDetails(params);
  }

}