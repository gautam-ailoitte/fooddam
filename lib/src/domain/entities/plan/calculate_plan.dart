import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/package/package_entity.dart';

import '../../../domain/entities/meal/day_meal_entity.dart';

class CalculatedPlan extends Equatable {
  final String? dietaryPreference;
  final String? requestedWeek;
  final int? actualSystemWeek;
  final DateTime? startDate;
  final DateTime? endDate;
  final Package? package;
  final List<DailyMeal>? dailyMeals;

  const CalculatedPlan({
    this.dietaryPreference,
    this.requestedWeek,
    this.actualSystemWeek,
    this.startDate,
    this.endDate,
    this.package,
    this.dailyMeals,
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

  bool get isVegetarian => dietaryPreference?.toLowerCase() == 'vegetarian';
  int get durationDays => dailyMeals?.length ?? 0;

  DailyMeal? getMealForDate(DateTime date) {
    return dailyMeals?.firstWhere(
      (meal) =>
          meal.date?.year == date.year &&
          meal.date?.month == date.month &&
          meal.date?.day == date.day,
      orElse: () => const DailyMeal(),
    );
  }
}

class DailyMeal extends Equatable {
  final DateTime? date;
  final String? day;
  final DayMeal? meal;

  const DailyMeal({this.date, this.day, this.meal});

  @override
  List<Object?> get props => [date, day, meal];

  String get formattedDate {
    if (date == null) return '';
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
    return '${months[date!.month - 1]} ${date!.day}, ${date!.year}';
  }

  bool get isToday {
    if (date == null) return false;
    final now = DateTime.now();
    return date!.year == now.year &&
        date!.month == now.month &&
        date!.day == now.day;
  }

  String get displayDay => day?.toLowerCase().capitalize() ?? '';
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
