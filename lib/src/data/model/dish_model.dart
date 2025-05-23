// lib/src/data/model/dish_model.dart
import 'package:foodam/src/domain/entities/dish_entity.dart';

class DishModel {
  final String id;
  final String name;
  final String description;
  final List<String>? dietaryPreferences;
  final bool? isAvailable;
  final Map<String, dynamic>? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DishModel({
    required this.id,
    required this.name,
    required this.description,
    this.dietaryPreferences,
    this.isAvailable,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dietaryPreferences:
          json['dietaryPreferences'] != null
              ? List<String>.from(json['dietaryPreferences'])
              : null,
      isAvailable: json['isAvailable'] as bool? ?? true,
      image: json['image'] as Map<String, dynamic>?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'description': description,
    };

    if (dietaryPreferences != null) {
      data['dietaryPreferences'] = dietaryPreferences;
    }
    if (isAvailable != null) {
      data['isAvailable'] = isAvailable;
    }
    if (image != null) {
      data['image'] = image;
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
  Dish toEntity() {
    return Dish(
      id: id,
      name: name,
      description: description,
      dietaryPreferences: dietaryPreferences ?? [],
      isAvailable: isAvailable ?? true,
      imageUrl: _extractImageUrl(),
    );
  }

  // Mapper to convert entity to model
  factory DishModel.fromEntity(Dish entity) {
    return DishModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      dietaryPreferences: entity.dietaryPreferences,
      isAvailable: entity.isAvailable,
    );
  }

  // Helper to extract image URL from image object
  String? _extractImageUrl() {
    if (image == null) return null;
    // Handle different image object structures
    if (image!.containsKey('url')) {
      return image!['url'] as String?;
    }
    if (image!.containsKey('src')) {
      return image!['src'] as String?;
    }
    return null;
  }
}
