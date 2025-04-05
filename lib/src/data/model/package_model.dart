// lib/src/data/model/package_model.dart
import 'package:foodam/src/data/model/meal_slot_model.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

class PackageModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<MealSlotModel> slots;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.slots,
    this.isActive = false,
    this.createdAt,
    this.updatedAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    List<MealSlotModel> parsedSlots = [];

    // Parse slots if they exist
    if (json['slots'] != null && json['slots'] is List) {
      parsedSlots =
          (json['slots'] as List)
              .map((slot) => MealSlotModel.fromJson(slot))
              .toList();
    }

    return PackageModel(
      id: json['id'] ?? "unknown",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      price:
          (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : (json['price'] as num? ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
      slots: parsedSlots,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'isActive': isActive,
      'slots': slots.map((slot) => slot.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Mapper to convert model to entity
  Package toEntity() {
    return Package(
      id: id,
      name: name,
      description: description,
      price: price,
      slots: slots.map((slot) => slot.toEntity()).toList(),
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Mapper to convert entity to model
  factory PackageModel.fromEntity(Package entity) {
    return PackageModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      slots:
          entity.slots.map((slot) => MealSlotModel.fromEntity(slot)).toList(),
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
