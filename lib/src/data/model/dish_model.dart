
import 'package:foodam/src/data/model/nutritional_model.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';

class DishModel extends Dish {
  const DishModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    super.dietaryPreferences,
    super.ingredients,
    super.nutritionalInfo,
    super.quantity,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      category: json['category'],
      dietaryPreferences: json['dietaryPreferences'] != null
          ? List<String>.from(json['dietaryPreferences'])
          : null,
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : null,
      nutritionalInfo: json['nutritionalInfo'] != null
          ? NutritionalInfoModel.fromJson(json['nutritionalInfo'])
          : null,
      quantity: json['quantity'] != null
          ? QuantityModel.fromJson(json['quantity'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'dietaryPreferences': dietaryPreferences,
      'ingredients': ingredients,
      'nutritionalInfo': nutritionalInfo != null
          ? (nutritionalInfo as NutritionalInfoModel).toJson()
          : null,
      'quantity': quantity != null
          ? (quantity as QuantityModel).toJson()
          : null,
    };
  }
}

class QuantityModel extends Quantity {
  const QuantityModel({
    required super.value,
    required super.unit,
  });

  factory QuantityModel.fromJson(Map<String, dynamic> json) {
    return QuantityModel(
      value: json['value'].toDouble(),
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }
}

