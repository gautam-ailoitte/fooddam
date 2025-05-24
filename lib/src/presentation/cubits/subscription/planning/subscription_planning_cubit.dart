// lib/src/presentation/cubits/subscription/planning/updated_planning_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/services/subscription_service.dart';
import 'package:foodam/src/domain/services/week_data_service.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_state.dart';

class SubscriptionPlanningCubit extends Cubit<SubscriptionPlanningState> {
  final WeekDataService _weekDataService;
  final SubscriptionService _subscriptionService;
  final LoggerService _logger = LoggerService();

  SubscriptionPlanningCubit({
    required WeekDataService weekDataService,
    required SubscriptionService subscriptionService,
  }) : _weekDataService = weekDataService,
       _subscriptionService = subscriptionService,
       super(SubscriptionPlanningInitial());

  /// Initialize planning form
  void initializePlanning() {
    _logger.i('Initializing subscription planning');
    emit(const PlanningFormActive());
  }

  /// Update form data
  void updateFormData({
    DateTime? startDate,
    String? dietaryPreference,
    int? duration,
    int? mealPlan,
  }) {
    final currentState = state;
    if (currentState is! PlanningFormActive) return;

    // Check if critical form data changed (requires cache clear)
    final bool shouldClearCache =
        (startDate != null && startDate != currentState.startDate) ||
        (dietaryPreference != null &&
            dietaryPreference != currentState.dietaryPreference);

    if (shouldClearCache) {
      _logger.i('Form data changed, clearing cache');
      _weekDataService.clearCache();
    }

    emit(
      currentState.copyWith(
        startDate: startDate,
        dietaryPreference: dietaryPreference,
        duration: duration,
        mealPlan: mealPlan,
      ),
    );

    _logger.d('Form data updated');
  }

  /// Start week selection flow
  Future<void> startWeekSelection() async {
    PlanningFormActive? formState;

    // Handle different current states
    if (state is PlanningFormActive) {
      formState = state as PlanningFormActive;
    } else if (state is WeekSelectionActive) {
      // Re-entering from week selection (back navigation case)
      final weekState = state as WeekSelectionActive;
      formState = PlanningFormActive(
        startDate: weekState.startDate,
        dietaryPreference: weekState.dietaryPreference,
        duration: weekState.duration,
        mealPlan: weekState.mealPlan,
      );
    } else {
      _logger.w(
        'Cannot start week selection from current state: ${state.runtimeType}',
      );
      emit(
        const SubscriptionPlanningError(
          'Invalid state for starting week selection',
        ),
      );
      return;
    }

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
        weekCache: {},
        selections: [],
      );

      emit(weekSelectionState);

      // Load first week data
      await _loadWeekData(1);
    } catch (e) {
      _logger.e('Error starting week selection', error: e);
      emit(SubscriptionPlanningError('Failed to start meal selection: $e'));
    }
  }

  /// Load week data using service
  Future<void> _loadWeekData(int week) async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    try {
      _logger.i('Loading week $week data');

      // Get week data from service (handles caching automatically)
      final result = await _weekDataService.getWeekData(
        week: week,
        startDate: currentState.startDate,
        dietaryPreference: currentState.dietaryPreference,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to load week $week: ${failure.message}');
          emit(
            SubscriptionPlanningError(
              failure.message ?? 'Failed to load week data',
            ),
          );
        },
        (weekCache) {
          _logger.d('Week $week data loaded, updating state');

          // Update week cache in state
          final updatedWeekCache = Map<int, WeekCache>.from(
            currentState.weekCache,
          );
          updatedWeekCache[week] = weekCache;

          emit(currentState.copyWith(weekCache: updatedWeekCache));
        },
      );
    } catch (e) {
      _logger.e('Unexpected error loading week $week', error: e);
      emit(const SubscriptionPlanningError('An unexpected error occurred'));
    }
  }

  /// Navigate to specific week
  Future<void> navigateToWeek(int week) async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    if (week < 1 || week > currentState.duration) {
      _logger.w('Invalid week number: $week');
      return;
    }

    _logger.i('Navigating to week $week');

    // Update current week
    emit(currentState.copyWith(currentWeek: week));

    // Load week data if not already loaded/loading
    final weekCache = currentState.weekCache[week];
    if (weekCache == null || (!weekCache.isLoaded && !weekCache.isLoading)) {
      await _loadWeekData(week);
    }
  }

  /// Toggle meal selection - SIMPLIFIED!
  void toggleMealSelection({
    required int week,
    required MealOption mealOption,
  }) {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    // Create selection ID for this meal option
    final selectionId = '${week}_${mealOption.id}';

    // Check if already selected
    final existingSelection =
        currentState.selections.where((s) => s.id == selectionId).firstOrNull;

    List<MealSelection> updatedSelections;

    if (existingSelection != null) {
      // Remove selection
      updatedSelections =
          currentState.selections.where((s) => s.id != selectionId).toList();
      _logger.d('Removed meal selection: $selectionId');
    } else {
      // Check if can add more selections for this week
      if (!currentState.canSelectMore(week)) {
        _logger.w(
          'Cannot select more meals for week $week (limit: ${currentState.mealPlan})',
        );
        emit(
          SubscriptionPlanningError(
            'Cannot select more than ${currentState.mealPlan} meals for week $week',
          ),
        );
        return;
      }

      // Add selection
      final newSelection = MealSelection.fromMealOption(
        week: week,
        mealOption: mealOption,
      );

      updatedSelections = [...currentState.selections, newSelection];
      _logger.d('Added meal selection: $selectionId');
    }

    // Update state with new selections
    emit(currentState.copyWith(selections: updatedSelections));

    _logger.i(
      'Week $week now has ${currentState.getSelectedMealCount(week)} meals selected',
    );
  }

  /// Go to next week
  Future<void> nextWeek() async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

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
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    if (currentState.currentWeek > 1) {
      await navigateToWeek(currentState.currentWeek - 1);
    }
  }

  /// Complete planning and move to summary
  void _completePlanning() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    if (!currentState.allWeeksValid) {
      emit(
        const SubscriptionPlanningError(
          'Please complete all weeks before proceeding',
        ),
      );
      return;
    }

    _logger.i('Planning completed successfully');

    emit(
      PlanningComplete(
        startDate: currentState.startDate,
        dietaryPreference: currentState.dietaryPreference,
        duration: currentState.duration,
        mealPlan: currentState.mealPlan,
        weekCache: currentState.weekCache,
        selections: currentState.selections,
      ),
    );
  }

  /// Go to checkout
  void goToCheckout() {
    final currentState = state;
    if (currentState is! PlanningComplete) return;

    if (!currentState.isValidForSubscription) {
      emit(
        const SubscriptionPlanningError(
          'Planning is not complete. Please ensure all weeks have the correct number of meals.',
        ),
      );
      return;
    }

    emit(CheckoutActive(planningData: currentState));
    _logger.i('Moved to checkout step');
  }

  /// Update checkout data
  void updateCheckoutData({
    String? addressId,
    String? instructions,
    int? noOfPersons,
  }) {
    final currentState = state;
    if (currentState is! CheckoutActive) return;

    emit(
      currentState.copyWith(
        selectedAddressId: addressId,
        instructions: instructions,
        noOfPersons: noOfPersons,
      ),
    );
  }

  /// Create subscription (final API call)
  Future<void> createSubscription() async {
    final currentState = state;
    if (currentState is! CheckoutActive) return;

    if (!currentState.canSubmit) {
      emit(
        const SubscriptionPlanningError('Please complete all required fields'),
      );
      return;
    }

    try {
      // Set submitting state
      emit(currentState.copyWith(isSubmitting: true));

      // Build subscription request
      final request = currentState.planningData.buildSubscriptionRequest(
        addressId: currentState.selectedAddressId!,
        instructions: currentState.instructions,
        noOfPersons: currentState.noOfPersons,
      );

      // Validate request
      final validation = SubscriptionService.validateRequest(request);
      validation.fold((error) {
        _logger.e('Subscription request validation failed: $error');
        emit(SubscriptionPlanningError(error));
        return;
      }, (_) => _logger.d('Subscription request validation passed'));

      _logger.i('Creating subscription with ${request.weeks.length} weeks');

      // Make API call
      final result = await _subscriptionService.createSubscription(
        request: request,
      );

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
          // State will be handled by navigation - cubit job is done!
          emit(currentState.copyWith(isSubmitting: false));
        },
      );
    } catch (e) {
      _logger.e('Unexpected error creating subscription', error: e);
      emit(const SubscriptionPlanningError('An unexpected error occurred'));
    }
  }

  /// Reset to initial state
  void reset() {
    _logger.i('Resetting subscription planning');
    _weekDataService.clearCache();
    emit(SubscriptionPlanningInitial());
  }

  /// Reset to planning form (for back navigation)
  void resetToPlanning() {
    final currentState = state;

    if (currentState is WeekSelectionActive) {
      emit(
        PlanningFormActive(
          startDate: currentState.startDate,
          dietaryPreference: currentState.dietaryPreference,
          duration: currentState.duration,
          mealPlan: currentState.mealPlan,
        ),
      );
      _logger.i('Reset to planning form from week selection');
    } else if (currentState is PlanningComplete) {
      emit(
        PlanningFormActive(
          startDate: currentState.startDate,
          dietaryPreference: currentState.dietaryPreference,
          duration: currentState.duration,
          mealPlan: currentState.mealPlan,
        ),
      );
      _logger.i('Reset to planning form from summary');
    }
  }

  /// Retry loading current week data
  Future<void> retryLoadWeek() async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    await _loadWeekData(currentState.currentWeek);
  }

  /// Get meal options for current week (helper for UI)
  List<MealOption> getCurrentWeekMealOptions() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return [];

    final weekCache = currentState.getCurrentWeekCache();
    if (weekCache?.calculatedPlan == null) return [];

    return _weekDataService.extractMealOptions(weekCache!.calculatedPlan!);
  }

  /// Check if meal option is selected (helper for UI)
  bool isMealOptionSelected(String mealOptionId, int week) {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return false;

    return currentState.isMealSelected(mealOptionId, week);
  }
}
