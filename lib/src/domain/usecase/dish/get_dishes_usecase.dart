
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';

class GetDishesUseCase implements UseCase<List<Dish>> {
  final MealRepository repository;

  GetDishesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Dish>>> call() {
    return repository.getDishes();
  }
}