

// lib/src/domain/entities/dish.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/nutritional_entity.dart';

class Dish extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String>? dietaryPreferences;
  final List<String>? ingredients;
  final NutritionalInfo? nutritionalInfo;
  final Quantity? quantity;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.dietaryPreferences,
    this.ingredients,
    this.nutritionalInfo,
    this.quantity,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        category,
        dietaryPreferences,
        ingredients,
        nutritionalInfo,
        quantity,
      ];
}

class Quantity extends Equatable {
  final double value;
  final String unit;

  const Quantity({
    required this.value,
    required this.unit,
  });

  @override
  List<Object?> get props => [value, unit];
}
