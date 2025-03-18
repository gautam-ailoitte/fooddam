// lib/src/domain/repositories/dish_repository.dart
// Previously meal_repository.dart

import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';

abstract class DishRepository {
  /// Get all available dish options with optional filtering
  Future<Either<Failure, List<Dish>>> getDishes({
    FoodCategory? category,
    DietaryPreference? dietaryPreference,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    int skip = 0,
  });

  /// Get a specific dish by ID
  Future<Either<Failure, Dish>> getDishById(String id);
  
  /// Search dishes by name or description
  Future<Either<Failure, List<Dish>>> searchDishes(String query);
  
  /// Get dishes by list of IDs
  Future<Either<Failure, List<Dish>>> getDishesByIds(List<String> ids);
  
  /// Get dishes by category
  Future<Either<Failure, List<Dish>>> getDishesByCategory(FoodCategory category);
  
  /// Get dishes by dietary preference
  Future<Either<Failure, List<Dish>>> getDishesByDietaryPreference(DietaryPreference preference);
}