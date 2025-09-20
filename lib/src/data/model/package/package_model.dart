// lib/src/data/model/package_model.dart
import 'package:foodam/src/data/model/package/package_image_model.dart';
import 'package:foodam/src/data/model/package/package_slot_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/package/package_entity.dart';

part 'package_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PackageModel {
  final int? index;
  final String? id;
  final String? name;
  final String? description;
  final int? week;
  final double? totalPrice;
  final String? dietaryPreference;
  final PackageImageModel? image;
  final int? noOfSlots;
  final bool? isActive;
  final List<PackageSlotModel>? slots;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PackageModel({
    this.index,
    this.id,
    this.name,
    this.description,
    this.week,
    this.totalPrice,
    this.dietaryPreference,
    this.image,
    this.noOfSlots,
    this.isActive,
    this.slots,
    this.createdAt,
    this.updatedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) =>
      _$PackageModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageModelToJson(this);

  Package toEntity() {
    return Package(
      index: index ?? 0,
      id: id ?? '',
      name: name ?? '',
      description: description ?? '',
      week: week ?? 0,
      totalPrice: totalPrice ?? 0.0,
      dietaryPreference: dietaryPreference ?? '',
      image: image?.toEntity(),
      noOfSlots: noOfSlots ?? 0,
      isActive: isActive ?? false,
      slots: slots?.map((slot) => slot.toEntity()).toList() ?? [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory PackageModel.fromEntity(Package entity) {
    return PackageModel(
      index: entity.index,
      id: entity.id,
      name: entity.name,
      description: entity.description,
      week: entity.week,
      totalPrice: entity.totalPrice,
      dietaryPreference: entity.dietaryPreference,
      image:
          entity.image != null
              ? PackageImageModel.fromEntity(entity.image!)
              : null,
      noOfSlots: entity.noOfSlots,
      isActive: entity.isActive,
      slots:
          entity.slots
              .map((slot) => PackageSlotModel.fromEntity(slot))
              .toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
