// lib/src/domain/entities/meal_entity.dart
// This replaces the previous thali_entity.dart

import 'package:equatable/equatable.dart';
import 'dish_entity.dart';

class MealOption extends Equatable {
  final String dishId;
  final int defaultQuantity;
  
  const MealOption({
    required this.dishId,
    this.defaultQuantity = 1,
  });
  
  @override
  List<Object?> get props => [dishId, defaultQuantity];
}

class MealCategory extends Equatable {
  final String name;
  final String description;
  final List<MealOption> options;
  final int minSelections;
  final int maxSelections;
  final bool isRequired;
  
  const MealCategory({
    required this.name,
    required this.description,
    required this.options,
    required this.minSelections,
    required this.maxSelections,
    this.isRequired = false,
  });
  
  @override
  List<Object?> get props => [
    name, 
    description, 
    options, 
    minSelections, 
    maxSelections, 
    isRequired
  ];
}

class Meal extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<MealCategory> categories;
  final List<DietaryPreference> dietaryPreferences;
  final String imageUrl;
  final bool isAvailable;

  const Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categories,
    required this.dietaryPreferences,
    required this.imageUrl,
    this.isAvailable = true,
  });

  // Calculate total base price, considering minimum required dishes from each category
  double get basePrice {
    return price; // Price is already defined at the meal level
  }

  bool containsDish(String dishId) {
    for (var category in categories) {
      for (var option in category.options) {
        if (option.dishId == dishId) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    categories,
    dietaryPreferences,
    imageUrl,
    isAvailable,
  ];
}