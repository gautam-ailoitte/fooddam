// lib/src/domain/entities/package_slot_entity.dart
import 'package:equatable/equatable.dart';

import '../meal/meal_entity.dart';

class PackageSlot extends Equatable {
  final String day;
  final Meal? meal;

  const PackageSlot({required this.day, this.meal});

  @override
  List<Object?> get props => [day, meal];

  bool get hasMeal => meal != null;
  bool get isAvailable => meal?.isAvailable ?? false;

  // Convenience getters
  String get dayCapitalized =>
      day.isNotEmpty
          ? day[0].toUpperCase() + day.substring(1).toLowerCase()
          : '';

  String? get mealName => meal?.name;
  double get mealPrice => meal?.price ?? 0.0;
}
