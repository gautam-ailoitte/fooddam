

import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

class MealModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<DishModel> dishes;
  final List<String>? dietaryPreferences;
  final String? imageUrl;
  final bool? isAvailable;

  MealModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.dishes,
    this.dietaryPreferences,
    this.imageUrl,
    this.isAvailable,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] is int) 
          ? (json['price'] as int).toDouble() 
          : json['price'],
      dishes: (json['dishes'] as List)
          .map((dish) => DishModel.fromJson(dish))
          .toList(),
      dietaryPreferences: json['dietaryPreferences'] != null
          ? List<String>.from(json['dietaryPreferences'])
          : null,
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'dishes': dishes.map((dish) => dish.toJson()).toList(),
      'dietaryPreferences': dietaryPreferences,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }

  // Mapper to convert model to entity
  Meal toEntity() {
    return Meal(
      id: id,
      name: name,
      description: description,
      price: price,
      dishes: dishes.map((dish) => dish.toEntity()).toList(),
      dietaryPreferences: dietaryPreferences,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
    );
  }

  // Mapper to convert entity to model
  factory MealModel.fromEntity(Meal entity) {
    return MealModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      dishes: entity.dishes
          .map((dish) => DishModel.fromEntity(dish))
          .toList(),
      dietaryPreferences: entity.dietaryPreferences,
      imageUrl: entity.imageUrl,
      isAvailable: entity.isAvailable,
    );
  }
}
