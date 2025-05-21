import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';

class DayMeal extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String>? dietaryPreferences;
  final bool isAvailable;
  final Map<String, Dish> dishes;

  const DayMeal({
    required this.id,
    required this.name,
    required this.description,
    this.dietaryPreferences,
    required this.isAvailable,
    required this.dishes,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    dietaryPreferences,
    isAvailable,
    dishes,
  ];

  // Helper methods
  bool get hasBreakfast => dishes.containsKey('breakfast');
  bool get hasLunch => dishes.containsKey('lunch');
  bool get hasDinner => dishes.containsKey('dinner');

  Dish? get breakfastDish => dishes['breakfast'];
  Dish? get lunchDish => dishes['lunch'];
  Dish? get dinnerDish => dishes['dinner'];

  bool get isVegetarian => dietaryPreferences?.contains('vegetarian') ?? false;

  bool get isComplete => hasBreakfast && hasLunch && hasDinner;
}
