// lib/src/domain/usecase/meal/get_meals_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/repo/meal_repo.dart';

class GetMealsParams {
  final DietaryPreference? dietaryPreference;
  final double? minPrice;
  final double? maxPrice;
  final int limit;
  final int skip;

  GetMealsParams({
    this.dietaryPreference,
    this.minPrice,
    this.maxPrice,
    this.limit = 10,
    this.skip = 0,
  });
}

class GetMealsUseCase extends UseCaseWithParams<List<Meal>, GetMealsParams> {
  final MealRepository repository;

  GetMealsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call(GetMealsParams params) {
    return repository.getMeals(
      dietaryPreference: params.dietaryPreference,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      limit: params.limit,
      skip: params.skip,
    );
  }
}
