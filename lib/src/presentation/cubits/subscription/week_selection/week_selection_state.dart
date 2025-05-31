// lib/src/presentation/cubits/subscription/week_selection/week_selection_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/entities/meal_plan_item.dart';
import 'package:foodam/src/domain/entities/price_option.dart';

// ===============================================================
// BASE STATES
// ===============================================================

/// Base class for all week selection states
abstract class WeekSelectionState extends Equatable {
  const WeekSelectionState();

  @override
  List<Object?> get props => [];
}

/// Initial state when week selection is not started
class WeekSelectionInitial extends WeekSelectionState {
  const WeekSelectionInitial();
}

/// Error state when something goes wrong during initialization
class WeekSelectionError extends WeekSelectionState {
  final String message;
  final String? errorCode;

  const WeekSelectionError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

// ===============================================================
// PLANNING FORM DATA (UPDATED - Added mealPlan)
// ===============================================================

/// Data collected from the initial planning form
/// Updated to include meal plan selection for Week 1
class PlanningFormData extends Equatable {
  final DateTime startDate;
  final String dietaryPreference;
  final int mealPlan; // NEW: Meal plan selection for Week 1

  const PlanningFormData({
    required this.startDate,
    required this.dietaryPreference,
    required this.mealPlan, // NEW: Required meal plan
  });

  @override
  List<Object?> get props => [startDate, dietaryPreference, mealPlan];

  /// Create copy with updated values
  PlanningFormData copyWith({
    DateTime? startDate,
    String? dietaryPreference,
    int? mealPlan,
  }) {
    return PlanningFormData(
      startDate: startDate ?? this.startDate,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      mealPlan: mealPlan ?? this.mealPlan,
    );
  }

  /// Helper getters
  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  bool get isVegetarian => dietaryPreference.toLowerCase() == 'vegetarian';
  bool get isNonVegetarian => dietaryPreference.toLowerCase() == 'non-vegetarian';

  /// Validation with enhanced debugging
  bool get isValid {
    // UPDATED: Start date must be in the future (tomorrow onwards)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(startDate.year, startDate.month, startDate.day);
    final dateValid = selectedDate.isAfter(today); // Must be strictly after today

    final dietValid = (dietaryPreference == 'vegetarian' || dietaryPreference == 'non-vegetarian');
    final mealPlanValid = [10, 15, 18, 21].contains(mealPlan);

    // Debug logging for validation
    debugPrint('📋 PlanningFormData validation:');
    debugPrint('  📅 Date valid: $dateValid (${formattedStartDate}) - must be after today');
    debugPrint('  🥗 Diet valid: $dietValid ($dietaryPreference)');
    debugPrint('  🍽️ Meal plan valid: $mealPlanValid ($mealPlan)');
    debugPrint('  ✅ Overall valid: ${dateValid && dietValid && mealPlanValid}');

    return dateValid && dietValid && mealPlanValid;
  }

  /// Summary text for display
  String get summaryText {
    return '$mealPlan ${isVegetarian ? 'vegetarian' : 'non-vegetarian'} meals starting ${formattedStartDate}';
  }

  /// Debug string representation
  @override
  String toString() {
    return 'PlanningFormData(startDate: $startDate, dietaryPreference: $dietaryPreference, mealPlan: $mealPlan)';
  }
}

// ===============================================================
// WEEK CONFIGURATION
// ===============================================================

/// Configuration for a specific week
class WeekConfig extends Equatable {
  final int week;
  final String dietaryPreference;
  final int mealPlan;
  final bool isComplete;

  const WeekConfig({
    required this.week,
    required this.dietaryPreference,
    required this.mealPlan,
    required this.isComplete,
  });

  @override
  List<Object?> get props => [week, dietaryPreference, mealPlan, isComplete];

  /// Create copy with updated values
  WeekConfig copyWith({
    int? week,
    String? dietaryPreference,
    int? mealPlan,
    bool? isComplete,
  }) {
    return WeekConfig(
      week: week ?? this.week,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      mealPlan: mealPlan ?? this.mealPlan,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Helper getters
  bool get isVegetarian => dietaryPreference.toLowerCase() == 'vegetarian';
  bool get isNonVegetarian => dietaryPreference.toLowerCase() == 'non-vegetarian';
  bool get isAllMealsPlan => mealPlan == 21;

  /// Display text for week config
  String get displayText {
    final dietText = isVegetarian ? 'Veg' : 'Non-Veg';
    return 'Week $week: $mealPlan $dietText meals';
  }

  /// Summary for checkout
  String get checkoutSummary {
    return '$mealPlan ${dietaryPreference} meals';
  }
}

// ===============================================================
// WEEK DATA & MEAL SELECTION
// ===============================================================

/// Data loaded for a specific week from API
class WeekData extends Equatable {
  final CalculatedPlan? calculatedPlan;
  final List<MealPlanItem>? availableMeals;
  final String? packageId;
  final List<PriceOption>? priceOptions;

  const WeekData({
    this.calculatedPlan,
    this.availableMeals,
    this.packageId,
    this.priceOptions,
  });

  /// Factory constructor for successfully loaded data
  const WeekData.loaded({
    required CalculatedPlan calculatedPlan,
    required List<MealPlanItem> availableMeals,
    required String packageId,
    required List<PriceOption> priceOptions,
  }) : this(
    calculatedPlan: calculatedPlan,
    availableMeals: availableMeals,
    packageId: packageId,
    priceOptions: priceOptions,
  );

  /// Factory constructor for loading state (null data)
  const WeekData.loading() : this();

  /// Factory constructor for error state
  const WeekData.error() : this();

  @override
  List<Object?> get props => [calculatedPlan, availableMeals, packageId, priceOptions];

  /// Helper getters
  bool get isLoading => calculatedPlan == null && availableMeals == null;
  bool get isError => calculatedPlan == null && availableMeals == null;
  bool get isLoaded => calculatedPlan != null && availableMeals != null;
  bool get isValid => isLoaded && availableMeals!.isNotEmpty;

  /// Get meals by timing
  List<MealPlanItem> getMealsByTiming(String timing) {
    if (!isValid) return [];
    return availableMeals!
        .where((meal) => meal.timing.toLowerCase() == timing.toLowerCase())
        .toList();
  }

  /// Get meals by day
  List<MealPlanItem> getMealsByDay(String day) {
    if (!isValid) return [];
    return availableMeals!
        .where((meal) => meal.day.toLowerCase() == day.toLowerCase())
        .toList();
  }

  /// Get total available meals count
  int get totalMealsCount => availableMeals?.length ?? 0;

  /// Summary for display
  String get summary {
    if (!isValid) return 'No data available';
    return '${totalMealsCount} meals available';
  }
}

/// Represents a user's dish selection for subscription
class DishSelection extends Equatable {
  final String key; // Unique identifier: "week_day_timing_dishId"
  final int week;
  final String day;
  final String timing;
  final String dishId;
  final String dishName;
  final DateTime date;
  final String packageId;

  const DishSelection({
    required this.key,
    required this.week,
    required this.day,
    required this.timing,
    required this.dishId,
    required this.dishName,
    required this.date,
    required this.packageId,
  });

  @override
  List<Object?> get props => [key, week, day, timing, dishId, dishName, date, packageId];

  /// Generate unique key for selection
  static String generateKey(int week, String dishId, String day, String timing) {
    return '${week}_${day.toLowerCase()}_${timing.toLowerCase()}_$dishId';
  }

  /// Factory constructor from MealPlanItem
  factory DishSelection.fromMealPlanItem({
    required int week,
    required MealPlanItem item,
    required DateTime date,
    required String packageId,
  }) {
    final key = generateKey(week, item.dishId, item.day, item.timing);

    return DishSelection(
      key: key,
      week: week,
      day: item.day,
      timing: item.timing,
      dishId: item.dishId,
      dishName: item.dishName,
      date: date,
      packageId: packageId,
    );
  }

  /// Convert to subscription slot format for API
  Map<String, dynamic> toSubscriptionSlot() {
    return {
      'day': day.toLowerCase(),
      'date': date.toUtc().toIso8601String(),
      'timing': timing.toLowerCase(),
      'meal': dishId, // API expects dish ID in meal field
    };
  }

  /// Helper getters
  String get mealType => timing;
  String get displayText => '$dishName ($timing on ${_capitalize(day)})';
  bool get isBreakfast => timing.toLowerCase() == 'breakfast';
  bool get isLunch => timing.toLowerCase() == 'lunch';
  bool get isDinner => timing.toLowerCase() == 'dinner';

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Copy with new values
  DishSelection copyWith({
    String? key,
    int? week,
    String? day,
    String? timing,
    String? dishId,
    String? dishName,
    DateTime? date,
    String? packageId,
  }) {
    return DishSelection(
      key: key ?? this.key,
      week: week ?? this.week,
      day: day ?? this.day,
      timing: timing ?? this.timing,
      dishId: dishId ?? this.dishId,
      dishName: dishName ?? this.dishName,
      date: date ?? this.date,
      packageId: packageId ?? this.packageId,
    );
  }
}

// ===============================================================
// MAIN ACTIVE STATE
// ===============================================================

/// Active week selection state with all data
class WeekSelectionActive extends WeekSelectionState {
  final PlanningFormData planningData;
  final int currentWeek;
  final int maxWeeksConfigured;
  final Map<int, WeekConfig> weekConfigs;
  final Map<int, WeekData?> weekDataCache;
  final Map<String, DishSelection> selections;

  const WeekSelectionActive({
    required this.planningData,
    required this.currentWeek,
    required this.maxWeeksConfigured,
    required this.weekConfigs,
    required this.weekDataCache,
    required this.selections,
  });

  @override
  List<Object?> get props => [
    planningData,
    currentWeek,
    maxWeeksConfigured,
    weekConfigs,
    weekDataCache,
    selections,
  ];

  /// Create copy with updated values
  WeekSelectionActive copyWith({
    PlanningFormData? planningData,
    int? currentWeek,
    int? maxWeeksConfigured,
    Map<int, WeekConfig>? weekConfigs,
    Map<int, WeekData?>? weekDataCache,
    Map<String, DishSelection>? selections,
  }) {
    return WeekSelectionActive(
      planningData: planningData ?? this.planningData,
      currentWeek: currentWeek ?? this.currentWeek,
      maxWeeksConfigured: maxWeeksConfigured ?? this.maxWeeksConfigured,
      weekConfigs: weekConfigs ?? this.weekConfigs,
      weekDataCache: weekDataCache ?? this.weekDataCache,
      selections: selections ?? this.selections,
    );
  }

  // ===============================================================
  // WEEK NAVIGATION HELPERS
  // ===============================================================

  /// Check if can navigate to next week
  bool get canGoToNextWeek => currentWeek < maxWeeksConfigured;

  /// Check if can navigate to previous week
  bool get canGoToPreviousWeek => currentWeek > 1;

  /// Check if current week is configured
  bool get isCurrentWeekConfigured => weekConfigs.containsKey(currentWeek);

  /// Get current week configuration
  WeekConfig? get currentWeekConfig => weekConfigs[currentWeek];

  /// Get current week data
  WeekData? get currentWeekData => weekDataCache[currentWeek];

  // ===============================================================
  // SELECTION HELPERS
  // ===============================================================

  /// Get selections for specific week
  List<DishSelection> getSelectionsForWeek(int week) {
    return selections.values.where((selection) => selection.week == week).toList();
  }

  /// Check if specific dish is selected
  bool isDishSelected(int week, String dishId, String day, String timing) {
    final key = DishSelection.generateKey(week, dishId, day, timing);
    return selections.containsKey(key);
  }

  /// Get total selections count
  int get totalSelections => selections.length;

  /// Get selections grouped by week
  Map<int, List<DishSelection>> get selectionsByWeek {
    final grouped = <int, List<DishSelection>>{};
    for (final selection in selections.values) {
      grouped.putIfAbsent(selection.week, () => []).add(selection);
    }
    return grouped;
  }

  // ===============================================================
  // VALIDATION HELPERS
  // ===============================================================

  /// Validate current week selection
  WeekValidationResult validateCurrentWeek() {
    final weekConfig = currentWeekConfig;
    if (weekConfig == null) {
      return WeekValidationResult(
        isValid: false,
        message: 'Week ${currentWeek} is not configured',
        selectedMeals: 0,
        requiredMeals: 0,
        missingMeals: 0,
      );
    }

    final weekSelections = getSelectionsForWeek(currentWeek);
    final selectedCount = weekSelections.length;
    final requiredCount = weekConfig.mealPlan;
    final missingCount = requiredCount - selectedCount;

    return WeekValidationResult(
      isValid: selectedCount == requiredCount,
      message: missingCount > 0
          ? 'Select $missingCount more meals for Week $currentWeek'
          : 'Week $currentWeek is complete',
      selectedMeals: selectedCount,
      requiredMeals: requiredCount,
      missingMeals: missingCount,
    );
  }

  /// Check if all configured weeks are complete
  bool get areAllWeeksComplete {
    return weekConfigs.values.every((config) => config.isComplete);
  }

  /// Get completion percentage for current week
  double get currentWeekCompletionPercentage {
    final validation = validateCurrentWeek();
    if (validation.requiredMeals == 0) return 0.0;
    return validation.selectedMeals / validation.requiredMeals;
  }

  // ===============================================================
  // DISPLAY HELPERS
  // ===============================================================

  /// Get summary for checkout
  String get checkoutSummary {
    final totalMeals = selections.length;
    final totalWeeks = weekConfigs.length;
    return '$totalMeals meals across $totalWeeks weeks';
  }

  /// Get week progress text
  String get weekProgressText {
    final completed = weekConfigs.values.where((config) => config.isComplete).length;
    return '$completed of $maxWeeksConfigured weeks completed';
  }

  /// Get current week display text
  String get currentWeekDisplayText {
    final config = currentWeekConfig;
    if (config == null) return 'Week $currentWeek (Not Configured)';

    final validation = validateCurrentWeek();
    return 'Week $currentWeek (${validation.selectedMeals}/${validation.requiredMeals} meals)';
  }
}

// ===============================================================
// VALIDATION RESULT
// ===============================================================

/// Result of week validation
class WeekValidationResult extends Equatable {
  final bool isValid;
  final String message;
  final int selectedMeals;
  final int requiredMeals;
  final int missingMeals;

  const WeekValidationResult({
    required this.isValid,
    required this.message,
    required this.selectedMeals,
    required this.requiredMeals,
    required this.missingMeals,
  });

  @override
  List<Object?> get props => [isValid, message, selectedMeals, requiredMeals, missingMeals];

  /// Get completion percentage
  double get completionPercentage {
    if (requiredMeals == 0) return 0.0;
    return selectedMeals / requiredMeals;
  }

  /// Check if week is complete
  bool get isComplete => selectedMeals == requiredMeals;

  /// Check if week is over-selected (shouldn't happen)
  bool get isOverSelected => selectedMeals > requiredMeals;

  /// Get status color name for UI
  String get statusColorName {
    if (isComplete) return 'success';
    if (selectedMeals > 0) return 'warning';
    return 'grey';
  }
}