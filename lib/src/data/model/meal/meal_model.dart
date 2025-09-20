// lib/src/data/model/meal_model.dart
import 'package:foodam/src/data/model/meal/meal_dishes_model.dart';
import 'package:foodam/src/data/model/package/package_image_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/meal/meal_entity.dart';

part 'meal_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MealModel {
  final String? id;
  final String? name;
  final String? description;
  final String? dietaryPreference;
  final double? price;
  final MealDishesModel? dishes;
  final PackageImageModel? image;
  final bool? isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MealModel({
    this.id,
    this.name,
    this.description,
    this.dietaryPreference,
    this.price,
    this.dishes,
    this.image,
    this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) =>
      _$MealModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealModelToJson(this);

  Meal toEntity() {
    return Meal(
      id: id ?? '',
      name: name ?? '',
      description: description ?? '',
      dietaryPreference: dietaryPreference ?? '',
      price: price ?? 0.0,
      dishes: dishes?.toEntity(),
      image: image?.toEntity(),
      isAvailable: isAvailable ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory MealModel.fromEntity(Meal entity) {
    return MealModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      dietaryPreference: entity.dietaryPreference,
      price: entity.price,
      dishes:
          entity.dishes != null
              ? MealDishesModel.fromEntity(entity.dishes!)
              : null,
      image:
          entity.image != null
              ? PackageImageModel.fromEntity(entity.image!)
              : null,
      isAvailable: entity.isAvailable,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
