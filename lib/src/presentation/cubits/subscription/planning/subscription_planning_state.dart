// lib/src/presentation/cubits/subscription/planning/subscription_planning_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';

abstract class SubscriptionPlanningState extends Equatable {
  const SubscriptionPlanningState();

  @override
  List<Object?> get props => [];
}

class SubscriptionPlanningInitial extends SubscriptionPlanningState {}

class SubscriptionPlanningLoading extends SubscriptionPlanningState {}

class SubscriptionPlanningError extends SubscriptionPlanningState {
  final String message;

  const SubscriptionPlanningError(this.message);

  @override
  List<Object?> get props => [message];
}

// Form planning state
class PlanningFormActive extends SubscriptionPlanningState {
  final DateTime? startDate;
  final String? dietaryPreference;
  final int? duration; // in weeks
  final int? mealPlan; // meals per week

  const PlanningFormActive({
    this.startDate,
    this.dietaryPreference,
    this.duration,
    this.mealPlan,
  });

  @override
  List<Object?> get props => [startDate, dietaryPreference, duration, mealPlan];

  bool get isFormValid =>
      startDate != null &&
      dietaryPreference != null &&
      duration != null &&
      mealPlan != null;

  PlanningFormActive copyWith({
    DateTime? startDate,
    String? dietaryPreference,
    int? duration,
    int? mealPlan,
  }) {
    return PlanningFormActive(
      startDate: startDate ?? this.startDate,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      duration: duration ?? this.duration,
      mealPlan: mealPlan ?? this.mealPlan,
    );
  }
}

// Week-by-week selection state
class WeekSelectionActive extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final int currentWeek;
  final Map<int, WeekPlanData> weeksData;
  final Map<int, Map<DateTime, Map<String, bool>>> mealSelections;

  const WeekSelectionActive({
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
    required this.currentWeek,
    required this.weeksData,
    required this.mealSelections,
  });

  @override
  List<Object?> get props => [
    startDate,
    dietaryPreference,
    duration,
    mealPlan,
    currentWeek,
    weeksData,
    mealSelections,
  ];

  // Get selected meal count for a specific week
  int getSelectedMealCount(int week) {
    final weekSelections = mealSelections[week] ?? {};
    int count = 0;
    for (final daySelections in weekSelections.values) {
      count += daySelections.values.where((selected) => selected).length;
    }
    return count;
  }

  // Check if a specific week is valid (has exact meal count)
  bool isWeekValid(int week) {
    return getSelectedMealCount(week) == mealPlan;
  }

  // Check if all weeks are valid
  bool get allWeeksValid {
    for (int week = 1; week <= duration; week++) {
      if (!isWeekValid(week)) return false;
    }
    return true;
  }

  // Check if current week is loaded
  bool get isCurrentWeekLoaded => weeksData.containsKey(currentWeek);

  // Get calculated plan for current week
  CalculatedPlan? get currentWeekPlan => weeksData[currentWeek]?.calculatedPlan;

  WeekSelectionActive copyWith({
    DateTime? startDate,
    String? dietaryPreference,
    int? duration,
    int? mealPlan,
    int? currentWeek,
    Map<int, WeekPlanData>? weeksData,
    Map<int, Map<DateTime, Map<String, bool>>>? mealSelections,
  }) {
    return WeekSelectionActive(
      startDate: startDate ?? this.startDate,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      duration: duration ?? this.duration,
      mealPlan: mealPlan ?? this.mealPlan,
      currentWeek: currentWeek ?? this.currentWeek,
      weeksData: weeksData ?? this.weeksData,
      mealSelections: mealSelections ?? this.mealSelections,
    );
  }
}

// Planning complete state
class PlanningComplete extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final Map<int, WeekPlanData> weeksData;
  final Map<int, Map<DateTime, Map<String, bool>>> mealSelections;

  const PlanningComplete({
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
    required this.weeksData,
    required this.mealSelections,
  });

  @override
  List<Object?> get props => [
    startDate,
    dietaryPreference,
    duration,
    mealPlan,
    weeksData,
    mealSelections,
  ];

  // Generate subscription request data
  List<WeekSubscriptionRequest> generateSubscriptionWeeks() {
    final List<WeekSubscriptionRequest> weeks = [];

    for (int week = 1; week <= duration; week++) {
      final weekData = weeksData[week];
      final weekSelections = mealSelections[week] ?? {};

      if (weekData == null) continue;

      final List<MealSlotRequest> slots = [];

      for (final dateEntry in weekSelections.entries) {
        final date = dateEntry.key;
        final mealSelections = dateEntry.value;

        for (final mealEntry in mealSelections.entries) {
          final mealType = mealEntry.key;
          final isSelected = mealEntry.value;

          if (isSelected) {
            // Find the meal for this date and meal type
            final dailyMeal =
                weekData.calculatedPlan.dailyMeals
                    .where((dm) => _isSameDate(dm.date, date))
                    .firstOrNull;

            if (dailyMeal?.slot.meal != null) {
              final dish = dailyMeal!.slot.meal!.dishes[mealType];
              if (dish != null) {
                slots.add(
                  MealSlotRequest(
                    day: _getDayName(date.weekday),
                    date: date,
                    timing: mealType,
                    mealId: dish.id,
                  ),
                );
              }
            }
          }
        }
      }

      weeks.add(
        WeekSubscriptionRequest(
          packageId: weekData.calculatedPlan.package?.id ?? '',
          slots: slots,
        ),
      );
    }

    return weeks;
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[weekday - 1];
  }
}

// Helper class to hold week plan data
class WeekPlanData extends Equatable {
  final CalculatedPlan calculatedPlan;
  final DateTime weekStartDate;
  final DateTime weekEndDate;

  const WeekPlanData({
    required this.calculatedPlan,
    required this.weekStartDate,
    required this.weekEndDate,
  });

  @override
  List<Object?> get props => [calculatedPlan, weekStartDate, weekEndDate];
}
