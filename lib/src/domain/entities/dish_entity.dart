// lib/src/domain/entities/dish_entity.dart
// This replaces the previous meal_entity.dart

import 'package:equatable/equatable.dart';

enum FoodCategory {
  appetizer,
  mainCourse,
  dessert,
  beverage,
  sideDish,
  soup,
  salad,
  breakfast,
  snack
}

enum DietaryPreference {
  vegetarian,
  nonVegetarian,
  vegan,
  glutenFree,
  dairyFree,
  nutFree,
  pescatarian,
  keto,
  paleo
}

enum QuantityUnit {
  grams,
  milliliters,
  pieces,
  servings,
  tablespoons,
  teaspoons,
  cups,
  ounces,
  pounds
}

class NutritionalValue extends Equatable {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  const NutritionalValue({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
     this.fiber = 0,
     this.sugar = 0,
  });

  @override
  List<Object?> get props => [calories, protein, carbs, fat, fiber, sugar];
}

class Quantity extends Equatable {
  final double value;
  final QuantityUnit unit;

  const Quantity({
    required this.value,
    required this.unit,
  });

  @override
  List<Object?> get props => [value, unit];
}

class Dish extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final FoodCategory category;
  final List<DietaryPreference> dietaryPreferences;
  final String imageUrl;
  final NutritionalValue? nutritionalInfo;
  final Quantity quantity;
  final List<String> ingredients;
  final bool isAvailable;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.dietaryPreferences,
    required this.imageUrl,
    this.nutritionalInfo,
    required this.quantity,
    required this.ingredients,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        category,
        dietaryPreferences,
        imageUrl,
        nutritionalInfo,
        quantity,
        ingredients,
        isAvailable,
      ];
}