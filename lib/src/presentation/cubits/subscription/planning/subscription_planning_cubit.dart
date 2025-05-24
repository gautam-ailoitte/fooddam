// lib/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/services/subscription_service.dart';
import 'package:foodam/src/domain/services/week_data_service.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_state.dart';

class SubscriptionPlanningCubit extends Cubit<SubscriptionPlanningState> {
  final WeekDataService _weekDataService;
  final SubscriptionService _subscriptionService;
  final LoggerService _logger = LoggerService();

  // Enhanced state caching with metadata
  _StateCache? _cachedWeekSelection;
  _StateCache? _cachedPlanningComplete;

  // Navigation context preservation
  int? _lastActiveTab;
  double? _lastScrollPosition;

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

  /// Update form data with intelligent cache clearing
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
            dietaryPreference != currentState.dietaryPreference) ||
        (duration != null && duration != currentState.duration) ||
        (mealPlan != null && mealPlan != currentState.mealPlan);

    if (shouldClearCache) {
      _logger.i('Form data changed, clearing all caches');
      _weekDataService.clearCache();
      _clearStateCache();
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

  /// Start week selection flow with cache recovery
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
    } else if (state is PlanningComplete) {
      // Coming from summary - convert back to form state
      final completeState = state as PlanningComplete;
      formState = PlanningFormActive(
        startDate: completeState.startDate,
        dietaryPreference: completeState.dietaryPreference,
        duration: completeState.duration,
        mealPlan: completeState.mealPlan,
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

      // Try to restore from validated cache first
      if (_cachedWeekSelection != null &&
          _isValidCachedWeekSelection(formState, _cachedWeekSelection!)) {
        _logger.i('Restoring week selection state from validated cache');

        // Small delay for smooth UX
        await Future.delayed(const Duration(milliseconds: 150));

        emit(_cachedWeekSelection!.state as WeekSelectionActive);
        return;
      }

      // Initialize new week selection state
      final weekSelectionState = WeekSelectionActive(
        startDate: formState.startDate!,
        dietaryPreference: formState.dietaryPreference!,
        duration: formState.duration!,
        mealPlan: formState.mealPlan!,
        currentWeek: 1,
        weekCache: {},
        selections: [],
      );

      // Cache the state
      _cacheWeekSelectionState(weekSelectionState);
      emit(weekSelectionState);

      // Load first week data
      await _loadWeekData(1);
    } catch (e) {
      _logger.e('Error starting week selection', error: e);
      emit(SubscriptionPlanningError('Failed to start meal selection: $e'));
    }
  }

  /// Enhanced resume week selection with validation
  Future<void> resumeWeekSelection() async {
    final currentState = state;

    _logger.i(
      'Resuming week selection from state: ${currentState.runtimeType}',
    );

    try {
      emit(SubscriptionPlanningLoading());

      // Validate and restore cached week selection state
      if (_cachedWeekSelection != null) {
        final cachedState = _cachedWeekSelection!.state as WeekSelectionActive;

        // Validate cached state
        if (_isValidWeekSelectionState(cachedState)) {
          _logger.i('Restoring validated week selection state');

          // Small delay for smooth transition
          await Future.delayed(const Duration(milliseconds: 150));

          emit(cachedState);
          return;
        } else {
          _logger.w('Cached week selection state is invalid, clearing cache');
          _clearWeekSelectionCache();
        }
      }

      // Fallback: reconstruct from current state
      if (currentState is PlanningComplete) {
        _logger.i('Reconstructing week selection from planning complete state');

        final weekSelectionState = WeekSelectionActive(
          startDate: currentState.startDate,
          dietaryPreference: currentState.dietaryPreference,
          duration: currentState.duration,
          mealPlan: currentState.mealPlan,
          currentWeek: _lastActiveTab != null ? _lastActiveTab! : 1,
          weekCache: currentState.weekCache,
          selections: currentState.selections,
        );

        _cacheWeekSelectionState(weekSelectionState);
        emit(weekSelectionState);
        return;
      }

      // Last resort: redirect to start
      _logger.w('Cannot resume week selection, redirecting to start');
      emit(
        const SubscriptionPlanningError(
          'Unable to resume meal selection. Redirecting to start.',
        ),
      );

      // Auto-redirect after showing error
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
          reset();
        }
      });
    } catch (e) {
      _logger.e('Error resuming week selection', error: e);
      emit(
        const SubscriptionPlanningError(
          'Failed to resume meal selection. Please start over.',
        ),
      );
    }
  }

  /// Load week data with enhanced error handling
  Future<void> _loadWeekData(int week) async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    try {
      _logger.i('Loading week $week data');

      // Update cache to loading state first
      final loadingCache = Map<int, WeekCache>.from(currentState.weekCache);
      loadingCache[week] = WeekCache.loading(week: week);

      final updatedState = currentState.copyWith(weekCache: loadingCache);
      _cacheWeekSelectionState(updatedState);
      emit(updatedState);

      // Get week data from service
      final result = await _weekDataService.getWeekData(
        week: week,
        startDate: currentState.startDate,
        dietaryPreference: currentState.dietaryPreference,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to load week $week: ${failure.message}');

          // Update cache with error state
          final errorCache = Map<int, WeekCache>.from(currentState.weekCache);
          errorCache[week] = WeekCache.error(
            week: week,
            errorMessage: failure.message ?? 'Failed to load week data',
          );

          final errorState = currentState.copyWith(weekCache: errorCache);
          _cacheWeekSelectionState(errorState);
          emit(errorState);
        },
        (weekCache) {
          _logger.d('Week $week data loaded successfully');

          // Update week cache in state
          final updatedWeekCache = Map<int, WeekCache>.from(
            currentState.weekCache,
          );
          updatedWeekCache[week] = weekCache;

          final successState = currentState.copyWith(
            weekCache: updatedWeekCache,
          );
          _cacheWeekSelectionState(successState);
          emit(successState);
        },
      );
    } catch (e) {
      _logger.e('Unexpected error loading week $week', error: e);

      final errorCache = Map<int, WeekCache>.from(currentState.weekCache);
      errorCache[week] = WeekCache.error(
        week: week,
        errorMessage: 'An unexpected error occurred',
      );

      final errorState = currentState.copyWith(weekCache: errorCache);
      _cacheWeekSelectionState(errorState);
      emit(errorState);
    }
  }

  /// Navigate to specific week with context preservation
  Future<void> navigateToWeek(int week) async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    if (week < 1 || week > currentState.duration) {
      _logger.w('Invalid week number: $week');
      return;
    }

    _logger.i('Navigating to week $week');

    // Update current week
    final updatedState = currentState.copyWith(currentWeek: week);
    _cacheWeekSelectionState(updatedState);
    emit(updatedState);

    // Load week data if not already loaded/loading
    final weekCache = currentState.weekCache[week];
    if (weekCache == null || (!weekCache.isLoaded && !weekCache.isLoading)) {
      await _loadWeekData(week);
    }
  }

  /// Toggle meal selection with optimizations
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
    final updatedState = currentState.copyWith(selections: updatedSelections);
    _cacheWeekSelectionState(updatedState);
    emit(updatedState);

    _logger.i(
      'Week $week now has ${updatedSelections.where((s) => s.week == week).length} meals selected',
    );
  }

  /// Go to next week with validation
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

  /// Complete planning and move to summary with caching
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

    final planningCompleteState = PlanningComplete(
      startDate: currentState.startDate,
      dietaryPreference: currentState.dietaryPreference,
      duration: currentState.duration,
      mealPlan: currentState.mealPlan,
      weekCache: currentState.weekCache,
      selections: currentState.selections,
    );

    // Cache both states for smooth navigation
    _cachePlanningCompleteState(planningCompleteState);
    _cacheWeekSelectionState(
      currentState,
    ); // Keep week selection for back navigation

    emit(planningCompleteState);
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

  /// Create subscription with cache cleanup
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

          // Clear all caches after successful creation
          _clearAllCaches();

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
    _clearAllCaches();
    emit(SubscriptionPlanningInitial());
  }

  /// Reset to planning form
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

  /// Get meal options for current week
  List<MealOption> getCurrentWeekMealOptions() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return [];

    final weekCache = currentState.getCurrentWeekCache();
    if (weekCache?.calculatedPlan == null) return [];

    return _weekDataService.extractMealOptions(weekCache!.calculatedPlan!);
  }

  /// Check if meal option is selected
  bool isMealOptionSelected(String mealOptionId, int week) {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return false;

    return currentState.isMealSelected(mealOptionId, week);
  }

  /// Store navigation context for preservation
  void storeNavigationContext({int? activeTab, double? scrollPosition}) {
    if (activeTab != null) _lastActiveTab = activeTab;
    if (scrollPosition != null) _lastScrollPosition = scrollPosition;
    _logger.d(
      'Stored navigation context: tab=$activeTab, scroll=$scrollPosition',
    );
  }

  /// Get stored navigation context
  Map<String, dynamic> getNavigationContext() {
    return {
      'activeTab': _lastActiveTab ?? 0,
      'scrollPosition': _lastScrollPosition ?? 0.0,
    };
  }

  // ========================================
  // PRIVATE HELPER METHODS
  // ========================================

  /// Cache week selection state with metadata
  void _cacheWeekSelectionState(WeekSelectionActive state) {
    _cachedWeekSelection = _StateCache(
      state: state,
      timestamp: DateTime.now(),
      metadata: {
        'startDate': state.startDate.toIso8601String(),
        'dietaryPreference': state.dietaryPreference,
        'duration': state.duration,
        'mealPlan': state.mealPlan,
      },
    );
    _logger.d('Cached week selection state');
  }

  /// Cache planning complete state
  void _cachePlanningCompleteState(PlanningComplete state) {
    _cachedPlanningComplete = _StateCache(
      state: state,
      timestamp: DateTime.now(),
      metadata: {
        'startDate': state.startDate.toIso8601String(),
        'dietaryPreference': state.dietaryPreference,
        'totalSelections': state.selections.length,
      },
    );
    _logger.d('Cached planning complete state');
  }

  /// Validate cached week selection state
  bool _isValidCachedWeekSelection(
    PlanningFormActive formState,
    _StateCache cachedState,
  ) {
    // Check if cache is too old (1 hour limit)
    if (DateTime.now().difference(cachedState.timestamp).inHours > 1) {
      _logger.w('Cached state is too old, invalidating');
      return false;
    }

    // Check if form data matches cached metadata
    final metadata = cachedState.metadata;
    if (metadata['startDate'] != formState.startDate?.toIso8601String() ||
        metadata['dietaryPreference'] != formState.dietaryPreference ||
        metadata['duration'] != formState.duration ||
        metadata['mealPlan'] != formState.mealPlan) {
      _logger.w('Form data mismatch with cached state');
      return false;
    }

    return true;
  }

  /// Validate week selection state integrity
  bool _isValidWeekSelectionState(WeekSelectionActive state) {
    try {
      // Check basic state integrity
      if (state.duration <= 0 || state.mealPlan <= 0) return false;
      if (state.currentWeek < 1 || state.currentWeek > state.duration)
        return false;
      if (state.startDate.isAfter(
        DateTime.now().add(const Duration(days: 365)),
      ))
        return false;

      // Check selections integrity
      for (final selection in state.selections) {
        if (selection.week < 1 || selection.week > state.duration) return false;
      }

      // Check week cache integrity
      for (final entry in state.weekCache.entries) {
        final week = entry.key;
        if (week < 1 || week > state.duration) return false;
      }

      return true;
    } catch (e) {
      _logger.e('Error validating week selection state', error: e);
      return false;
    }
  }

  /// Clear week selection cache
  void _clearWeekSelectionCache() {
    _cachedWeekSelection = null;
    _logger.d('Cleared week selection cache');
  }

  /// Clear planning complete cache
  void _clearPlanningCompleteCache() {
    _cachedPlanningComplete = null;
    _logger.d('Cleared planning complete cache');
  }

  /// Clear state cache
  void _clearStateCache() {
    _clearWeekSelectionCache();
    _clearPlanningCompleteCache();
    _lastActiveTab = null;
    _lastScrollPosition = null;
    _logger.d('Cleared all state cache');
  }

  /// Clear all caches including service cache
  void _clearAllCaches() {
    _weekDataService.clearCache();
    _clearStateCache();
    _logger.i('Cleared all caches');
  }
}

/// Internal cache structure with metadata
class _StateCache {
  final SubscriptionPlanningState state;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  _StateCache({
    required this.state,
    required this.timestamp,
    required this.metadata,
  });
}
