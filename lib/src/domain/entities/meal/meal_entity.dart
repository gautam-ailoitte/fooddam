// lib/src/domain/entities/meal_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal/meal_dishes_entity.dart';
import 'package:foodam/src/domain/entities/package/package_image_entity.dart';

class Meal extends Equatable {
  final String id;
  final String name;
  final String description;
  final String dietaryPreference;
  final double price;
  final MealDishes? dishes;
  final PackageImage? image;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.dietaryPreference,
    required this.price,
    this.dishes,
    this.image,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    dietaryPreference,
    price,
    dishes,
    image,
    isAvailable,
    createdAt,
    updatedAt,
  ];

  bool get isVegetarian => dietaryPreference == 'vegetarian';
  bool get isNonVegetarian => dietaryPreference == 'non-vegetarian';
  String? get imageUrl => image?.url;
  bool get hasBreakfast => dishes?.hasBreakfast ?? false;
  bool get hasLunch => dishes?.hasLunch ?? false;
  bool get hasDinner => dishes?.hasDinner ?? false;
  int get mealCount => dishes?.mealCount ?? 0;
}
