// lib/src/data/model/meal_model.dart
import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

class MealModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<DishModel>? dishes;
  final List<String>? dietaryPreferences;
  final String? imageUrl;
  final bool? isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MealModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.dishes,
    this.dietaryPreferences,
    this.imageUrl,
    this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    // Handle dishes which may not be present in all API responses
    List<DishModel>? dishList;
    if (json['dishes'] != null) {
      dishList =
          (json['dishes'] as List)
              .map((dish) => DishModel.fromJson(dish))
              .toList();
    }

    return MealModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _parsePrice(json['price']),
      dishes: dishList,
      dietaryPreferences:
          json['dietaryPreferences'] != null
              ? List<String>.from(json['dietaryPreferences'])
              : null,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Add helper method for safe price parsing
  static double _parsePrice(dynamic priceValue) {
    if (priceValue == null) return 0.0;

    if (priceValue is int) {
      return priceValue.toDouble();
    } else if (priceValue is double) {
      return priceValue;
    } else if (priceValue is String) {
      return double.tryParse(priceValue) ?? 0.0;
    } else if (priceValue is num) {
      return priceValue.toDouble();
    }

    return 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };

    if (dishes != null) {
      data['dishes'] = dishes!.map((dish) => dish.toJson()).toList();
    }
    if (dietaryPreferences != null) {
      data['dietaryPreferences'] = dietaryPreferences;
    }
    if (isAvailable != null) {
      data['isAvailable'] = isAvailable;
    }
    if (createdAt != null) {
      data['createdAt'] = createdAt!.toIso8601String();
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt!.toIso8601String();
    }

    return data;
  }

  // Mapper to convert model to entity
  Meal toEntity() {
    return Meal(
      id: id,
      name: name,
      description: description,
      price: price,
      dishes: dishes?.map((dish) => dish.toEntity()).toList() ?? [],
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
      dishes: entity.dishes.map((dish) => DishModel.fromEntity(dish)).toList(),
      dietaryPreferences: entity.dietaryPreferences,
      imageUrl: entity.imageUrl,
      isAvailable: entity.isAvailable,
    );
  }
}
