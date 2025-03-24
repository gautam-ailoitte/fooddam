// lib/src/domain/entities/package_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';

class Package extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<MealSlot> slots;

  const Package({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.slots,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        slots,
      ];
}