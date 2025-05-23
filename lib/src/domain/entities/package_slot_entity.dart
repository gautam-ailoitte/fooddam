// lib/src/domain/entities/package_slot_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/day_meal.dart';

class PackageSlot extends Equatable {
  final String day;
  final DayMeal? meal;

  const PackageSlot({required this.day, this.meal});

  @override
  List<Object?> get props => [day, meal];

  // Helper methods
  String get formattedDay {
    if (day.isEmpty) return '';
    return day.substring(0, 1).toUpperCase() + day.substring(1).toLowerCase();
  }

  bool get hasMeal => meal != null;

  bool get isWeekend {
    final weekend = ['saturday', 'sunday'];
    return weekend.contains(day.toLowerCase());
  }

  bool get isWeekday => !isWeekend;
}
