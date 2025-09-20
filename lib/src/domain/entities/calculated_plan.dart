import 'package:equatable/equatable.dart';

import 'package/package_entity.dart';

class CalculatedPlan extends Equatable {
  final String dietaryPreference;
  final String requestedWeek;
  final int actualSystemWeek;
  final DateTime startDate;
  final DateTime endDate;
  final Package? package;
  final List<DailyMeal> dailyMeals;

  const CalculatedPlan({
    required this.dietaryPreference,
    required this.requestedWeek,
    required this.actualSystemWeek,
    required this.startDate,
    required this.endDate,
    this.package,
    required this.dailyMeals,
  });

  @override
  List<Object?> get props => [
    dietaryPreference,
    requestedWeek,
    actualSystemWeek,
    startDate,
    endDate,
    package,
    dailyMeals,
  ];

  // Helper methods
  bool get isVegetarian => dietaryPreference == 'vegetarian';

  int get durationDays => dailyMeals.length;

  DailyMeal? getMealForDate(DateTime date) {
    try {
      return dailyMeals.firstWhere(
        (meal) =>
            meal.date.year == date.year &&
            meal.date.month == date.month &&
            meal.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  List<DailyMeal> getMealsForDay(String day) {
    return dailyMeals
        .where((meal) => meal.slot.day.toLowerCase() == day.toLowerCase())
        .toList();
  }
}

class DailyMeal extends Equatable {
  final DateTime date;
  final DailySlot slot;

  const DailyMeal({required this.date, required this.slot});

  @override
  List<Object?> get props => [date, slot];

  // Helper methods
  String get formattedDate {
    final month = _getMonthName(date.month);
    return '$month ${date.day}, ${date.year}';
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

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
}

class DailySlot extends Equatable {
  final String day;
  final DayMeal? meal;

  const DailySlot({required this.day, required this.meal});

  @override
  List<Object?> get props => [day, meal];

  bool get hasMeal => meal != null;
}
