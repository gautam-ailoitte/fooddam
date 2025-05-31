// lib/src/presentation/cubits/week_selection/week_selection_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/entities/meal_plan_item.dart';
import 'package:foodam/src/domain/usecase/calendar_usecase.dart';
import 'package:foodam/src/presentation/cubits/subscription/week_selection/week_selection_state.dart';

class WeekSelectionCubit extends Cubit<WeekSelectionState> {
  final CalendarUseCase _calendarUseCase;
  final LoggerService _logger = LoggerService();

  // Debouncing to prevent UI collision issues
  bool _isProcessingSelection = false;
  static const _selectionDebounceMs = 300;

  WeekSelectionCubit({required CalendarUseCase calendarUseCase})
    : _calendarUseCase = calendarUseCase,
      super(const WeekSelectionInitial());

  // ===============================================================
  // INITIALIZATION & WEEK CONFIGURATION
  // ===============================================================

  /// Initialize week selection with planning data from form
  /// Automatically configure and load Week 1
  Future<void> initializeWeekSelection(PlanningFormData planningData) async {
    try {
      _logger.i('Initializing week selection with planning data');

      // Start with Week 1 configuration using default dietary preference
      final weekConfig = WeekConfig(
        week: 1,
        dietaryPreference: planningData.dietaryPreference,
        mealPlan: 15, // Default meal plan, user can change
        isComplete: false,
      );

      // Initial state with Week 1 configured
      final initialState = WeekSelectionActive(
        planningData: planningData,
        currentWeek: 1,
        maxWeeksConfigured: 1,
        weekConfigs: {1: weekConfig},
        weekDataCache: {},
        selections: {},
      );

      emit(initialState);

      // Auto-load Week 1 data
      await _loadWeekData(1, weekConfig.dietaryPreference, weekConfig.mealPlan);
    } catch (e) {
      _logger.e('Error initializing week selection', error: e);
      // UI will handle null data case with empty screen
    }
  }

  /// Configure new week with dietary preference and meal plan
  /// Called when user adds a new week via bottom sheet
  Future<void> configureWeek({
    required int week,
    required String dietaryPreference,
    required int mealPlan,
  }) async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    try {
      _logger.i(
        'Configuring week $week with $mealPlan meals ($dietaryPreference)',
      );

      // Create new week configuration
      final weekConfig = WeekConfig(
        week: week,
        dietaryPreference: dietaryPreference,
        mealPlan: mealPlan,
        isComplete: false,
      );

      // Update state with new configuration
      final updatedConfigs = Map<int, WeekConfig>.from(
        currentState.weekConfigs,
      );
      updatedConfigs[week] = weekConfig;

      final updatedState = currentState.copyWith(
        weekConfigs: updatedConfigs,
        maxWeeksConfigured:
            week > currentState.maxWeeksConfigured
                ? week
                : currentState.maxWeeksConfigured,
        currentWeek: week,
      );

      emit(updatedState);

      // Load week data
      await _loadWeekData(week, dietaryPreference, mealPlan);
    } catch (e) {
      _logger.e('Error configuring week $week', error: e);
      // UI will handle null data case
    }
  }

  // ===============================================================
  // WEEK DATA LOADING & API INTEGRATION
  // ===============================================================

  /// Load week data from API with proper error handling
  /// Fixed API call to use constant startDate as specified
  Future<void> _loadWeekData(
    int week,
    String dietaryPreference,
    int mealPlan,
  ) async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    try {
      _logger.i('Loading data for week $week ($dietaryPreference)');

      // Set null in cache to indicate loading (UI handles this with empty screen)
      final updatedCache = Map<int, WeekData?>.from(currentState.weekDataCache);
      updatedCache[week] = null;
      emit(currentState.copyWith(weekDataCache: updatedCache));

      // API call with FIXED startDate (as specified in requirements)
      // Only week and dietaryPreference change, startDate remains constant
      final result = await _calendarUseCase.getCalculatedPlan(
        dietaryPreference: dietaryPreference,
        week: week,
        startDate: currentState.planningData.startDate,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to load week $week data: ${failure.message}');
          // Keep null in cache - UI will show empty state
        },
        (calculatedPlan) async {
          _logger.d('Successfully loaded week $week data');

          // Extract meal plan items from calculated plan
          final availableMeals = _extractMealPlanItems(calculatedPlan);
          final packageId = calculatedPlan.package?.id ?? '';
          final priceOptions = calculatedPlan.package?.priceOptions ?? [];

          // Validate API response has enough meals
          if (availableMeals.length < mealPlan) {
            _logger.w(
              'API returned ${availableMeals.length} meals but user selected $mealPlan meal plan',
            );
            // Keep null in cache - UI will show error state
            return;
          }

          // Store loaded data
          final loadedCache = Map<int, WeekData?>.from(
            currentState.weekDataCache,
          );
          loadedCache[week] = WeekData.loaded(
            calculatedPlan: calculatedPlan,
            availableMeals: availableMeals,
            packageId: packageId,
            priceOptions: priceOptions,
          );

          final loadedState = currentState.copyWith(weekDataCache: loadedCache);
          emit(loadedState);

          // Auto-select all meals for 21-meal plan
          if (mealPlan == 21) {
            await _autoSelectAllMeals(week, availableMeals, packageId);
          }
        },
      );
    } catch (e) {
      _logger.e('Unexpected error loading week $week data', error: e);
      // Keep null in cache - UI will show error state
    }
  }

  /// Extract MealPlanItem list from CalculatedPlan
  /// Flattens the nested structure for easier UI consumption
  List<MealPlanItem> _extractMealPlanItems(CalculatedPlan calculatedPlan) {
    final items = <MealPlanItem>[];

    for (final dailyMeal in calculatedPlan.dailyMeals) {
      final dayMeal = dailyMeal.slot.meal;
      if (dayMeal == null) continue;

      final dayName = dailyMeal.slot.day;

      // Extract items for each meal type (breakfast, lunch, dinner)
      dayMeal.dishes.forEach((mealType, dish) {
        if (dish.isAvailable) {
          final item = MealPlanItem.fromDish(
            dish: dish,
            day: dayName,
            timing: mealType,
          );
          items.add(item);
        }
      });
    }

    _logger.d('Extracted ${items.length} meal plan items');
    return items;
  }

  /// Auto-select all meals for 21-meal plan
  Future<void> _autoSelectAllMeals(
    int week,
    List<MealPlanItem> meals,
    String packageId,
  ) async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    _logger.i(
      'Auto-selecting all ${meals.length} meals for week $week (21-meal plan)',
    );

    final newSelections = Map<String, DishSelection>.from(
      currentState.selections,
    );

    for (final meal in meals) {
      final key = DishSelection.generateKey(
        week,
        meal.dishId,
        meal.day,
        meal.timing,
      );

      // Use date from meal plan item (calculated from API response)
      final date = meal.calculateDate(
        currentState.planningData.startDate,
        week,
      );

      final selection = DishSelection.fromMealPlanItem(
        week: week,
        item: meal,
        date: date,
        packageId: packageId,
      );

      newSelections[key] = selection;
    }

    // Update week config to complete
    final updatedConfigs = Map<int, WeekConfig>.from(currentState.weekConfigs);
    final currentConfig = updatedConfigs[week];
    if (currentConfig != null) {
      updatedConfigs[week] = currentConfig.copyWith(isComplete: true);
    }

    emit(
      currentState.copyWith(
        selections: newSelections,
        weekConfigs: updatedConfigs,
      ),
    );

    _logger.i(
      'Auto-selected ${newSelections.length - currentState.selections.length} meals for week $week',
    );
  }

  // ===============================================================
  // MEAL SELECTION LOGIC
  // ===============================================================

  /// Toggle meal selection with debouncing to prevent UI collision
  Future<void> toggleMealSelection({
    required int week,
    required MealPlanItem item,
    required String packageId,
  }) async {
    // Debouncing to prevent rapid tap collision
    if (_isProcessingSelection) {
      _logger.d('Selection already in progress, ignoring tap');
      return;
    }

    _isProcessingSelection = true;

    try {
      await _performMealSelection(week, item, packageId);
    } finally {
      // Reset debouncing flag after delay
      Future.delayed(const Duration(milliseconds: _selectionDebounceMs), () {
        _isProcessingSelection = false;
      });
    }
  }

  /// Core meal selection logic with proper validation
  Future<void> _performMealSelection(
    int week,
    MealPlanItem item,
    String packageId,
  ) async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    final weekConfig = currentState.weekConfigs[week];
    if (weekConfig == null) {
      _logger.w('No configuration found for week $week');
      return;
    }

    // Prevent unselection for 21-meal plan
    if (weekConfig.mealPlan == 21) {
      _logger.d('Cannot unselect meals for 21-meal plan');
      return;
    }

    final key = DishSelection.generateKey(
      week,
      item.dishId,
      item.day,
      item.timing,
    );
    final newSelections = Map<String, DishSelection>.from(
      currentState.selections,
    );
    final weekSelections = currentState.getSelectionsForWeek(week);

    if (newSelections.containsKey(key)) {
      // Remove selection
      newSelections.remove(key);
      _logger.d(
        'Removed selection: ${item.dishName} for $week-${item.day}-${item.timing}',
      );
    } else {
      // Check meal plan limit
      if (weekSelections.length >= weekConfig.mealPlan) {
        _logger.w(
          'Meal plan limit reached for week $week (${weekConfig.mealPlan} meals)',
        );
        return;
      }

      // Add selection
      final date = item.calculateDate(
        currentState.planningData.startDate,
        week,
      );
      final selection = DishSelection.fromMealPlanItem(
        week: week,
        item: item,
        date: date,
        packageId: packageId,
      );

      newSelections[key] = selection;
      _logger.d(
        'Added selection: ${item.dishName} for $week-${item.day}-${item.timing}',
      );
    }

    // Update week completion status
    final updatedConfigs = Map<int, WeekConfig>.from(currentState.weekConfigs);
    final updatedWeekSelections =
        newSelections.values.where((s) => s.week == week).toList();

    updatedConfigs[week] = weekConfig.copyWith(
      isComplete: updatedWeekSelections.length == weekConfig.mealPlan,
    );

    emit(
      currentState.copyWith(
        selections: newSelections,
        weekConfigs: updatedConfigs,
      ),
    );
  }

  // ===============================================================
  // WEEK NAVIGATION
  // ===============================================================

  /// Navigate to specific week
  void navigateToWeek(int week) {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    if (week < 1 || week > 4) {
      _logger.w('Invalid week number: $week');
      return;
    }

    _logger.i('Navigating to week $week');

    emit(currentState.copyWith(currentWeek: week));

    // Load week data if not already loaded
    if (!currentState.weekConfigs.containsKey(week)) {
      _logger.d('Week $week not configured, user needs to configure it');
    } else if (currentState.weekDataCache[week] == null) {
      final config = currentState.weekConfigs[week]!;
      _loadWeekData(week, config.dietaryPreference, config.mealPlan);
    }
  }

  /// Navigate to next week
  void nextWeek() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    if (currentState.canGoToNextWeek) {
      navigateToWeek(currentState.currentWeek + 1);
    }
  }

  /// Navigate to previous week
  void previousWeek() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    if (currentState.canGoToPreviousWeek) {
      navigateToWeek(currentState.currentWeek - 1);
    }
  }

  /// Retry loading data for current week
  Future<void> retryCurrentWeek() async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    final weekConfig = currentState.currentWeekConfig;
    if (weekConfig != null) {
      await _loadWeekData(
        currentState.currentWeek,
        weekConfig.dietaryPreference,
        weekConfig.mealPlan,
      );
    }
  }

  // ===============================================================
  // TOGGLE FEATURES (ENHANCED FUNCTIONALITY)
  // ===============================================================

  /// Toggle all meals of specific type for current week
  /// Follows day-wise order as specified
  Future<void> toggleMealType(String mealType) async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    final weekData = currentState.currentWeekData;
    final weekConfig = currentState.currentWeekConfig;

    if (weekData == null || weekConfig == null || !weekData.isValid) return;

    _logger.i(
      'Toggling all $mealType meals for week ${currentState.currentWeek}',
    );

    // Get meals of this type in day-wise order
    final mealTypeItems =
        weekData.availableMeals!
            .where(
              (meal) => meal.timing.toLowerCase() == mealType.toLowerCase(),
            )
            .toList();

    // Sort by day order (Monday, Tuesday, ...)
    mealTypeItems.sort(
      (a, b) => _getDayOrder(a.day).compareTo(_getDayOrder(b.day)),
    );

    final currentSelections = currentState.getSelectionsForWeek(
      currentState.currentWeek,
    );
    final selectedMealTypeKeys =
        currentSelections
            .where((s) => s.timing.toLowerCase() == mealType.toLowerCase())
            .map((s) => s.key)
            .toSet();

    // Determine if we're selecting or deselecting
    final shouldSelect = selectedMealTypeKeys.length < mealTypeItems.length;

    if (shouldSelect) {
      await _selectMealTypeItems(mealTypeItems, currentState, weekConfig);
    } else {
      await _deselectMealTypeItems(selectedMealTypeKeys, currentState);
    }
  }

  /// Select meal type items respecting meal plan limits
  Future<void> _selectMealTypeItems(
    List<MealPlanItem> items,
    WeekSelectionActive currentState,
    WeekConfig weekConfig,
  ) async {
    final newSelections = Map<String, DishSelection>.from(
      currentState.selections,
    );
    final currentWeekSelections = currentState.getSelectionsForWeek(
      currentState.currentWeek,
    );
    final availableSlots = weekConfig.mealPlan - currentWeekSelections.length;

    int selected = 0;
    for (final item in items) {
      if (selected >= availableSlots) break;

      final key = DishSelection.generateKey(
        currentState.currentWeek,
        item.dishId,
        item.day,
        item.timing,
      );

      if (!newSelections.containsKey(key)) {
        final date = item.calculateDate(
          currentState.planningData.startDate,
          currentState.currentWeek,
        );
        final selection = DishSelection.fromMealPlanItem(
          week: currentState.currentWeek,
          item: item,
          date: date,
          packageId: currentState.currentWeekData?.packageId ?? '',
        );

        newSelections[key] = selection;
        selected++;
      }
    }

    // Update completion status
    final updatedConfigs = Map<int, WeekConfig>.from(currentState.weekConfigs);
    final updatedWeekSelections =
        newSelections.values
            .where((s) => s.week == currentState.currentWeek)
            .toList();

    updatedConfigs[currentState.currentWeek] = weekConfig.copyWith(
      isComplete: updatedWeekSelections.length == weekConfig.mealPlan,
    );

    emit(
      currentState.copyWith(
        selections: newSelections,
        weekConfigs: updatedConfigs,
      ),
    );

    _logger.i('Selected $selected meal items');
  }

  /// Deselect meal type items
  Future<void> _deselectMealTypeItems(
    Set<String> keysToRemove,
    WeekSelectionActive currentState,
  ) async {
    final newSelections = Map<String, DishSelection>.from(
      currentState.selections,
    );

    for (final key in keysToRemove) {
      newSelections.remove(key);
    }

    // Update completion status
    final weekConfig = currentState.currentWeekConfig!;
    final updatedConfigs = Map<int, WeekConfig>.from(currentState.weekConfigs);
    final updatedWeekSelections =
        newSelections.values
            .where((s) => s.week == currentState.currentWeek)
            .toList();

    updatedConfigs[currentState.currentWeek] = weekConfig.copyWith(
      isComplete: updatedWeekSelections.length == weekConfig.mealPlan,
    );

    emit(
      currentState.copyWith(
        selections: newSelections,
        weekConfigs: updatedConfigs,
      ),
    );

    _logger.i('Deselected ${keysToRemove.length} meal items');
  }

  /// Get day order for sorting (Monday = 0, Tuesday = 1, etc.)
  int _getDayOrder(String day) {
    const dayOrder = {
      'monday': 0,
      'tuesday': 1,
      'wednesday': 2,
      'thursday': 3,
      'friday': 4,
      'saturday': 5,
      'sunday': 6,
    };
    return dayOrder[day.toLowerCase()] ?? 7;
  }

  // ===============================================================
  // ADDITIONAL HELPER METHODS
  // ===============================================================

  /// Toggle all breakfast meals for current week
  Future<void> toggleBreakfastMeals() async {
    await toggleMealType('breakfast');
  }

  /// Toggle all lunch meals for current week
  Future<void> toggleLunchMeals() async {
    await toggleMealType('lunch');
  }

  /// Toggle all dinner meals for current week
  Future<void> toggleDinnerMeals() async {
    await toggleMealType('dinner');
  }

  /// Clear all selections for current week
  Future<void> clearCurrentWeekSelections() async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    final weekConfig = currentState.currentWeekConfig;
    if (weekConfig == null || weekConfig.mealPlan == 21) {
      // Don't allow clearing for 21-meal plan
      return;
    }

    _logger.i('Clearing all selections for week ${currentState.currentWeek}');

    final newSelections = Map<String, DishSelection>.from(
      currentState.selections,
    );

    // Remove all selections for current week
    newSelections.removeWhere(
      (key, selection) => selection.week == currentState.currentWeek,
    );

    // Update week config to incomplete
    final updatedConfigs = Map<int, WeekConfig>.from(currentState.weekConfigs);
    updatedConfigs[currentState.currentWeek] = weekConfig.copyWith(
      isComplete: false,
    );

    emit(
      currentState.copyWith(
        selections: newSelections,
        weekConfigs: updatedConfigs,
      ),
    );
  }

  /// Select random meals for current week (up to meal plan limit)
  Future<void> selectRandomMeals() async {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return;

    final weekData = currentState.currentWeekData;
    final weekConfig = currentState.currentWeekConfig;

    if (weekData == null || weekConfig == null || !weekData.isValid) return;

    _logger.i('Selecting random meals for week ${currentState.currentWeek}');

    final availableMeals = List<MealPlanItem>.from(weekData.availableMeals!);
    availableMeals.shuffle(); // Randomize order

    final newSelections = Map<String, DishSelection>.from(
      currentState.selections,
    );

    // Remove existing selections for current week
    newSelections.removeWhere(
      (key, selection) => selection.week == currentState.currentWeek,
    );

    // Add random selections up to meal plan limit
    int selected = 0;
    for (final meal in availableMeals) {
      if (selected >= weekConfig.mealPlan) break;

      final key = DishSelection.generateKey(
        currentState.currentWeek,
        meal.dishId,
        meal.day,
        meal.timing,
      );

      final date = meal.calculateDate(
        currentState.planningData.startDate,
        currentState.currentWeek,
      );

      final selection = DishSelection.fromMealPlanItem(
        week: currentState.currentWeek,
        item: meal,
        date: date,
        packageId: weekData.packageId ?? '',
      );

      newSelections[key] = selection;
      selected++;
    }

    // Update week config completion
    final updatedConfigs = Map<int, WeekConfig>.from(currentState.weekConfigs);
    updatedConfigs[currentState.currentWeek] = weekConfig.copyWith(
      isComplete: selected == weekConfig.mealPlan,
    );

    emit(
      currentState.copyWith(
        selections: newSelections,
        weekConfigs: updatedConfigs,
      ),
    );

    _logger.i('Selected $selected random meals');
  }

  // ===============================================================
  // VALIDATION & UTILITIES
  // ===============================================================

  /// Check if current week can proceed to next
  bool canProceedToNextWeek() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return false;

    return currentState.validateCurrentWeek().isValid;
  }

  /// Get total selected meals across all weeks
  int getTotalSelectedMeals() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return 0;

    return currentState.selections.length;
  }

  /// Get selections for subscription creation
  Map<int, List<DishSelection>> getSelectionsGroupedByWeek() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return {};

    final grouped = <int, List<DishSelection>>{};

    for (final selection in currentState.selections.values) {
      grouped.putIfAbsent(selection.week, () => []).add(selection);
    }

    return grouped;
  }

  /// Get all configured weeks
  List<int> getConfiguredWeeks() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return [];

    return currentState.weekConfigs.keys.toList()..sort();
  }

  /// Get all completed weeks
  List<int> getCompletedWeeks() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return [];

    return currentState.weekConfigs.entries
        .where((entry) => entry.value.isComplete)
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }

  /// Check if all configured weeks are complete
  bool areAllWeeksComplete() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return false;

    return currentState.weekConfigs.values.every((config) => config.isComplete);
  }

  /// Get subscription creation data
  Map<String, dynamic> getSubscriptionData() {
    final currentState = state;
    if (currentState is! WeekSelectionActive) return {};

    final groupedSelections = getSelectionsGroupedByWeek();
    final weeks = <Map<String, dynamic>>[];

    for (final entry in groupedSelections.entries) {
      final week = entry.key;
      final selections = entry.value;

      if (selections.isNotEmpty) {
        final weekConfig = currentState.weekConfigs[week];
        final packageId = selections.first.packageId;

        weeks.add({
          'package': packageId,
          'slots': selections.map((s) => s.toSubscriptionSlot()).toList(),
        });
      }
    }

    return {
      'startDate': currentState.planningData.startDate.toIso8601String(),
      'weeks': weeks,
    };
  }

  /// Reset to initial state
  void reset() {
    _logger.i('Resetting week selection');
    emit(const WeekSelectionInitial());
  }

  /// Dispose and cleanup
  @override
  Future<void> close() {
    _logger.d('Closing WeekSelectionCubit');
    return super.close();
  }
}
