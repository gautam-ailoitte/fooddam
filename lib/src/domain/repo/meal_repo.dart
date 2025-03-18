// lib/src/domain/repositories/meal_repository.dart
// Previously thali_repository.dart

import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

abstract class MealRepository {
  /// Get all available meals with optional filtering
  Future<Either<Failure, List<Meal>>> getMeals({
    DietaryPreference? dietaryPreference,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    int skip = 0,
  });

  /// Get a specific meal by ID
  Future<Either<Failure, Meal>> getMealById(String id);
  
  /// Search meals by name or description
  Future<Either<Failure, List<Meal>>> searchMeals(String query);
  
  /// Get meals by dietary preference
  Future<Either<Failure, List<Meal>>> getMealsByDietaryPreference(DietaryPreference preference);
  
  /// Get meals containing a specific dish
  Future<Either<Failure, List<Meal>>> getMealsByDishId(String dishId);
  
  /// Get meals by list of IDs
  Future<Either<Failure, List<Meal>>> getMealsByIds(List<String> ids);
}