// lib/src/domain/entities/pacakge_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';

class Package extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<MealSlot> slots;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Package({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.slots,
    this.isActive = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    slots,
    isActive,
    createdAt,
    updatedAt,
  ];
}
