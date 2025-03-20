import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';

class GetAvailableMealsUseCase implements UseCase<List<Meal>> {
  final MealRepository repository;

  GetAvailableMealsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call() {
    return repository.getAvailableMeals();
  }
}
