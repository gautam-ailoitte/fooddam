// lib/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/entities/dish_selection.dart';
import 'package:foodam/src/domain/entities/meal_plan_item.dart';
import 'package:foodam/src/domain/services/subscription_service.dart';
import 'package:foodam/src/domain/services/week_data_service.dart';
import 'package:foodam/src/presentation/cubits/subscription/planning/subscription_planning_state.dart';

/// Enhanced subscription planning cubit with selection management
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

  // ==========================================
  // PLANNING FORM MANAGEMENT
  // ==========================================

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

  /// Reset to planning form from any state
  void resetToPlanning() {
    if (state is WeekSelectionActive) {
      final weekState = state as WeekSelectionActive;
      emit(
        PlanningFormActive(
          startDate: weekState.startDate,
          dietaryPreference: weekState.dietaryPreference,
          duration: weekState.duration,
          mealPlan: weekState.mealPlan,
        ),
      );
    } else if (state is PlanningComplete) {
      final completeState = state as PlanningComplete;
      emit(
        PlanningFormActive(
          startDate: completeState.startDate,
          dietaryPreference: completeState.dietaryPreference,
          duration: completeState.duration,
          mealPlan: completeState.mealPlan,
        ),
      );
    } else {
      emit(const PlanningFormActive());
    }
    _logger.i('Reset to planning form');
  }

  // ==========================================
  // WEEK SELECTION FLOW
  // ==========================================

  /// Start week selection flow
  Future<void> startWeekSelection() async {
    final currentState = state;

    // Extract form data from current state
    PlanningFormActive? formState;
    if (currentState is PlanningFormActive) {
      formState = currentState;
    } else if (currentState is WeekSelectionActive) {
      final weekState = currentState as WeekSelectionActive;
      formState = PlanningFormActive(
        startDate: weekState.startDate,
        dietaryPreference: weekState.dietaryPreference,
        duration: weekState.duration,
        mealPlan: weekState.mealPlan,
      );
    } else {
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
      emit(const SubscriptionPlanningLoading('Setting up meal selection...'));

      // Initialize week selection state with empty selections
      final weekSelectionState = WeekSelectionActive(
        startDate: formState.startDate!,
        dietaryPreference: formState.dietaryPreference!,
        duration: formState.duration!,
        mealPlan: formState.mealPlan!,
        currentWeek: 1,
        weekDataStatus: {},
        weekSelections: {}, // Empty initially
        weekPackageIds: {}, // Empty initially
      );

      emit(weekSelectionState);

      // Load first week data
      await _loadWeekData(1);
    } catch (e) {
      _logger.e('Error starting week selection', error: e);
      emit(SubscriptionPlanningError('Failed to start meal selection: $e'));
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
    final updatedState = currentState.copyWith(currentWeek: week);
    emit(updatedState);

    // Load week data if not already loaded/loading
    final weekStatus = currentState.weekDataStatus[week];
    if (weekStatus == null || (!weekStatus.isLoaded && !weekStatus.isLoading)) {
      await _loadWeekData(week);
    }
  }

  /// Go to next week
  Future<void> nextWeek() async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    if (currentState.currentWeek < currentState.duration) {
      await navigateToWeek(currentState.currentWeek + 1);
    } else {
      // All weeks completed, go to summary
      _goToSummary();
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

  /// Retry loading current week data
  Future<void> retryLoadWeek() async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    await _loadWeekData(currentState.currentWeek);
  }

  // ==========================================
  // 🔥 SELECTION MANAGEMENT (NEW)
  // ==========================================

  /// Toggle dish selection for current week
  void toggleDishSelection({
    required MealPlanItem item,
    required String packageId,
  }) {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    _logger.d(
      '🔄 Toggling selection for ${item.dishName} on ${item.day} ${item.timing}',
    );
    _logger.d(
      '📊 BEFORE: Week ${currentState.currentWeek} has ${currentState.currentWeekSelectionCount} selections',
    );

    final week = currentState.currentWeek;

    // 🔥 FIXED: Create completely NEW Map instances
    final newSelections = <int, List<DishSelection>>{};
    final newPackageIds = <int, String>{};

    // Deep copy ALL existing data to new Maps
    currentState.weekSelections.forEach((key, value) {
      newSelections[key] = List<DishSelection>.from(value);
    });
    currentState.weekPackageIds.forEach((key, value) {
      newPackageIds[key] = value;
    });

    // Store package ID for this week
    newPackageIds[week] = packageId;

    // Initialize week selections if needed
    newSelections[week] ??= <DishSelection>[];

    // Calculate the actual date for this selection
    final selectionDate = item.calculateDate(currentState.startDate, week);

    // Create selection object
    final selection = DishSelection.fromMealPlanItem(
      week: week,
      item: item,
      date: selectionDate,
      packageId: packageId,
    );

    final weekSelections = newSelections[week]!;

    // Check if already selected (exact match with day)
    final existingIndex = weekSelections.indexWhere(
      (s) =>
          s.dishId == selection.dishId &&
          s.day.toLowerCase() == selection.day.toLowerCase() &&
          s.timing.toLowerCase() == selection.timing.toLowerCase(),
    );

    if (existingIndex != -1) {
      // Remove selection
      weekSelections.removeAt(existingIndex);
      _logger.d('➖ Removed selection: ${selection.dishName}');
    } else {
      // Check if can add more
      if (weekSelections.length >= currentState.mealPlan) {
        _logger.w(
          '🚫 Cannot add more selections for week $week (${weekSelections.length}/${currentState.mealPlan})',
        );
        return;
      }

      // Add selection
      weekSelections.add(selection);
      _logger.d('➕ Added selection: ${selection.dishName}');
    }

    _logger.d(
      '📊 AFTER: Week $week will have ${weekSelections.length} selections',
    );

    // 🔥 CRITICAL: Emit state with NEW Map instances (different references)
    final newState = WeekSelectionActive(
      startDate: currentState.startDate,
      dietaryPreference: currentState.dietaryPreference,
      duration: currentState.duration,
      mealPlan: currentState.mealPlan,
      currentWeek: currentState.currentWeek,
      weekDataStatus: currentState.weekDataStatus,
      weekSelections: newSelections, // NEW Map instance
      weekPackageIds: newPackageIds, // NEW Map instance
    );

    emit(newState);

    // 🔍 DEBUG: Verify state change
    final verifyState = state as WeekSelectionActive;
    _logger.d(
      '✅ State emitted. Verified count: ${verifyState.currentWeekSelectionCount}',
    );
  }

  /// Check if a specific dish is selected
  bool isDishSelected(String dishId, String day, String timing) {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return false;

    return currentState.isDishSelected(dishId, day, timing);
  }

  /// Get selection count for current week
  int getCurrentWeekSelectionCount() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return 0;

    return currentState.currentWeekSelectionCount;
  }

  /// Check if current week is complete
  bool isCurrentWeekComplete() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return false;

    return currentState.isCurrentWeekComplete;
  }

  /// Check if can select more for current week
  bool canSelectMoreForCurrentWeek() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return false;

    return currentState.canSelectMore;
  }

  // ==========================================
  // SUMMARY & CHECKOUT
  // ==========================================

  /// Go to planning summary
  void _goToSummary() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    _logger.i('Planning completed, going to summary');

    final summaryState = PlanningComplete(
      startDate: currentState.startDate,
      dietaryPreference: currentState.dietaryPreference,
      duration: currentState.duration,
      mealPlan: currentState.mealPlan,
      weekSelections: currentState.weekSelections,
      weekPackageIds: currentState.weekPackageIds,
    );

    emit(summaryState);
  }

  /// Go to checkout
  void goToCheckout() {
    final currentState = state;
    if (currentState is! PlanningComplete) return;

    emit(
      CheckoutActive(
        startDate: currentState.startDate,
        dietaryPreference: currentState.dietaryPreference,
        duration: currentState.duration,
        mealPlan: currentState.mealPlan,
        weekSelections: currentState.weekSelections,
        weekPackageIds: currentState.weekPackageIds,
      ),
    );
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

  /// Create subscription
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

      _logger.i('Creating subscription...');

      // Build subscription request from cubit state
      final subscriptionRequest = _buildSubscriptionRequest(currentState);

      // Create subscription via service
      final result = await _subscriptionService.createSubscription(
        request: subscriptionRequest,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to create subscription: ${failure.message}');
          emit(
            SubscriptionPlanningError(
              failure.message ?? 'Failed to create subscription',
            ),
          );
        },
        (subscription) {
          _logger.i('Subscription created successfully: ${subscription.id}');
          emit(currentState.copyWith(isSubmitting: false));
          // TODO: Navigate to success screen or emit success state
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
    emit(SubscriptionPlanningInitial());
  }

  // ==========================================
  // MEAL PLAN DATA ACCESS
  // ==========================================

  /// Get meal plan items for current week
  List<MealPlanItem> getCurrentWeekMealPlanItems() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return [];

    final weekPlan = currentState.currentWeekPlan;
    if (weekPlan == null) return [];

    return _extractMealPlanItems(weekPlan);
  }

  /// Get meal plan items filtered by meal type for current week
  List<MealPlanItem> getCurrentWeekMealPlanItemsByType(String mealType) {
    final allItems = getCurrentWeekMealPlanItems();
    return allItems
        .where((item) => item.timing.toLowerCase() == mealType.toLowerCase())
        .toList();
  }

  // ==========================================
  // PRIVATE HELPERS
  // ==========================================

  /// Load week data from service
  Future<void> _loadWeekData(int week) async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    try {
      _logger.i('Loading week $week data');

      // Update status to loading
      final loadingStatus = Map<int, WeekDataStatus>.from(
        currentState.weekDataStatus,
      );
      loadingStatus[week] = WeekDataStatus.loading(week);

      emit(currentState.copyWith(weekDataStatus: loadingStatus));

      // Get week data from service
      final result = await _weekDataService.getWeekData(
        week: week,
        startDate: currentState.startDate,
        dietaryPreference: currentState.dietaryPreference,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to load week $week: ${failure.message}');

          // Update status to error
          final errorStatus = Map<int, WeekDataStatus>.from(
            currentState.weekDataStatus,
          );
          errorStatus[week] = WeekDataStatus.error(
            week: week,
            errorMessage: failure.message ?? 'Failed to load week data',
          );

          if (!isClosed) {
            emit(currentState.copyWith(weekDataStatus: errorStatus));
          }
        },
        (weekCache) {
          _logger.d('Week $week data loaded successfully');

          // Extract package ID from calculated plan
          String? packageId;
          if (weekCache.calculatedPlan?.package != null) {
            packageId = weekCache.calculatedPlan!.package!.id;
          }

          // Update status to loaded
          final loadedStatus = Map<int, WeekDataStatus>.from(
            currentState.weekDataStatus,
          );
          loadedStatus[week] = WeekDataStatus.loaded(
            week: week,
            calculatedPlan: weekCache.calculatedPlan!,
            packageId: packageId ?? '',
          );

          if (!isClosed) {
            emit(currentState.copyWith(weekDataStatus: loadedStatus));
          }
        },
      );
    } catch (e) {
      _logger.e('Unexpected error loading week $week', error: e);

      // Update status to error
      final errorStatus = Map<int, WeekDataStatus>.from(
        currentState.weekDataStatus,
      );
      errorStatus[week] = WeekDataStatus.error(
        week: week,
        errorMessage: 'An unexpected error occurred',
      );

      if (!isClosed) {
        emit(currentState.copyWith(weekDataStatus: errorStatus));
      }
    }
  }

  /// Extract meal plan items from calculated plan
  List<MealPlanItem> _extractMealPlanItems(CalculatedPlan calculatedPlan) {
    final items = <MealPlanItem>[];

    for (final dailyMeal in calculatedPlan.dailyMeals) {
      final dayMeal = dailyMeal.slot.meal;
      if (dayMeal == null) continue;

      final dayName = dailyMeal.slot.day;

      // Extract items for each meal type from the day meal
      dayMeal.dishes.forEach((mealType, dish) {
        final item = MealPlanItem.fromDish(
          dish: dish,
          day: dayName,
          timing: mealType,
        );
        items.add(item);
      });
    }

    return items;
  }

  /// Build subscription request from checkout state
  SubscriptionRequest _buildSubscriptionRequest(CheckoutActive state) {
    // Convert selections to subscription format
    final weeks = <WeekSubscriptionData>[];

    for (int week = 1; week <= state.duration; week++) {
      final weekSelections = state.weekSelections[week] ?? [];
      final packageId = state.weekPackageIds[week];

      if (weekSelections.isNotEmpty && packageId != null) {
        final slots =
            weekSelections
                .map(
                  (selection) => SubscriptionSlotData(
                    dayName: selection.day,
                    date: selection.date,
                    mealType: selection.timing,
                    dishId: selection.dishId,
                  ),
                )
                .toList();

        weeks.add(
          WeekSubscriptionData(week: week, packageId: packageId, slots: slots),
        );
      }
    }

    return SubscriptionRequest(
      startDate: state.startDate,
      endDate: state.calculatedEndDate,
      durationDays: state.duration * 7,
      addressId: state.selectedAddressId!,
      instructions: state.instructions,
      noOfPersons: state.noOfPersons,
      weeks: weeks,
    );
  }
}
