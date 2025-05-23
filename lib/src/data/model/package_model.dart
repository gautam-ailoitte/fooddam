// lib/src/data/model/package_model.dart
import 'package:foodam/src/data/model/package_slot_model.dart';
import 'package:foodam/src/data/model/price_option_model.dart';
import 'package:foodam/src/data/model/price_range_model.dart';
import 'package:foodam/src/domain/entities/price_range.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/pacakge_entity.dart';
import '../../domain/entities/price_option.dart';

part 'package_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PackageModel {
  final String? id;
  final String? name;
  final String? description;
  final int? week;
  final PriceRangeModel? priceRange;
  final List<PriceOptionModel>? price;
  final List<String>? dietaryPreferences;
  final Map<String, dynamic>? image;
  final int? noOfSlots;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Updated to use proper slot model
  final List<PackageSlotModel>? slots;

  PackageModel({
    this.id,
    this.name,
    this.description,
    this.week,
    this.priceRange,
    this.price,
    this.dietaryPreferences,
    this.image,
    this.noOfSlots,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.slots,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) =>
      _$PackageModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageModelToJson(this);

  // Mapper to convert model to entity
  Package toEntity() {
    return Package(
      id: id ?? '',
      name: name ?? '',
      description: description ?? '',
      week: week ?? 0,
      priceRange:
          priceRange != null
              ? PriceRange(min: priceRange!.min ?? 0, max: priceRange!.max ?? 0)
              : null,
      priceOptions:
          price
              ?.map(
                (option) => PriceOption(
                  numberOfMeals: option.numberOfMeals ?? 0,
                  price: option.price ?? 0,
                ),
              )
              .toList() ??
          [],
      dietaryPreferences: dietaryPreferences ?? [],
      isActive: isActive ?? false,
      noOfSlots: noOfSlots ?? 0,
      slots: slots?.map((slot) => slot.toEntity()).toList() ?? [],
    );
  }

  // Mapper to convert entity to model
  factory PackageModel.fromEntity(Package entity) {
    return PackageModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      week: entity.week,
      priceRange:
          entity.priceRange != null
              ? PriceRangeModel(
                min: entity.priceRange!.min,
                max: entity.priceRange!.max,
              )
              : null,
      price:
          entity.priceOptions
              ?.map(
                (option) => PriceOptionModel(
                  numberOfMeals: option.numberOfMeals,
                  price: option.price,
                ),
              )
              .toList(),
      dietaryPreferences: entity.dietaryPreferences,
      isActive: entity.isActive,
      noOfSlots: entity.noOfSlots,
      slots:
          entity.slots
              .map((slot) => PackageSlotModel.fromEntity(slot))
              .toList(),
    );
  }
}
