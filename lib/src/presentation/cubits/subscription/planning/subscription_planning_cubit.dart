// lib/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/usecase/calendar_usecase.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';

import 'subscription_planning_state.dart';

class SubscriptionPlanningCubit extends Cubit<SubscriptionPlanningState> {
  final CalendarUseCase _calendarUseCase;
  final SubscriptionUseCase _subscriptionUseCase;
  final LoggerService _logger = LoggerService();

  SubscriptionPlanningCubit({
    required CalendarUseCase calendarUseCase,
    required SubscriptionUseCase subscriptionUseCase,
  }) : _calendarUseCase = calendarUseCase,
       _subscriptionUseCase = subscriptionUseCase,
       super(SubscriptionPlanningInitial());

  /// Initialize planning form
  void initializePlanning() {
    emit(const PlanningFormActive());
  }

  /// Update form data
  void updateFormData({
    DateTime? startDate,
    String? dietaryPreference,
    int? duration,
    int? mealPlan,
  }) {
    if (state is PlanningFormActive) {
      final currentState = state as PlanningFormActive;
      emit(
        currentState.copyWith(
          startDate: startDate,
          dietaryPreference: dietaryPreference,
          duration: duration,
          mealPlan: mealPlan,
        ),
      );
    }
  }

  /// Start week selection flow
  Future<void> startWeekSelection() async {
    if (state is! PlanningFormActive) return;

    final formState = state as PlanningFormActive;
    if (!formState.isFormValid) {
      emit(const SubscriptionPlanningError('Please complete all form fields'));
      return;
    }

    try {
      emit(SubscriptionPlanningLoading());

      // Initialize week selection state
      final weekSelectionState = WeekSelectionActive(
        startDate: formState.startDate!,
        dietaryPreference: formState.dietaryPreference!,
        duration: formState.duration!,
        mealPlan: formState.mealPlan!,
        currentWeek: 1,
        weeksData: {},
        mealSelections: {},
      );

      emit(weekSelectionState);

      // Load first week data
      await _loadWeekData(1);
    } catch (e) {
      _logger.e('Error starting week selection', error: e);
      emit(SubscriptionPlanningError('Failed to start meal selection: $e'));
    }
  }

  /// Load calculated plan data for a specific week
  Future<void> _loadWeekData(int week) async {
    if (state is! WeekSelectionActive) return;

    final currentState = state as WeekSelectionActive;

    try {
      _logger.i('Loading data for week $week');

      // Calculate start date for this week
      final weekStartDate = currentState.startDate.add(
        Duration(days: (week - 1) * 7),
      );

      // Call calculated plan API
      final result = await _calendarUseCase.getCalculatedPlan(
        dietaryPreference: currentState.dietaryPreference,
        week: week,
        startDate: weekStartDate,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to load week $week data', error: failure);
          emit(
            SubscriptionPlanningError(
              failure.message ?? 'Failed to load meal plan for week $week',
            ),
          );
        },
        (calculatedPlan) {
          _logger.i('Successfully loaded week $week data');

          // Calculate week end date
          final weekEndDate = weekStartDate.add(const Duration(days: 6));

          // Create week plan data
          final weekPlanData = WeekPlanData(
            calculatedPlan: calculatedPlan,
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
          );

          // Update weeks data
          final updatedWeeksData = Map<int, WeekPlanData>.from(
            currentState.weeksData,
          );
          updatedWeeksData[week] = weekPlanData;

          // Initialize meal selections for this week if not already done
          final updatedMealSelections =
              Map<int, Map<DateTime, Map<String, bool>>>.from(
                currentState.mealSelections,
              );

          if (!updatedMealSelections.containsKey(week)) {
            updatedMealSelections[week] = _initializeMealSelections(
              calculatedPlan,
            );
          }

          emit(
            currentState.copyWith(
              weeksData: updatedWeeksData,
              mealSelections: updatedMealSelections,
            ),
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error loading week $week data', error: e);
      emit(SubscriptionPlanningError('An unexpected error occurred'));
    }
  }

  /// Initialize meal selections for a calculated plan (all unselected)
  Map<DateTime, Map<String, bool>> _initializeMealSelections(
    CalculatedPlan calculatedPlan,
  ) {
    final Map<DateTime, Map<String, bool>> selections = {};

    for (final dailyMeal in calculatedPlan.dailyMeals) {
      final date = DateTime(
        dailyMeal.date.year,
        dailyMeal.date.month,
        dailyMeal.date.day,
      );

      selections[date] = {};

      // Check which meals are available for this day
      final dayMeal = dailyMeal.slot.meal;
      if (dayMeal != null) {
        if (dayMeal.dishes['breakfast'] != null) {
          selections[date]!['breakfast'] = false;
        }
        if (dayMeal.dishes['lunch'] != null) {
          selections[date]!['lunch'] = false;
        }
        if (dayMeal.dishes['dinner'] != null) {
          selections[date]!['dinner'] = false;
        }
      }
    }

    return selections;
  }

  /// Navigate to specific week
  Future<void> navigateToWeek(int week) async {
    if (state is! WeekSelectionActive) return;

    final currentState = state as WeekSelectionActive;

    if (week < 1 || week > currentState.duration) return;

    // Update current week
    emit(currentState.copyWith(currentWeek: week));

    // Load week data if not already loaded
    if (!currentState.weeksData.containsKey(week)) {
      await _loadWeekData(week);
    }
  }

  /// Toggle meal selection
  void toggleMealSelection({
    required int week,
    required DateTime date,
    required String mealType,
  }) {
    if (state is! WeekSelectionActive) return;

    final currentState = state as WeekSelectionActive;

    // Create a deep copy of meal selections
    final updatedMealSelections =
        Map<int, Map<DateTime, Map<String, bool>>>.from(
          currentState.mealSelections,
        );

    if (!updatedMealSelections.containsKey(week)) {
      updatedMealSelections[week] = {};
    }

    if (!updatedMealSelections[week]!.containsKey(date)) {
      updatedMealSelections[week]![date] = {};
    }

    // Get current selection count for this week
    final currentCount = currentState.getSelectedMealCount(week);
    final isCurrentlySelected =
        updatedMealSelections[week]![date]![mealType] ?? false;

    // Check if we can toggle this selection
    if (!isCurrentlySelected && currentCount >= currentState.mealPlan) {
      // Cannot select more meals
      _logger.w(
        'Cannot select more than ${currentState.mealPlan} meals for week $week',
      );
      return;
    }

    // Toggle the selection
    updatedMealSelections[week]![date]![mealType] = !isCurrentlySelected;

    emit(currentState.copyWith(mealSelections: updatedMealSelections));

    _logger.i(
      'Toggled meal: Week $week, Date ${date.day}/${date.month}, $mealType = ${!isCurrentlySelected}',
    );
  }

  /// Go to next week
  Future<void> nextWeek() async {
    if (state is! WeekSelectionActive) return;

    final currentState = state as WeekSelectionActive;

    // Validate current week before proceeding
    if (!currentState.isWeekValid(currentState.currentWeek)) {
      emit(
        SubscriptionPlanningError(
          'Please select exactly ${currentState.mealPlan} meals for week ${currentState.currentWeek}',
        ),
      );
      return;
    }

    if (currentState.currentWeek < currentState.duration) {
      await navigateToWeek(currentState.currentWeek + 1);
    } else {
      // All weeks completed
      _completePlanning();
    }
  }

  /// Go to previous week
  Future<void> previousWeek() async {
    if (state is! WeekSelectionActive) return;

    final currentState = state as WeekSelectionActive;

    if (currentState.currentWeek > 1) {
      await navigateToWeek(currentState.currentWeek - 1);
    }
  }

  /// Complete planning and move to summary
  void _completePlanning() {
    if (state is! WeekSelectionActive) return;

    final currentState = state as WeekSelectionActive;

    if (!currentState.allWeeksValid) {
      emit(
        const SubscriptionPlanningError(
          'Please complete all weeks before proceeding',
        ),
      );
      return;
    }

    emit(
      PlanningComplete(
        startDate: currentState.startDate,
        dietaryPreference: currentState.dietaryPreference,
        duration: currentState.duration,
        mealPlan: currentState.mealPlan,
        weeksData: currentState.weeksData,
        mealSelections: currentState.mealSelections,
      ),
    );

    _logger.i('Planning completed successfully');
  }

  /// Create subscription
  Future<void> createSubscription({
    required String addressId,
    String? instructions,
    int noOfPersons = 1,
  }) async {
    if (state is! PlanningComplete) return;

    final planningState = state as PlanningComplete;

    try {
      emit(SubscriptionPlanningLoading());

      // Generate subscription weeks
      final weeks = planningState.generateSubscriptionWeeks();

      // Create subscription parameters
      final params = SubscriptionParams(
        startDate: planningState.startDate,
        durationDays: planningState.duration * 7,
        addressId: addressId,
        instructions: instructions,
        noOfPersons: noOfPersons,
        weeks: weeks,
      );

      // Call subscription creation
      final result = await _subscriptionUseCase.createSubscription(params);

      result.fold(
        (failure) {
          _logger.e('Failed to create subscription', error: failure);
          emit(
            SubscriptionPlanningError(
              failure.message ?? 'Failed to create subscription',
            ),
          );
        },
        (subscription) {
          _logger.i('Subscription created successfully: ${subscription.id}');
          // Keep the planning complete state but maybe add subscription ID
          emit(planningState);
        },
      );
    } catch (e) {
      _logger.e('Unexpected error creating subscription', error: e);
      emit(const SubscriptionPlanningError('An unexpected error occurred'));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(SubscriptionPlanningInitial());
  }

  /// Retry loading current week data
  Future<void> retryLoadWeek() async {
    if (state is! WeekSelectionActive) return;

    final currentState = state as WeekSelectionActive;
    await _loadWeekData(currentState.currentWeek);
  }
}
