
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';

class GetDishDetailsUseCase implements UseCaseWithParams<Dish, String> {
  final MealRepository repository;

  GetDishDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, Dish>> call(String params) {
    return repository.getDishDetails(params);
  }
}