// lib/src/data/model/package_model.dart
import 'package:foodam/src/data/model/meal_slot_model.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';

class PackageModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<MealSlotModel> slots;
  // final bool 

  PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.slots,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id']??"unknown",
      // Handle null or empty name
      name: json['name'],
      description: json['description'],
      price: (json['price'] is int) 
          ? (json['price'] as int).toDouble() 
          : (json['price'] as num).toDouble(),
      slots: json['slots'] != null
          ? (json['slots'] as List)
              .map((slot) => MealSlotModel.fromJson(slot))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'slots': slots.map((slot) => slot.toJson()).toList(),
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
    );
  }

  // Mapper to convert entity to model
  factory PackageModel.fromEntity(Package entity) {
    return PackageModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      slots: entity.slots
          .map((slot) => MealSlotModel.fromEntity(slot))
          .toList(),
    );
  }
}