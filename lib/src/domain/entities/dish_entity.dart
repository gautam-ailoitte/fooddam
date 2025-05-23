// lib/src/domain/entities/dish_entity.dart
import 'package:equatable/equatable.dart';

class Dish extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> dietaryPreferences;
  final bool isAvailable;
  final String? imageUrl;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    this.dietaryPreferences = const [],
    this.isAvailable = true,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    dietaryPreferences,
    isAvailable,
    imageUrl,
  ];

  // Helper methods
  bool get isVegetarian => dietaryPreferences.contains('vegetarian');
  bool get isNonVegetarian => dietaryPreferences.contains('non-vegetarian');
  bool get isVegan => dietaryPreferences.contains('vegan');
  bool get isGlutenFree => dietaryPreferences.contains('gluten-free');

  String get dietaryDisplayText {
    if (dietaryPreferences.isEmpty) return 'No specific dietary preference';
    return dietaryPreferences.join(', ');
  }
}
