// lib/src/presentation/cubits/week_selection/week_selection_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/entities/meal_plan_item.dart';
import 'package:foodam/src/domain/entities/price_option.dart';

abstract class WeekSelectionState extends Equatable {
  const WeekSelectionState();

  @override
  List<Object?> get props => [];
}

/// Initial state when week selection starts
class WeekSelectionInitial extends WeekSelectionState {
  const WeekSelectionInitial();
}

/// Main active state - handles all week selection logic
/// UI will handle null/empty data cases with empty screens
class WeekSelectionActive extends WeekSelectionState {
  final PlanningFormData planningData;
  final int currentWeek;
  final int maxWeeksConfigured;
  final Map<int, WeekConfig> weekConfigs;
  final Map<int, WeekData?> weekDataCache; // Nullable - UI handles null case
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
    selections.length,
    _generateSelectionsHash(),
  ];

  /// Generate hash to detect selection changes without Map comparison
  int _generateSelectionsHash() {
    return selections.entries
        .map((e) => '${e.key}:${e.value.dishId}'.hashCode)
        .fold(0, (prev, hash) => prev ^ hash);
  }

  // ===============================================================
  // VALIDATION METHODS (computed on-demand, no separate map)
  // ===============================================================

  /// Check if current week is configured
  bool get isCurrentWeekConfigured => weekConfigs.containsKey(currentWeek);

  /// Check if current week data is available (not null)
  bool get isCurrentWeekDataAvailable => weekDataCache[currentWeek] != null;

  /// Get current week configuration
  WeekConfig? get currentWeekConfig => weekConfigs[currentWeek];

  /// Get current week data (nullable - UI handles null case)
  WeekData? get currentWeekData => weekDataCache[currentWeek];

  /// Compute validation on-demand for current week
  WeekValidationResult validateCurrentWeek() {
    final config = weekConfigs[currentWeek];
    if (config == null) {
      return WeekValidationResult(
        isValid: false,
        requiredMeals: 0,
        selectedMeals: 0,
        missingMeals: 0,
        message: 'Week not configured',
      );
    }

    final weekSelections = getSelectionsForWeek(currentWeek);
    final selectedCount = weekSelections.length;
    final requiredCount = config.mealPlan;
    final missing = requiredCount - selectedCount;

    return WeekValidationResult(
      isValid: selectedCount == requiredCount,
      requiredMeals: requiredCount,
      selectedMeals: selectedCount,
      missingMeals: missing,
      message:
          missing > 0
              ? 'Select $missing more meals'
              : selectedCount > requiredCount
              ? 'Too many meals selected'
              : 'Week complete',
    );
  }

  /// Get selections for specific week
  List<DishSelection> getSelectionsForWeek(int week) {
    return selections.values
        .where((selection) => selection.week == week)
        .toList();
  }

  /// Check if specific dish is selected
  bool isDishSelected(int week, String dishId, String day, String timing) {
    final key = DishSelection.generateKey(week, dishId, day, timing);
    return selections.containsKey(key);
  }

  /// Navigation helpers
  bool get canGoToNextWeek => currentWeek < 4; // Max 4 weeks
  bool get canGoToPreviousWeek => currentWeek > 1;
  bool get canAddNextWeek =>
      maxWeeksConfigured < 4 && validateCurrentWeek().isValid;

  /// Create copy with new data - avoiding complex state transitions
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
}

// ===============================================================
// SUPPORTING DATA CLASSES
// ===============================================================

/// Planning form data from StartPlanningScreen
class PlanningFormData extends Equatable {
  final DateTime startDate;
  final String
  dietaryPreference; // Default preference, can be overridden per week

  const PlanningFormData({
    required this.startDate,
    required this.dietaryPreference,
  });

  @override
  List<Object> get props => [startDate, dietaryPreference];
}

/// Configuration for each week - can have different settings
class WeekConfig extends Equatable {
  final int week;
  final String dietaryPreference; // Can differ from default
  final int mealPlan; // 10, 15, 18, 21
  final bool isComplete;

  const WeekConfig({
    required this.week,
    required this.dietaryPreference,
    required this.mealPlan,
    required this.isComplete,
  });

  @override
  List<Object> get props => [week, dietaryPreference, mealPlan, isComplete];

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
}

/// Week data from API - simplified without loading/error states
class WeekData extends Equatable {
  final CalculatedPlan? calculatedPlan;
  final List<MealPlanItem>? availableMeals;
  final String? packageId;
  final List<PriceOption>? priceOptions;
  final DateTime? loadedAt;

  const WeekData({
    this.calculatedPlan,
    this.availableMeals,
    this.packageId,
    this.priceOptions,
    this.loadedAt,
  });

  /// Factory for successfully loaded data
  factory WeekData.loaded({
    required CalculatedPlan calculatedPlan,
    required List<MealPlanItem> availableMeals,
    required String packageId,
    required List<PriceOption> priceOptions,
  }) {
    return WeekData(
      calculatedPlan: calculatedPlan,
      availableMeals: availableMeals,
      packageId: packageId,
      priceOptions: priceOptions,
      loadedAt: DateTime.now(),
    );
  }

  /// Check if data is valid and complete
  bool get isValid =>
      calculatedPlan != null &&
      availableMeals != null &&
      packageId != null &&
      availableMeals!.isNotEmpty;

  @override
  List<Object?> get props => [
    calculatedPlan,
    availableMeals,
    packageId,
    priceOptions,
    loadedAt,
  ];
}

/// Fixed selection key structure - prevents week replication issue
class DishSelection extends Equatable {
  final String key; // week_dishId_day_timing
  final int week;
  final String dishId; // From API response
  final String dishName;
  final String day;
  final String timing;
  final DateTime date; // From API for subscription creation
  final String packageId; // For subscription creation

  const DishSelection({
    required this.key,
    required this.week,
    required this.dishId,
    required this.dishName,
    required this.day,
    required this.timing,
    required this.date,
    required this.packageId,
  });

  /// Generate unique key - fixes week replication issue
  static String generateKey(
    int week,
    String dishId,
    String day,
    String timing,
  ) {
    return '${week}_${dishId}_${day}_$timing';
  }

  /// Factory from MealPlanItem
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
      dishId: item.dishId,
      dishName: item.dishName,
      day: item.day,
      timing: item.timing,
      date: date,
      packageId: packageId,
    );
  }

  @override
  List<Object> get props => [
    key,
    week,
    dishId,
    dishName,
    day,
    timing,
    date,
    packageId,
  ];

  /// Convert to API format for subscription creation
  Map<String, dynamic> toSubscriptionSlot() {
    return {
      'day': day.toLowerCase(),
      'date': date.toIso8601String(),
      'timing': timing.toLowerCase(),
      'meal': dishId, // API expects dishId in 'meal' field
    };
  }

  /// Copy with new values
  DishSelection copyWith({
    String? key,
    int? week,
    String? dishId,
    String? dishName,
    String? day,
    String? timing,
    DateTime? date,
    String? packageId,
  }) {
    return DishSelection(
      key: key ?? this.key,
      week: week ?? this.week,
      dishId: dishId ?? this.dishId,
      dishName: dishName ?? this.dishName,
      day: day ?? this.day,
      timing: timing ?? this.timing,
      date: date ?? this.date,
      packageId: packageId ?? this.packageId,
    );
  }
}

/// Validation result computed on-demand
class WeekValidationResult extends Equatable {
  final bool isValid;
  final int requiredMeals;
  final int selectedMeals;
  final int missingMeals;
  final String message;

  const WeekValidationResult({
    required this.isValid,
    required this.requiredMeals,
    required this.selectedMeals,
    required this.missingMeals,
    required this.message,
  });

  @override
  List<Object> get props => [
    isValid,
    requiredMeals,
    selectedMeals,
    missingMeals,
    message,
  ];
}
