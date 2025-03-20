
import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

class MealModel extends Meal {
  const MealModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.dishes,
    super.ingredients,
    super.dietaryPreferences,
    super.isAvailable,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      dishes: (json['dishes'] as List)
          .map((dish) => DishModel.fromJson(dish))
          .toList(),
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : null,
      dietaryPreferences: json['dietaryPreferences'] != null
          ? List<String>.from(json['dietaryPreferences'])
          : null,
      isAvailable: json['isAvailable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'dishes': (dishes as List<DishModel>)
          .map((dish) => dish.toJson())
          .toList(),
      'ingredients': ingredients,
      'dietaryPreferences': dietaryPreferences,
      'isAvailable': isAvailable,
    };
  }
}

