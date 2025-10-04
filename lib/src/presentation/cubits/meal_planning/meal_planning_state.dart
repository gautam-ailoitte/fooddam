// lib/src/presentation/cubits/meal_planning/meal_planning_state.dart

part of 'meal_planning_cubit.dart';

abstract class MealPlanningState extends Equatable {
  const MealPlanningState();

  @override
  List<Object?> get props => [];
}

class MealPlanningInitial extends MealPlanningState {}

class StartPlanningActive extends MealPlanningState {
  final DateTime? selectedStartDate;
  final String? selectedDietaryPreference;
  final int? selectedMealCount;
  final bool isFormValid;

  const StartPlanningActive({
    this.selectedStartDate,
    this.selectedDietaryPreference,
    this.selectedMealCount,
    this.isFormValid = false,
  });

  StartPlanningActive copyWith({
    DateTime? selectedStartDate,
    String? selectedDietaryPreference,
    int? selectedMealCount,
  }) {
    final newStartDate = selectedStartDate ?? this.selectedStartDate;
    final newDietaryPreference =
        selectedDietaryPreference ?? this.selectedDietaryPreference;
    final newMealCount = selectedMealCount ?? this.selectedMealCount;

    return StartPlanningActive(
      selectedStartDate: newStartDate,
      selectedDietaryPreference: newDietaryPreference,
      selectedMealCount: newMealCount,
      isFormValid:
          newStartDate != null &&
          newDietaryPreference != null &&
          newMealCount != null,
    );
  }

  @override
  List<Object?> get props => [
    selectedStartDate,
    selectedDietaryPreference,
    selectedMealCount,
    isFormValid,
  ];
}

class WeekGridLoading extends MealPlanningState {
  final int week;
  final String? message;

  const WeekGridLoading({required this.week, this.message});

  @override
  List<Object?> get props => [week, message];
}

class WeekGridLoaded extends MealPlanningState {
  final int currentWeek;
  final int totalWeeks;
  final Map<int, WeekSelectionData> weekSelections;
  final WeekValidation currentWeekValidation;
  final double totalPrice;
  final MealPlanningConfig? config;

  const WeekGridLoaded({
    required this.currentWeek,
    required this.totalWeeks,
    required this.weekSelections,
    required this.currentWeekValidation,
    required this.totalPrice,
    this.config,
  });

  // Get current week data
  WeekSelectionData get currentWeekData => weekSelections[currentWeek]!;

  // Check if all weeks are complete
  bool get allWeeksComplete {
    return weekSelections.values.every((week) => week.validation.isValid);
  }

  // Get overall completion percentage
  double get overallProgress {
    if (weekSelections.isEmpty) return 0.0;

    final totalRequired = weekSelections.values.fold(
      0,
      (sum, week) => sum + week.targetMealCount,
    );
    final totalSelected = weekSelections.values.fold(
      0,
      (sum, week) => sum + week.validation.selectedCount,
    );

    return totalRequired > 0 ? totalSelected / totalRequired : 0.0;
  }

  @override
  List<Object?> get props => [
    currentWeek,
    totalWeeks,
    weekSelections,
    currentWeekValidation,
    totalPrice,
    config,
  ];
}

class SubscriptionCreating extends MealPlanningState {
  final String? message;

  const SubscriptionCreating([this.message]);

  @override
  List<Object?> get props => [message];
}

class SubscriptionSuccess extends MealPlanningState {
  final String subscriptionId;
  final String? message;
  final double? totalAmount;

  const SubscriptionSuccess({
    required this.subscriptionId,
    this.message,
    this.totalAmount,
  });

  @override
  List<Object?> get props => [subscriptionId, message, totalAmount];
}

class MealPlanningError extends MealPlanningState {
  final String message;

  const MealPlanningError(this.message);

  @override
  List<Object?> get props => [message];
}
