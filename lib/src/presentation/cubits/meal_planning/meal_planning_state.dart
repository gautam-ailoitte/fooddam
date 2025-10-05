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
  final int? selectedWeekCount;
  final int? selectedMealCount;
  final bool isFormValid;

  const StartPlanningActive({
    this.selectedStartDate,
    this.selectedDietaryPreference,
    this.selectedMealCount,
    this.selectedWeekCount,
    this.isFormValid = false,
  });

  StartPlanningActive copyWith({
    DateTime? selectedStartDate,
    String? selectedDietaryPreference,
    int? selectedMealCount,
    int? selectedWeekCount,
  }) {
    final newStartDate = selectedStartDate ?? this.selectedStartDate;
    final newDietaryPreference =
        selectedDietaryPreference ?? this.selectedDietaryPreference;
    final newMealCount = selectedMealCount ?? this.selectedMealCount;
    final newWeekCount = selectedWeekCount ?? this.selectedWeekCount;

    return StartPlanningActive(
      selectedStartDate: newStartDate,
      selectedDietaryPreference: newDietaryPreference,
      selectedMealCount: newMealCount,
      selectedWeekCount: newWeekCount,
      isFormValid:
          newStartDate != null &&
          newDietaryPreference != null &&
          newMealCount != null &&
          newWeekCount != null &&
          newWeekCount >= 1 &&
          newWeekCount <= 4,
    );
  }

  @override
  List<Object?> get props => [
    selectedStartDate,
    selectedDietaryPreference,
    selectedMealCount,
    selectedWeekCount,
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

// lib/src/presentation/cubits/meal_planning/meal_planning_state.dart

class WeekGridLoaded extends MealPlanningState {
  final int currentWeek;
  final int totalWeeks;
  final Map<int, WeekSelectionData> weekSelections;
  final WeekValidation currentWeekValidation;
  final double totalPrice;
  final MealPlanningConfig config; // NOT nullable
  final Map<int, bool> hasSeenConfigPrompt;

  const WeekGridLoaded({
    required this.currentWeek,
    required this.totalWeeks,
    required this.weekSelections,
    required this.currentWeekValidation,
    required this.totalPrice,
    required this.config, // Required, not optional
    this.hasSeenConfigPrompt = const {},
  });

  WeekSelectionData get currentWeekData => weekSelections[currentWeek]!;

  // Access via config
  DateTime get startDate => config.startDate;
  String get defaultDietaryPreference => config.dietaryPreference;

  bool get allWeeksComplete {
    return weekSelections.values.every((week) => week.validation.isValid);
  }

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

  bool canNavigateToPrevious() => currentWeek > 1;

  bool canNavigateToNext() {
    return currentWeek < totalWeeks && currentWeekValidation.isComplete;
  }

  bool hasSeenPromptForWeek(int week) {
    return hasSeenConfigPrompt[week] ?? false;
  }

  bool isWeekCustomized(int week) {
    final weekData = weekSelections[week];
    if (weekData == null) return false;

    return weekData.dietaryPreference != config.dietaryPreference ||
        weekData.targetMealCount != config.mealCountPerWeek;
  }

  @override
  List<Object?> get props => [
    currentWeek,
    totalWeeks,
    weekSelections,
    currentWeekValidation,
    totalPrice,
    config,
    hasSeenConfigPrompt,
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
