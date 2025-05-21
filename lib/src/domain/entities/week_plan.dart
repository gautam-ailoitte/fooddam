import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';

import 'pacakge_entity.dart';

class WeekPlan extends Equatable {
  final Package? package;
  final int week;
  final List<MealSlot> slots;

  const WeekPlan({this.package, required this.week, required this.slots});

  @override
  List<Object?> get props => [package, week, slots];

  // Helper methods
  bool get hasMeals => slots.isNotEmpty;

  int get totalMeals => slots.length;

  List<MealSlot> getSlotsByDay(String day) {
    return slots
        .where((slot) => slot.day.toLowerCase() == day.toLowerCase())
        .toList();
  }

  List<MealSlot> getSlotsByDate(DateTime date) {
    return slots
        .where(
          (slot) =>
              slot.date?.year == date.year &&
              slot.date?.month == date.month &&
              slot.date?.day == date.day,
        )
        .toList();
  }
}
