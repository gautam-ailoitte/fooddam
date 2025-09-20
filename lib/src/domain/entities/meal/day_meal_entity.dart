import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal/meal_dishes_entity.dart';
import 'package:foodam/src/domain/entities/package/package_image_entity.dart';

class DayMeal extends Equatable {
  final String? id;
  final String? name;
  final String? description;
  final String? dietaryPreference;
  final double? price;
  final MealDishes? dishes;
  final PackageImage? image;
  final bool? isAvailable;

  const DayMeal({
    this.id,
    this.name,
    this.description,
    this.dietaryPreference,
    this.price,
    this.dishes,
    this.image,
    this.isAvailable,
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
  ];

  bool get isVegetarian => dietaryPreference?.toLowerCase() == 'vegetarian';
  bool get isNonVegetarian =>
      dietaryPreference?.toLowerCase() == 'non-vegetarian';
  String get displayName => name ?? 'Unknown Meal';
  double get displayPrice => price ?? 0.0;
}
