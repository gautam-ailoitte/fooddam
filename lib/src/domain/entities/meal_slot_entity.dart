// lib/src/domain/entities/meal_slot_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

class MealSlot extends Equatable {
  final String day;
  final String timing;
  final String? mealId;
  final Meal? meal;

  const MealSlot({
    required this.day,
    required this.timing,
    this.mealId,
    this.meal,
  });

  @override
  List<Object?> get props => [day, timing, mealId, meal];
  
  // Helper to get a nice display format for the day and timing
  String get displayText => '$day $timing';
  
  // Helper to check if this is a breakfast slot
  bool get isBreakfast => timing.toLowerCase() == 'breakfast';
  
  // Helper to check if this is a lunch slot
  bool get isLunch => timing.toLowerCase() == 'lunch';
  
  // Helper to check if this is a dinner slot
  bool get isDinner => timing.toLowerCase() == 'dinner';
  
  // Helper to check if this slot has a meal assigned
  bool get hasMeal => mealId != null;
  
  // Helper to check if this slot falls on a weekday
  bool get isWeekday {
    final weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    return weekdays.contains(day.toLowerCase());
  }
  
  // Helper to check if this slot falls on a weekend
  bool get isWeekend {
    final weekend = ['saturday', 'sunday'];
    return weekend.contains(day.toLowerCase());
  }
  
  // Helper to create a copy of this slot with a meal object attached
  MealSlot copyWithMeal(Meal mealData) {
    return MealSlot(
      day: day,
      timing: timing,
      mealId: mealId,
      meal: mealData,
    );
  }
}