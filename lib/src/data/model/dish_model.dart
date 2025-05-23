import 'package:foodam/src/domain/entities/dish_entity.dart';

class DishModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;

  DishModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _parsePrice(json['price']),
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
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
    }

    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  // Mapper to convert model to entity
  Dish toEntity() {
    return Dish(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
      imageUrl: imageUrl,
    );
  }

  // Mapper to convert entity to model
  factory DishModel.fromEntity(Dish entity) {
    return DishModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      category: entity.category,
      imageUrl: entity.imageUrl,
    );
  }
}
