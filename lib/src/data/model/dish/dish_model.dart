// lib/src/data/model/dish_model.dart
import 'package:foodam/src/data/model/package/package_image_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/dish/dish_entity.dart';

part 'dish_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DishModel {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final String? dietaryPreference;
  final bool? isAvailable;
  final PackageImageModel? image;

  DishModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.dietaryPreference,
    this.isAvailable,
    this.image,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) =>
      _$DishModelFromJson(json);

  Map<String, dynamic> toJson() => _$DishModelToJson(this);

  Dish toEntity() {
    return Dish(
      id: id ?? '',
      name: name ?? '',
      description: description ?? '',
      price: price ?? 0.0,
      dietaryPreference: dietaryPreference ?? '',
      isAvailable: isAvailable ?? true,
      image: image?.toEntity(),
    );
  }

  factory DishModel.fromEntity(Dish entity) {
    return DishModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      dietaryPreference: entity.dietaryPreference,
      isAvailable: entity.isAvailable,
      image:
          entity.image != null
              ? PackageImageModel.fromEntity(entity.image!)
              : null,
    );
  }
}
