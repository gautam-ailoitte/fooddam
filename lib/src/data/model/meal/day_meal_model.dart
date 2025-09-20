import 'package:foodam/src/data/model/meal/meal_dishes_model.dart';
import 'package:foodam/src/data/model/package/package_image_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/meal/day_meal_entity.dart';

part 'day_meal_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DayMealModel {
  final String? id;
  final String? name;
  final String? description;
  final String? dietaryPreference;
  final double? price;
  final MealDishesModel? dishes;
  final PackageImageModel? image;
  final bool? isAvailable;

  DayMealModel({
    this.id,
    this.name,
    this.description,
    this.dietaryPreference,
    this.price,
    this.dishes,
    this.image,
    this.isAvailable,
  });

  factory DayMealModel.fromJson(Map<String, dynamic> json) =>
      _$DayMealModelFromJson(json);

  Map<String, dynamic> toJson() => _$DayMealModelToJson(this);

  DayMeal toEntity() {
    return DayMeal(
      id: id,
      name: name,
      description: description,
      dietaryPreference: dietaryPreference,
      price: price,
      dishes: dishes?.toEntity(),
      image: image?.toEntity(),
      isAvailable: isAvailable,
    );
  }
}
