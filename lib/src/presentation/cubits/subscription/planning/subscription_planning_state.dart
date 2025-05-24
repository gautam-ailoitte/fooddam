// lib/src/presentation/cubits/subscription/planning/simplified_planning_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/services/week_data_service.dart';

import '../../../../domain/services/subscription_service.dart';

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

// Week-by-week selection state - SIMPLIFIED
class WeekSelectionActive extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final int currentWeek;

  // SIMPLIFIED: No more nested maps!
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

  // SIMPLE queries using flat list
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

  List<MealOption> getCurrentWeekMealOptions() {
    final cache = weekCache[currentWeek];
    if (cache?.calculatedPlan == null) return [];

    // This will be handled by WeekDataService.extractMealOptions
    return [];
  }

  // SIMPLE selection queries
  bool isMealSelected(String mealOptionId, int week) {
    return selections.any((s) => s.week == week && s.id.contains(mealOptionId));
  }

  List<MealSelection> getSelectionsForWeek(int week) {
    return selections.where((s) => s.week == week).toList();
  }

  List<MealSelection> getSelectionsForMealType(String mealType) {
    return selections.where((s) => s.mealType == mealType).toList();
  }

  Map<String, int> getMealTypeDistribution() {
    final Map<String, int> distribution = {
      'breakfast': 0,
      'lunch': 0,
      'dinner': 0,
    };

    for (final selection in selections) {
      distribution[selection.mealType] =
          (distribution[selection.mealType] ?? 0) + 1;
    }

    return distribution;
  }

  // Get package IDs for final subscription request
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

// Planning complete state - SIMPLIFIED
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

  // SIMPLE summary calculations
  int get totalSelectedMeals => selections.length;

  Map<String, int> get mealTypeDistribution {
    final Map<String, int> distribution = {
      'breakfast': 0,
      'lunch': 0,
      'dinner': 0,
    };

    for (final selection in selections) {
      distribution[selection.mealType] =
          (distribution[selection.mealType] ?? 0) + 1;
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

  // Get package IDs for subscription request
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

  // Validate all selections before creating subscription
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

    return true;
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

// Checkout state - NEW for final API call
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
      noOfPersons > 0;

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
