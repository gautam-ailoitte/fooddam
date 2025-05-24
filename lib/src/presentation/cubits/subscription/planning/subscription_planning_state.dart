// lib/src/presentation/cubits/subscription/planning/subscription_planning_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/entities/dish_selection.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

/// Simplified subscription planning states with selection data
abstract class SubscriptionPlanningState extends Equatable {
  const SubscriptionPlanningState();

  @override
  List<Object?> get props => [];
}

/// Initial state when planning hasn't started
class SubscriptionPlanningInitial extends SubscriptionPlanningState {}

/// Loading state for any async operations
class SubscriptionPlanningLoading extends SubscriptionPlanningState {
  final String? message;

  const SubscriptionPlanningLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Error state for any failures
class SubscriptionPlanningError extends SubscriptionPlanningState {
  final String message;

  const SubscriptionPlanningError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Planning form is active and ready for user input
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

  /// Check if form is valid for proceeding to meal selection
  bool get isFormValid =>
      startDate != null &&
      dietaryPreference != null &&
      duration != null &&
      mealPlan != null &&
      startDate!.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
      duration! > 0 &&
      mealPlan! > 0;

  /// Get form completion percentage for UI progress indicators
  double get completionPercentage {
    int completedFields = 0;
    if (startDate != null) completedFields++;
    if (dietaryPreference != null) completedFields++;
    if (duration != null) completedFields++;
    if (mealPlan != null) completedFields++;
    return completedFields / 4.0;
  }

  /// Get list of missing field names for validation messages
  List<String> get missingFields {
    final List<String> missing = [];
    if (startDate == null) missing.add('Start Date');
    if (dietaryPreference == null) missing.add('Dietary Preference');
    if (duration == null) missing.add('Duration');
    if (mealPlan == null) missing.add('Meal Plan');
    return missing;
  }

  /// Create copy with updated values
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

/// Week selection flow is active - NOW WITH SELECTIONS!
class WeekSelectionActive extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final int currentWeek;
  final Map<int, WeekDataStatus> weekDataStatus;
  final Map<int, List<DishSelection>> weekSelections;
  final Map<int, String> weekPackageIds;
  final Map<int, double> weekPricing; // 🔥 NEW: Store pricing per week

  const WeekSelectionActive({
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
    required this.currentWeek,
    required this.weekDataStatus,
    this.weekSelections = const {},
    this.weekPackageIds = const {},
    this.weekPricing = const {}, // 🔥 NEW: Default empty map
  });

  // 🔥 FIXED: Remove Equatable props and use custom equality
  @override
  List<Object?> get props => [
    startDate,
    dietaryPreference,
    duration,
    mealPlan,
    currentWeek,
    weekDataStatus,
    weekSelections.length, // Use length instead of Map for Equatable
    weekPackageIds.length,
    weekPricing.length, // 🔥 NEW
    _getSelectionsHash(), // Custom hash for selections
  ];

  // Generate unique hash based on selections content
  int _getSelectionsHash() {
    int hash = 0;
    weekSelections.forEach((week, selections) {
      hash = hash ^ week.hashCode;
      for (final selection in selections) {
        hash = hash ^ selection.id.hashCode;
      }
    });
    return hash;
  }

  /// Check if current week data is loaded
  bool get isCurrentWeekLoaded {
    final status = weekDataStatus[currentWeek];
    return status != null && status.isLoaded;
  }

  /// Check if current week is loading
  bool get isCurrentWeekLoading {
    final status = weekDataStatus[currentWeek];
    return status != null && status.isLoading;
  }

  /// Check if current week has error
  bool get currentWeekHasError {
    final status = weekDataStatus[currentWeek];
    return status != null && status.hasError;
  }

  /// Get current week error message
  String? get currentWeekError {
    final status = weekDataStatus[currentWeek];
    return status?.errorMessage;
  }

  /// Get current week calculated plan
  CalculatedPlan? get currentWeekPlan {
    final status = weekDataStatus[currentWeek];
    return status?.calculatedPlan;
  }

  /// Get current week package ID
  String? get currentWeekPackageId {
    final status = weekDataStatus[currentWeek];
    return status?.packageId;
  }

  /// 🔥 NEW: Get current week pricing
  double? get currentWeekPricing {
    return weekPricing[currentWeek];
  }

  /// 🔥 NEW: Get total pricing for all loaded weeks
  double get totalPricing {
    return weekPricing.values.fold(0.0, (sum, price) => sum + price);
  }

  /// Navigation helpers
  bool get canGoToNextWeek => currentWeek < duration;
  bool get canGoToPreviousWeek => currentWeek > 1;
  bool get isFirstWeek => currentWeek == 1;
  bool get isLastWeek => currentWeek == duration;

  /// Calculate date range for current week
  DateTime get currentWeekStartDate =>
      startDate.add(Duration(days: (currentWeek - 1) * 7));

  DateTime get currentWeekEndDate =>
      currentWeekStartDate.add(const Duration(days: 6));

  // 🔥 SELECTION METHODS

  /// Check if a specific dish is selected (FIXED LOGIC)
  bool isDishSelected(String dishId, String day, String timing) {
    final currentWeekSelections = weekSelections[currentWeek] ?? [];
    return currentWeekSelections.any(
      (selection) =>
          selection.dishId == dishId &&
          selection.day.toLowerCase() == day.toLowerCase() &&
          selection.timing.toLowerCase() == timing.toLowerCase(),
    );
  }

  /// Get selection count for current week
  int get currentWeekSelectionCount {
    return weekSelections[currentWeek]?.length ?? 0;
  }

  /// Check if current week is complete
  bool get isCurrentWeekComplete {
    return currentWeekSelectionCount == mealPlan;
  }

  /// Check if can select more for current week
  bool get canSelectMore {
    return currentWeekSelectionCount < mealPlan;
  }

  /// Get all selections for all weeks
  List<DishSelection> get allSelections {
    final all = <DishSelection>[];
    for (final selections in weekSelections.values) {
      all.addAll(selections);
    }
    return all;
  }

  /// Check if all weeks are complete
  bool get isAllWeeksComplete {
    for (int week = 1; week <= duration; week++) {
      final weekCount = weekSelections[week]?.length ?? 0;
      if (weekCount != mealPlan) return false;
    }
    return true;
  }

  /// Get completion progress
  double get completionProgress {
    final totalRequired = duration * mealPlan;
    final totalSelected = allSelections.length;
    return totalRequired > 0 ? totalSelected / totalRequired : 0.0;
  }

  /// 🔥 FIXED: Create copy with completely new Map instances
  WeekSelectionActive copyWith({
    DateTime? startDate,
    String? dietaryPreference,
    int? duration,
    int? mealPlan,
    int? currentWeek,
    Map<int, WeekDataStatus>? weekDataStatus,
    Map<int, List<DishSelection>>? weekSelections,
    Map<int, String>? weekPackageIds,
    Map<int, double>? weekPricing, // 🔥 NEW
  }) {
    return WeekSelectionActive(
      startDate: startDate ?? this.startDate,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      duration: duration ?? this.duration,
      mealPlan: mealPlan ?? this.mealPlan,
      currentWeek: currentWeek ?? this.currentWeek,
      weekDataStatus: weekDataStatus ?? this.weekDataStatus,
      weekSelections: weekSelections ?? this.weekSelections,
      weekPackageIds: weekPackageIds ?? this.weekPackageIds,
      weekPricing: weekPricing ?? this.weekPricing, // 🔥 NEW
    );
  }
}

/// Planning is complete and ready for checkout - WITH SELECTIONS
class PlanningComplete extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final Map<int, List<DishSelection>> weekSelections;
  final Map<int, String> weekPackageIds;
  final Map<int, double> weekPricing; // 🔥 NEW

  const PlanningComplete({
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
    required this.weekSelections,
    required this.weekPackageIds,
    required this.weekPricing, // 🔥 NEW
  });

  @override
  List<Object?> get props => [
    startDate,
    dietaryPreference,
    duration,
    mealPlan,
    weekSelections,
    weekPackageIds,
    weekPricing, // 🔥 NEW
  ];

  /// Calculate end date based on duration
  DateTime get calculatedEndDate =>
      startDate.add(Duration(days: duration * 7 - 1));

  /// Get all selections
  List<DishSelection> get allSelections {
    final all = <DishSelection>[];
    for (final selections in weekSelections.values) {
      all.addAll(selections);
    }
    return all;
  }

  /// 🔥 NEW: Get total pricing
  double get totalPricing {
    return weekPricing.values.fold(0.0, (sum, price) => sum + price);
  }

  /// Get meal type distribution
  Map<String, int> get mealTypeDistribution {
    final distribution = <String, int>{'breakfast': 0, 'lunch': 0, 'dinner': 0};

    for (final selection in allSelections) {
      final mealType = selection.timing.toLowerCase();
      distribution[mealType] = (distribution[mealType] ?? 0) + 1;
    }

    return distribution;
  }

  /// Check if ready for submission
  bool get isReadyForSubmission {
    final totalRequired = duration * mealPlan;
    final totalSelected = allSelections.length;
    return totalSelected == totalRequired;
  }

  /// Get summary stats
  Map<String, dynamic> get summaryStats {
    return {
      'totalSelections': allSelections.length,
      'totalRequired': duration * mealPlan,
      'completionProgress': allSelections.length / (duration * mealPlan),
      'mealTypeDistribution': mealTypeDistribution,
      'totalPricing': totalPricing, // 🔥 NEW
      'isReadyForSubmission': isReadyForSubmission,
    };
  }

  /// Create copy with updated values
  PlanningComplete copyWith({
    DateTime? startDate,
    String? dietaryPreference,
    int? duration,
    int? mealPlan,
    Map<int, List<DishSelection>>? weekSelections,
    Map<int, String>? weekPackageIds,
    Map<int, double>? weekPricing, // 🔥 NEW
  }) {
    return PlanningComplete(
      startDate: startDate ?? this.startDate,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      duration: duration ?? this.duration,
      mealPlan: mealPlan ?? this.mealPlan,
      weekSelections: weekSelections ?? this.weekSelections,
      weekPackageIds: weekPackageIds ?? this.weekPackageIds,
      weekPricing: weekPricing ?? this.weekPricing, // 🔥 NEW
    );
  }
}

/// Checkout flow is active - WITH SELECTIONS AND PRICING
class CheckoutActive extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final Map<int, List<DishSelection>> weekSelections;
  final Map<int, String> weekPackageIds;
  final Map<int, double> weekPricing; // 🔥 NEW
  final String? selectedAddressId;
  final String? instructions;
  final int noOfPersons;
  final bool isSubmitting;

  const CheckoutActive({
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
    required this.weekSelections,
    required this.weekPackageIds,
    required this.weekPricing, // 🔥 NEW
    this.selectedAddressId,
    this.instructions,
    this.noOfPersons = 1,
    this.isSubmitting = false,
  });

  @override
  List<Object?> get props => [
    startDate,
    dietaryPreference,
    duration,
    mealPlan,
    weekSelections,
    weekPackageIds,
    weekPricing, // 🔥 NEW
    selectedAddressId,
    instructions,
    noOfPersons,
    isSubmitting,
  ];

  /// Get all selections
  List<DishSelection> get allSelections {
    final all = <DishSelection>[];
    for (final selections in weekSelections.values) {
      all.addAll(selections);
    }
    return all;
  }

  /// 🔥 NEW: Get total pricing
  double get totalPricing {
    return weekPricing.values.fold(0.0, (sum, price) => sum + price);
  }

  /// Check if checkout form is ready for submission
  bool get canSubmit =>
      selectedAddressId != null &&
      selectedAddressId!.isNotEmpty &&
      !isSubmitting &&
      noOfPersons > 0;

  /// Get checkout completion percentage
  double get completionPercentage {
    int completedFields = 0;
    if (selectedAddressId?.isNotEmpty == true) completedFields++;
    if (noOfPersons > 0) completedFields++;
    return completedFields / 2.0;
  }

  /// Get missing fields for validation
  List<String> get missingFields {
    final List<String> missing = [];
    if (selectedAddressId?.isEmpty != false) missing.add('Delivery Address');
    if (noOfPersons <= 0) missing.add('Number of Persons');
    return missing;
  }

  /// Calculate end date for subscription
  DateTime get calculatedEndDate =>
      startDate.add(Duration(days: duration * 7 - 1));

  /// Create copy with updated values
  CheckoutActive copyWith({
    DateTime? startDate,
    String? dietaryPreference,
    int? duration,
    int? mealPlan,
    Map<int, List<DishSelection>>? weekSelections,
    Map<int, String>? weekPackageIds,
    Map<int, double>? weekPricing, // 🔥 NEW
    String? selectedAddressId,
    String? instructions,
    int? noOfPersons,
    bool? isSubmitting,
  }) {
    return CheckoutActive(
      startDate: startDate ?? this.startDate,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      duration: duration ?? this.duration,
      mealPlan: mealPlan ?? this.mealPlan,
      weekSelections: weekSelections ?? this.weekSelections,
      weekPackageIds: weekPackageIds ?? this.weekPackageIds,
      weekPricing: weekPricing ?? this.weekPricing, // 🔥 NEW
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      instructions: instructions ?? this.instructions,
      noOfPersons: noOfPersons ?? this.noOfPersons,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// 🔥 NEW: Subscription creation was successful - ready for payment
class SubscriptionCreationSuccess extends SubscriptionPlanningState {
  final Subscription subscription;
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final Map<int, List<DishSelection>> weekSelections;
  final Map<int, String> weekPackageIds;
  final Map<int, double> weekPricing; // 🔥 NEW
  final String selectedAddressId;
  final String? instructions;
  final int noOfPersons;

  const SubscriptionCreationSuccess({
    required this.subscription,
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
    required this.weekSelections,
    required this.weekPackageIds,
    required this.weekPricing, // 🔥 NEW
    required this.selectedAddressId,
    this.instructions,
    required this.noOfPersons,
  });

  @override
  List<Object?> get props => [
    subscription,
    startDate,
    dietaryPreference,
    duration,
    mealPlan,
    weekSelections,
    weekPackageIds,
    weekPricing, // 🔥 NEW
    selectedAddressId,
    instructions,
    noOfPersons,
  ];

  /// Get all selections
  List<DishSelection> get allSelections {
    final all = <DishSelection>[];
    for (final selections in weekSelections.values) {
      all.addAll(selections);
    }
    return all;
  }

  /// 🔥 NEW: Get total pricing
  double get totalPricing {
    return weekPricing.values.fold(0.0, (sum, price) => sum + price);
  }

  /// Calculate end date for subscription
  DateTime get calculatedEndDate =>
      startDate.add(Duration(days: duration * 7 - 1));

  /// Get meal type distribution
  Map<String, int> get mealTypeDistribution {
    final distribution = <String, int>{'breakfast': 0, 'lunch': 0, 'dinner': 0};

    for (final selection in allSelections) {
      final mealType = selection.timing.toLowerCase();
      distribution[mealType] = (distribution[mealType] ?? 0) + 1;
    }

    return distribution;
  }
}

/// 🔥 Subscription creation failed
class SubscriptionCreationError extends SubscriptionPlanningState {
  final String message;
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final Map<int, List<DishSelection>> weekSelections;
  final Map<int, String> weekPackageIds;
  final Map<int, double> weekPricing; // 🔥 NEW
  final String? selectedAddressId;
  final String? instructions;
  final int noOfPersons;

  const SubscriptionCreationError({
    required this.message,
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
    required this.weekSelections,
    required this.weekPackageIds,
    required this.weekPricing, // 🔥 NEW
    this.selectedAddressId,
    this.instructions,
    required this.noOfPersons,
  });

  @override
  List<Object?> get props => [
    message,
    startDate,
    dietaryPreference,
    duration,
    mealPlan,
    weekSelections,
    weekPackageIds,
    weekPricing, // 🔥 NEW
    selectedAddressId,
    instructions,
    noOfPersons,
  ];

  /// Get all selections
  List<DishSelection> get allSelections {
    final all = <DishSelection>[];
    for (final selections in weekSelections.values) {
      all.addAll(selections);
    }
    return all;
  }

  /// 🔥 NEW: Get total pricing
  double get totalPricing {
    return weekPricing.values.fold(0.0, (sum, price) => sum + price);
  }

  /// Calculate end date for subscription
  DateTime get calculatedEndDate =>
      startDate.add(Duration(days: duration * 7 - 1));

  /// Check if can retry submission
  bool get canRetry =>
      selectedAddressId != null &&
      selectedAddressId!.isNotEmpty &&
      noOfPersons > 0;
}

/// Helper class to track week data loading status
class WeekDataStatus extends Equatable {
  final int week;
  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
  final CalculatedPlan? calculatedPlan;
  final String? packageId;
  final double? pricePerMeal; // 🔥 NEW: Store price for selected meal plan

  const WeekDataStatus({
    required this.week,
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
    this.calculatedPlan,
    this.packageId,
    this.pricePerMeal, // 🔥 NEW
  });

  @override
  List<Object?> get props => [
    week,
    isLoading,
    isLoaded,
    errorMessage,
    calculatedPlan,
    packageId,
    pricePerMeal, // 🔥 NEW
  ];

  /// Check if this week has an error
  bool get hasError => errorMessage != null;

  /// Factory constructors for different states
  factory WeekDataStatus.loading(int week) {
    return WeekDataStatus(week: week, isLoading: true);
  }

  factory WeekDataStatus.loaded({
    required int week,
    required CalculatedPlan calculatedPlan,
    required String packageId,
    required double pricePerMeal, // 🔥 NEW: Required parameter
  }) {
    return WeekDataStatus(
      week: week,
      isLoaded: true,
      calculatedPlan: calculatedPlan,
      packageId: packageId,
      pricePerMeal: pricePerMeal, // 🔥 NEW
    );
  }

  factory WeekDataStatus.error({
    required int week,
    required String errorMessage,
  }) {
    return WeekDataStatus(week: week, errorMessage: errorMessage);
  }

  /// Create copy with updated values
  WeekDataStatus copyWith({
    int? week,
    bool? isLoading,
    bool? isLoaded,
    String? errorMessage,
    CalculatedPlan? calculatedPlan,
    String? packageId,
    double? pricePerMeal, // 🔥 NEW
  }) {
    return WeekDataStatus(
      week: week ?? this.week,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage ?? this.errorMessage,
      calculatedPlan: calculatedPlan ?? this.calculatedPlan,
      packageId: packageId ?? this.packageId,
      pricePerMeal: pricePerMeal ?? this.pricePerMeal, // 🔥 NEW
    );
  }
}
