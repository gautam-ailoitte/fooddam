// lib/src/domain/entities/meal_slot_entity.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

class MealSlot extends Equatable {
  final String day;
  final String timing;
  final String? mealId;
  final Meal? meal;
  final DateTime? date;

  const MealSlot({
    required this.day,
    required this.timing,
    this.mealId,
    this.meal,
    this.date,
  });

  @override
  List<Object?> get props => [day, timing, mealId, meal, date];

  // Helper to get a nice display format for the day and timing
  String get displayText => '$day $timing';

  // Helper to check if this is a breakfast slot
  bool get isBreakfast => timing.toLowerCase() == 'breakfast';

  // Helper to check if this is a lunch slot
  bool get isLunch => timing.toLowerCase() == 'lunch';

  // Helper to check if this is a dinner slot
  bool get isDinner => timing.toLowerCase() == 'dinner';

  // Helper to check if this slot has a meal assigned
  bool get hasMeal => mealId != null || meal != null;

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

  String? get formattedDate {
    if (date == null) return null;

    // Format as Month Day, Year
    final month = _getMonthName(date!.month);
    return '$month ${date!.day}, ${date!.year}';
  }

  // Helper to check if this is today's meal
  bool get isToday {
    if (date == null) return false;

    final now = DateTime.now();
    return date!.year == now.year &&
        date!.month == now.month &&
        date!.day == now.day;
  }

  // Helper to get month name
  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // Factory method to create from the old MealDistribution format
  factory MealSlot.fromMealDistribution(MealDistribution distribution) {
    return MealSlot(
      day: distribution.day,
      timing: distribution.mealTime,
      mealId: distribution.mealId,
    );
  }

  // Factory method to create from a map
  factory MealSlot.fromMap(Map<String, dynamic> map) {
    return MealSlot(
      day: map['day'] as String,
      timing: map['timing'] as String,
      mealId: map['meal'] as String?,
    );
  }

  // Convert to a map
  Map<String, dynamic> toMap() {
    return {'day': day, 'timing': timing, 'meal': mealId};
  }

  // Helper to create a copy of this slot with a meal object attached
  MealSlot copyWithMeal(Meal mealData) {
    return MealSlot(
      day: day,
      timing: timing,
      mealId: mealId ?? mealData.id,
      meal: mealData,
    );
  }

  // Helper to create a copy with updated properties
  MealSlot copyWith({String? day, String? timing, String? mealId, Meal? meal}) {
    return MealSlot(
      day: day ?? this.day,
      timing: timing ?? this.timing,
      mealId: mealId ?? this.mealId,
      meal: meal ?? this.meal,
    );
  }
}

// This represents the legacy class for reference during migration
// After migration is complete, this class should be removed
@Deprecated('Use MealSlot instead - this will be removed in a future version')
class MealDistribution extends Equatable {
  final String day;
  final String mealTime;
  final String? mealId;

  const MealDistribution({
    required this.day,
    required this.mealTime,
    this.mealId,
  });

  @override
  List<Object?> get props => [day, mealTime, mealId];

  // Helper method to convert to the new MealSlot format
  MealSlot toMealSlot() {
    return MealSlot(day: day, timing: mealTime, mealId: mealId);
  }
}
