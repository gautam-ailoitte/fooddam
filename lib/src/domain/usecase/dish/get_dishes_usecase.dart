// lib/src/domain/usecase/dish/get_dishes_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/repo/dish_repository.dart';

class GetDishesParams {
  final FoodCategory? category;
  final DietaryPreference? dietaryPreference;
  final double? minPrice;
  final double? maxPrice;
  final int limit;
  final int skip;

  GetDishesParams({
    this.category,
    this.dietaryPreference,
    this.minPrice,
    this.maxPrice,
    this.limit = 10,
    this.skip = 0,
  });
}

class GetDishesUseCase extends UseCaseWithParams<List<Dish>, GetDishesParams> {
  final DishRepository repository;

  GetDishesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Dish>>> call(GetDishesParams params) {
    return repository.getDishes(
      category: params.category,
      dietaryPreference: params.dietaryPreference,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      limit: params.limit,
      skip: params.skip,
    );
  }
}