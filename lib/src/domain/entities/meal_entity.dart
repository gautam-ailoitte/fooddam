
// lib/src/domain/entities/meal.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';

class Meal extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<Dish> dishes;
  final List<String>? ingredients;
  final List<String>? dietaryPreferences;
  final bool? isAvailable;

  const Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.dishes,
    this.ingredients,
    this.dietaryPreferences,
    this.isAvailable,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        dishes,
        ingredients,
        dietaryPreferences,
        isAvailable,
      ];
}