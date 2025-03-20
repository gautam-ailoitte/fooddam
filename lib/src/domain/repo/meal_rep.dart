// lib/src/domain/repo/meal_repository.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

abstract class MealRepository {
  Future<Either<Failure, List<Meal>>> getAvailableMeals();
  Future<Either<Failure, Meal>> getMealDetails(String mealId);
  Future<Either<Failure, List<Meal>>> getMealsByType(String type);
  Future<Either<Failure, List<Meal>>> getMealsByDietaryPreference(String preference);
  Future<Either<Failure, List<Dish>>> getDishes();
  Future<Either<Failure, Dish>> getDishDetails(String dishId);
}
