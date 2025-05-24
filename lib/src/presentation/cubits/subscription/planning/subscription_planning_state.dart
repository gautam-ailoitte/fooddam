// lib/src/presentation/cubits/subscription/planning/subscription_planning_state.dart (ENHANCED)
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/services/subscription_service.dart';
import 'package:foodam/src/domain/services/week_data_service.dart';

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

// Enhanced form planning state
class PlanningFormActive extends SubscriptionPlanningState {
  final DateTime? startDate;
  final String? dietaryPreference;
  final int? duration;
  final int? mealPlan;

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
      mealPlan != null &&
      startDate!.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
      duration! > 0 &&
      mealPlan! > 0;

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

  /// Get form completion percentage
  double get completionPercentage {
    int completedFields = 0;
    if (startDate != null) completedFields++;
    if (dietaryPreference != null) completedFields++;
    if (duration != null) completedFields++;
    if (mealPlan != null) completedFields++;
    return completedFields / 4.0;
  }

  /// Get missing field names
  List<String> get missingFields {
    final List<String> missing = [];
    if (startDate == null) missing.add('Start Date');
    if (dietaryPreference == null) missing.add('Dietary Preference');
    if (duration == null) missing.add('Duration');
    if (mealPlan == null) missing.add('Meal Plan');
    return missing;
  }
}

// Enhanced week-by-week selection state
class WeekSelectionActive extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final int currentWeek;
  final Map<int, WeekCache> weekCache;
  final List<MealSelection> selections;

  const WeekSelectionActive({
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
    required this.currentWeek,
    required this.weekCache,
    required this.selections,
  });

  @override
  List<Object?> get props => [
    startDate,
    dietaryPreference,
    duration,
    mealPlan,
    currentWeek,
    weekCache,
    selections,
  ];

  // Enhanced selection queries
  int getSelectedMealCount(int week) {
    return selections.where((s) => s.week == week).length;
  }

  bool isWeekValid(int week) {
    return getSelectedMealCount(week) == mealPlan;
  }

  bool canSelectMore(int week) {
    return getSelectedMealCount(week) < mealPlan;
  }

  bool get allWeeksValid {
    for (int week = 1; week <= duration; week++) {
      if (!isWeekValid(week)) return false;
    }
    return true;
  }

  // Current week state queries
  bool isCurrentWeekLoaded() {
    final cache = weekCache[currentWeek];
    return cache != null && cache.isLoaded;
  }

  bool isCurrentWeekLoading() {
    final cache = weekCache[currentWeek];
    return cache != null && cache.isLoading;
  }

  bool currentWeekHasError() {
    final cache = weekCache[currentWeek];
    return cache != null && cache.hasError;
  }

  String? getCurrentWeekError() {
    final cache = weekCache[currentWeek];
    return cache?.errorMessage;
  }

  WeekCache? getCurrentWeekCache() {
    return weekCache[currentWeek];
  }

  // Enhanced selection queries
  bool isMealSelected(String mealOptionId, int week) {
    return selections.any((s) => s.week == week && s.id.contains(mealOptionId));
  }

  List<MealSelection> getSelectionsForWeek(int week) {
    return selections.where((s) => s.week == week).toList();
  }

  List<MealSelection> getSelectionsForMealType(String mealType) {
    return selections
        .where((s) => s.mealType.toLowerCase() == mealType.toLowerCase())
        .toList();
  }

  Map<String, int> getMealTypeDistribution() {
    final Map<String, int> distribution = {
      'breakfast': 0,
      'lunch': 0,
      'dinner': 0,
    };

    for (final selection in selections) {
      final key = selection.mealType.toLowerCase();
      distribution[key] = (distribution[key] ?? 0) + 1;
    }

    return distribution;
  }

  // Week progress queries
  Map<int, double> getWeekProgress() {
    final Map<int, double> progress = {};
    for (int week = 1; week <= duration; week++) {
      final selected = getSelectedMealCount(week);
      progress[week] = mealPlan > 0 ? selected / mealPlan : 0.0;
    }
    return progress;
  }

  double get overallProgress {
    final totalRequired = duration * mealPlan;
    return totalRequired > 0 ? selections.length / totalRequired : 0.0;
  }

  int get totalSelectedMeals => selections.length;
  int get totalRequiredMeals => duration * mealPlan;
  int get remainingMeals => totalRequiredMeals - totalSelectedMeals;

  // Week package management
  Map<int, String> getWeekPackageIds() {
    final Map<int, String> packageIds = {};
    for (final entry in weekCache.entries) {
      final week = entry.key;
      final cache = entry.value;
      if (cache.packageId != null) {
        packageIds[week] = cache.packageId!;
      }
    }
    return packageIds;
  }

  // Week navigation helpers
  bool get canGoToNextWeek => currentWeek < duration;
  bool get canGoToPreviousWeek => currentWeek > 1;
  bool get isFirstWeek => currentWeek == 1;
  bool get isLastWeek => currentWeek == duration;

  // Week date calculations
  DateTime getWeekStartDate(int week) {
    return startDate.add(Duration(days: (week - 1) * 7));
  }

  DateTime getWeekEndDate(int week) {
    return getWeekStartDate(week).add(const Duration(days: 6));
  }

  DateTime get currentWeekStartDate => getWeekStartDate(currentWeek);
  DateTime get currentWeekEndDate => getWeekEndDate(currentWeek);

  // Validation helpers
  List<int> get invalidWeeks {
    final List<int> invalid = [];
    for (int week = 1; week <= duration; week++) {
      if (!isWeekValid(week)) invalid.add(week);
    }
    return invalid;
  }

  List<int> get validWeeks {
    final List<int> valid = [];
    for (int week = 1; week <= duration; week++) {
      if (isWeekValid(week)) valid.add(week);
    }
    return valid;
  }

  String? get validationMessage {
    if (allWeeksValid) return null;

    final invalid = invalidWeeks;
    if (invalid.length == 1) {
      return 'Week ${invalid.first} needs ${mealPlan - getSelectedMealCount(invalid.first)} more meals';
    } else {
      return '${invalid.length} weeks need more meals';
    }
  }

  WeekSelectionActive copyWith({
    DateTime? startDate,
    String? dietaryPreference,
    int? duration,
    int? mealPlan,
    int? currentWeek,
    Map<int, WeekCache>? weekCache,
    List<MealSelection>? selections,
  }) {
    return WeekSelectionActive(
      startDate: startDate ?? this.startDate,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      duration: duration ?? this.duration,
      mealPlan: mealPlan ?? this.mealPlan,
      currentWeek: currentWeek ?? this.currentWeek,
      weekCache: weekCache ?? this.weekCache,
      selections: selections ?? this.selections,
    );
  }
}

// Enhanced planning complete state
class PlanningComplete extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final Map<int, WeekCache> weekCache;
  final List<MealSelection> selections;

  const PlanningComplete({
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
    required this.weekCache,
    required this.selections,
  });

  @override
  List<Object?> get props => [
    startDate,
    dietaryPreference,
    duration,
    mealPlan,
    weekCache,
    selections,
  ];

  // Enhanced summary calculations
  int get totalSelectedMeals => selections.length;
  int get totalRequiredMeals => duration * mealPlan;

  Map<String, int> get mealTypeDistribution {
    final Map<String, int> distribution = {
      'breakfast': 0,
      'lunch': 0,
      'dinner': 0,
    };

    for (final selection in selections) {
      final key = selection.mealType.toLowerCase();
      distribution[key] = (distribution[key] ?? 0) + 1;
    }

    return distribution;
  }

  Map<int, int> get weeklyMealCounts {
    final Map<int, int> counts = {};
    for (final selection in selections) {
      counts[selection.week] = (counts[selection.week] ?? 0) + 1;
    }
    return counts;
  }

  // Week package management
  Map<int, String> get weekPackageIds {
    final Map<int, String> packageIds = {};
    for (final entry in weekCache.entries) {
      final week = entry.key;
      final cache = entry.value;
      if (cache.packageId != null) {
        packageIds[week] = cache.packageId!;
      }
    }
    return packageIds;
  }

  // Enhanced validation
  bool get isValidForSubscription {
    // Check if all weeks have correct meal count
    for (int week = 1; week <= duration; week++) {
      final weekCount = selections.where((s) => s.week == week).length;
      if (weekCount != mealPlan) return false;
    }

    // Check if all weeks have package IDs
    for (int week = 1; week <= duration; week++) {
      if (!weekPackageIds.containsKey(week)) return false;
    }

    // Check basic data integrity
    if (selections.isEmpty) return false;
    if (totalSelectedMeals != totalRequiredMeals) return false;

    return true;
  }

  List<String> get validationErrors {
    final List<String> errors = [];

    // Check week completion
    for (int week = 1; week <= duration; week++) {
      final weekCount = selections.where((s) => s.week == week).length;
      if (weekCount != mealPlan) {
        errors.add('Week $week has $weekCount meals, expected $mealPlan');
      }
    }

    // Check package IDs
    for (int week = 1; week <= duration; week++) {
      if (!weekPackageIds.containsKey(week)) {
        errors.add('Week $week missing package ID');
      }
    }

    // Check selections integrity
    if (selections.isEmpty) {
      errors.add('No meals selected');
    }

    if (totalSelectedMeals != totalRequiredMeals) {
      errors.add(
        'Total selected meals ($totalSelectedMeals) does not match required ($totalRequiredMeals)',
      );
    }

    return errors;
  }

  // Subscription date calculations
  DateTime get calculatedEndDate =>
      startDate.add(Duration(days: duration * 7 - 1));

  // Summary statistics
  Map<String, dynamic> get summaryStats {
    return {
      'totalDays': duration * 7,
      'totalWeeks': duration,
      'totalMeals': totalSelectedMeals,
      'mealsPerWeek': mealPlan,
      'avgMealsPerDay': totalSelectedMeals / (duration * 7),
      'mealTypeDistribution': mealTypeDistribution,
      'weeklyMealCounts': weeklyMealCounts,
      'isValid': isValidForSubscription,
      'validationErrors': validationErrors,
    };
  }

  // Generate subscription request
  SubscriptionRequest buildSubscriptionRequest({
    required String addressId,
    String? instructions,
    int noOfPersons = 1,
  }) {
    return SubscriptionService.buildRequest(
      startDate: startDate,
      durationDays: duration * 7,
      addressId: addressId,
      instructions: instructions,
      noOfPersons: noOfPersons,
      selections: selections,
      weekPackageIds: weekPackageIds,
    );
  }
}

// Enhanced checkout state
class CheckoutActive extends SubscriptionPlanningState {
  final PlanningComplete planningData;
  final String? selectedAddressId;
  final String? instructions;
  final int noOfPersons;
  final bool isSubmitting;

  const CheckoutActive({
    required this.planningData,
    this.selectedAddressId,
    this.instructions,
    this.noOfPersons = 1,
    this.isSubmitting = false,
  });

  @override
  List<Object?> get props => [
    planningData,
    selectedAddressId,
    instructions,
    noOfPersons,
    isSubmitting,
  ];

  bool get canSubmit =>
      selectedAddressId != null &&
      selectedAddressId!.isNotEmpty &&
      !isSubmitting &&
      noOfPersons > 0 &&
      planningData.isValidForSubscription;

  double get completionPercentage {
    int completedFields = 0;
    if (selectedAddressId?.isNotEmpty == true) completedFields++;
    if (noOfPersons > 0) completedFields++;
    // Instructions are optional, so don't count them
    return completedFields / 2.0;
  }

  List<String> get missingFields {
    final List<String> missing = [];
    if (selectedAddressId?.isEmpty != false) missing.add('Delivery Address');
    if (noOfPersons <= 0) missing.add('Number of Persons');
    return missing;
  }

  // Calculate subscription cost (if pricing is available)
  double? get estimatedCost {
    // This would be calculated based on package pricing
    // For now, return null since pricing logic would depend on package data
    return null;
  }

  // Generate final subscription request
  SubscriptionRequest get subscriptionRequest {
    return planningData.buildSubscriptionRequest(
      addressId: selectedAddressId!,
      instructions: instructions,
      noOfPersons: noOfPersons,
    );
  }

  CheckoutActive copyWith({
    PlanningComplete? planningData,
    String? selectedAddressId,
    String? instructions,
    int? noOfPersons,
    bool? isSubmitting,
  }) {
    return CheckoutActive(
      planningData: planningData ?? this.planningData,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      instructions: instructions ?? this.instructions,
      noOfPersons: noOfPersons ?? this.noOfPersons,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
