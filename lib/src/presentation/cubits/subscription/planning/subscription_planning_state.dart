// lib/src/presentation/cubits/subscription/planning/subscription_planning_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';

/// Simplified subscription planning states
/// Removed complex selection management and caching - those are now handled by MealSelectionService
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

/// Week selection flow is active
/// This state only manages week navigation and data loading
/// Meal selections are handled by MealSelectionService
class WeekSelectionActive extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final int currentWeek;
  final Map<int, WeekDataStatus> weekDataStatus;

  const WeekSelectionActive({
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
    required this.currentWeek,
    required this.weekDataStatus,
  });

  @override
  List<Object?> get props => [
    startDate,
    dietaryPreference,
    duration,
    mealPlan,
    currentWeek,
    weekDataStatus,
  ];

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

  /// Create copy with updated values
  WeekSelectionActive copyWith({
    DateTime? startDate,
    String? dietaryPreference,
    int? duration,
    int? mealPlan,
    int? currentWeek,
    Map<int, WeekDataStatus>? weekDataStatus,
  }) {
    return WeekSelectionActive(
      startDate: startDate ?? this.startDate,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      duration: duration ?? this.duration,
      mealPlan: mealPlan ?? this.mealPlan,
      currentWeek: currentWeek ?? this.currentWeek,
      weekDataStatus: weekDataStatus ?? this.weekDataStatus,
    );
  }
}

/// Planning is complete and ready for checkout
/// This state is purely for display purposes
/// All selection data comes from MealSelectionService
class PlanningComplete extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;

  const PlanningComplete({
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
  });

  @override
  List<Object?> get props => [startDate, dietaryPreference, duration, mealPlan];

  /// Calculate end date based on duration
  DateTime get calculatedEndDate =>
      startDate.add(Duration(days: duration * 7 - 1));

  /// Create copy with updated values
  PlanningComplete copyWith({
    DateTime? startDate,
    String? dietaryPreference,
    int? duration,
    int? mealPlan,
  }) {
    return PlanningComplete(
      startDate: startDate ?? this.startDate,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      duration: duration ?? this.duration,
      mealPlan: mealPlan ?? this.mealPlan,
    );
  }
}

/// Checkout flow is active
class CheckoutActive extends SubscriptionPlanningState {
  final DateTime startDate;
  final String dietaryPreference;
  final int duration;
  final int mealPlan;
  final String? selectedAddressId;
  final String? instructions;
  final int noOfPersons;
  final bool isSubmitting;

  const CheckoutActive({
    required this.startDate,
    required this.dietaryPreference,
    required this.duration,
    required this.mealPlan,
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
    selectedAddressId,
    instructions,
    noOfPersons,
    isSubmitting,
  ];

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
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      instructions: instructions ?? this.instructions,
      noOfPersons: noOfPersons ?? this.noOfPersons,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Helper class to track week data loading status
class WeekDataStatus extends Equatable {
  final int week;
  final bool isLoading;
  final bool isLoaded;
  final String? errorMessage;
  final CalculatedPlan? calculatedPlan;
  final String? packageId;

  const WeekDataStatus({
    required this.week,
    this.isLoading = false,
    this.isLoaded = false,
    this.errorMessage,
    this.calculatedPlan,
    this.packageId,
  });

  @override
  List<Object?> get props => [
    week,
    isLoading,
    isLoaded,
    errorMessage,
    calculatedPlan,
    packageId,
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
  }) {
    return WeekDataStatus(
      week: week,
      isLoaded: true,
      calculatedPlan: calculatedPlan,
      packageId: packageId,
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
  }) {
    return WeekDataStatus(
      week: week ?? this.week,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage ?? this.errorMessage,
      calculatedPlan: calculatedPlan ?? this.calculatedPlan,
      packageId: packageId ?? this.packageId,
    );
  }
}
