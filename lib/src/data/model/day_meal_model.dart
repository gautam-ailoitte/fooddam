import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/domain/entities/day_meal.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'day_meal_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DayMealModel {
  final String? id;
  final String? name;
  final String? description;
  final List<String>? dietaryPreferences;
  final bool? isAvailable;
  final Map<String, dynamic>? image;

  @JsonKey(name: 'dishes')
  final Map<String, DishModel>? mealDishes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  DayMealModel({
    this.id,
    this.name,
    this.description,
    this.dietaryPreferences,
    this.isAvailable,
    this.image,
    this.mealDishes,
    this.createdAt,
    this.updatedAt,
  });

  factory DayMealModel.fromJson(Map<String, dynamic> json) {
    // Process special dishes structure
    Map<String, DishModel>? dishes;
    if (json['dishes'] != null) {
      dishes = {};
      final dishesJson = json['dishes'] as Map<String, dynamic>;

      if (dishesJson.containsKey('breakfast')) {
        dishes['breakfast'] = DishModel.fromJson(dishesJson['breakfast']);
      }
      if (dishesJson.containsKey('lunch')) {
        dishes['lunch'] = DishModel.fromJson(dishesJson['lunch']);
      }
      if (dishesJson.containsKey('dinner')) {
        dishes['dinner'] = DishModel.fromJson(dishesJson['dinner']);
      }
    }

    return DayMealModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      dietaryPreferences:
          (json['dietaryPreferences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      isAvailable: json['isAvailable'] as bool?,
      image: json['image'] as Map<String, dynamic>?,
      mealDishes: dishes,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() => _$DayMealModelToJson(this);

  // Mapper to convert model to entity
  DayMeal toEntity() {
    Map<String, Dish> entityDishes = {};

    if (mealDishes != null) {
      mealDishes!.forEach((key, value) {
        entityDishes[key] = value.toEntity();
      });
    }

    return DayMeal(
      id: id ?? '',
      name: name ?? '',
      description: description ?? '',
      dietaryPreferences: dietaryPreferences ?? [],
      isAvailable: isAvailable ?? false,
      dishes: entityDishes,
    );
  }

  // Mapper to convert entity to model
  factory DayMealModel.fromEntity(DayMeal entity) {
    Map<String, DishModel> modelDishes = {};

    entity.dishes.forEach((key, value) {
      modelDishes[key] = DishModel.fromEntity(value);
    });

    return DayMealModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      dietaryPreferences: entity.dietaryPreferences,
      isAvailable: entity.isAvailable,
      mealDishes: modelDishes,
    );
  }
}
