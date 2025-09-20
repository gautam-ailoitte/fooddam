// lib/src/domain/entities/dish_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/package/package_image_entity.dart';

class Dish extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String dietaryPreference;
  final bool isAvailable;
  final PackageImage? image;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.dietaryPreference,
    required this.isAvailable,
    this.image,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    dietaryPreference,
    isAvailable,
    image,
  ];

  bool get isVegetarian => dietaryPreference == 'vegetarian';
  bool get isNonVegetarian => dietaryPreference == 'non-vegetarian';
  String? get imageUrl => image?.url;
}
