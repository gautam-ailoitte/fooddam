// lib/src/data/model/meal_dishes_model.dart
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/meal/meal_dishes_entity.dart';
import '../dish/dish_model.dart';

part 'meal_dishes_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MealDishesModel {
  final DishModel? breakfast;
  final DishModel? lunch;
  final DishModel? dinner;

  MealDishesModel({this.breakfast, this.lunch, this.dinner});

  factory MealDishesModel.fromJson(Map<String, dynamic> json) =>
      _$MealDishesModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealDishesModelToJson(this);

  MealDishes toEntity() {
    return MealDishes(
      breakfast: breakfast?.toEntity(),
      lunch: lunch?.toEntity(),
      dinner: dinner?.toEntity(),
    );
  }

  factory MealDishesModel.fromEntity(MealDishes entity) {
    return MealDishesModel(
      breakfast:
          entity.breakfast != null
              ? DishModel.fromEntity(entity.breakfast!)
              : null,
      lunch: entity.lunch != null ? DishModel.fromEntity(entity.lunch!) : null,
      dinner:
          entity.dinner != null ? DishModel.fromEntity(entity.dinner!) : null,
    );
  }
}
