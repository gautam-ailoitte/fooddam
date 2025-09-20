// lib/src/domain/repo/meal_repository.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';

import '../entities/dish/dish_entity.dart';
import '../entities/meal/meal_entity.dart';

abstract class MealRepository {
  Future<Either<Failure, Meal>> getMealById(String mealId);
  Future<Either<Failure, Dish>> getDishById(String dishId);
}
