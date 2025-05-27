// lib/src/presentation/cubits/subscription/planning/subscription_planning_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/entities/dish_selection.dart';
import 'package:foodam/src/domain/entities/meal_plan_item.dart';
import 'package:foodam/src/domain/entities/price_option.dart';
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
    } else if (state is CheckoutActive) {
      final checkoutState = state as CheckoutActive;
      emit(
        PlanningFormActive(
          startDate: checkoutState.startDate,
          dietaryPreference: checkoutState.dietaryPreference,
          duration: checkoutState.duration,
          mealPlan: checkoutState.mealPlan,
        ),
      );
    } else if (state is SubscriptionCreationSuccess) {
      final successState = state as SubscriptionCreationSuccess;
      emit(
        PlanningFormActive(
          startDate: successState.startDate,
          dietaryPreference: successState.dietaryPreference,
          duration: successState.duration,
          mealPlan: successState.mealPlan,
        ),
      );
    } else if (state is SubscriptionCreationError) {
      final errorState = state as SubscriptionCreationError;
      emit(
        PlanningFormActive(
          startDate: errorState.startDate,
          dietaryPreference: errorState.dietaryPreference,
          duration: errorState.duration,
          mealPlan: errorState.mealPlan,
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

    // 🔥 CRITICAL FIX: Include weekPricing in new state
    final newState = WeekSelectionActive(
      startDate: currentState.startDate,
      dietaryPreference: currentState.dietaryPreference,
      duration: currentState.duration,
      mealPlan: currentState.mealPlan,
      currentWeek: currentState.currentWeek,
      weekDataStatus: currentState.weekDataStatus,
      weekSelections: newSelections, // NEW Map instance
      weekPackageIds: newPackageIds, // NEW Map instance
      weekPricing: currentState.weekPricing, // 🔥 FIX: Preserve pricing!
    );

    emit(newState);

    // 🔍 DEBUG: Verify state change
    final verifyState = state as WeekSelectionActive;
    _logger.d(
      '✅ State emitted. Verified count: ${verifyState.currentWeekSelectionCount}',
    );
    _logger.d('💰 Verified pricing preserved: ${verifyState.weekPricing}');
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

    _logger.i('🔄 ===== GOING TO SUMMARY =====');
    _logger.d('📊 Current week pricing: ${currentState.weekPricing}');
    _logger.d('💰 Total pricing: ${currentState.totalPricing}');

    try {
      final summaryState = PlanningComplete(
        startDate: currentState.startDate,
        dietaryPreference: currentState.dietaryPreference,
        duration: currentState.duration,
        mealPlan: currentState.mealPlan,
        weekSelections: currentState.weekSelections,
        weekPackageIds: currentState.weekPackageIds,
        weekPricing: currentState.weekPricing,
      );

      _logger.d('📊 Summary state pricing: ${summaryState.weekPricing}');
      _logger.d('💰 Summary total pricing: ${summaryState.totalPricing}');
      _logger.i('🔄 ===== SUMMARY STATE CREATED =====');

      emit(summaryState);
    } catch (e) {
      _logger.e('❌ Error creating summary state', error: e);
      emit(SubscriptionPlanningError('Failed to prepare summary: $e'));
    }
  }

  /// Go to checkout

  void goToCheckout() {
    final currentState = state;
    _logger.i('🔄 ===== GOING TO CHECKOUT =====');
    _logger.d('📊 Current state type: ${currentState.runtimeType}');

    // Accept both PlanningComplete and already CheckoutActive states
    if (currentState is PlanningComplete) {
      _logger.d('📊 Complete state pricing: ${currentState.weekPricing}');
      _logger.d('💰 Complete total pricing: ${currentState.totalPricing}');

      try {
        final checkoutState = CheckoutActive(
          startDate: currentState.startDate,
          dietaryPreference: currentState.dietaryPreference,
          duration: currentState.duration,
          mealPlan: currentState.mealPlan,
          weekSelections: currentState.weekSelections,
          weekPackageIds: currentState.weekPackageIds,
          weekPricing: currentState.weekPricing,
        );

        _logger.d('📊 Checkout state pricing: ${checkoutState.weekPricing}');
        _logger.d('💰 Checkout total pricing: ${checkoutState.totalPricing}');
        _logger.i('🔄 ===== CHECKOUT STATE CREATED =====');

        emit(checkoutState);
      } catch (e) {
        _logger.e('❌ Error creating checkout state', error: e);
        emit(SubscriptionPlanningError('Failed to prepare checkout: $e'));
      }
    } else if (currentState is CheckoutActive) {
      _logger.d('Already in checkout state, no transition needed');
    } else {
      _logger.w(
        '⚠️ Cannot transition to checkout from state: ${currentState.runtimeType}',
      );
      emit(SubscriptionPlanningError('Invalid state for checkout transition'));
    }
  }

  void ensureCheckoutState() {
    final currentState = state;
    _logger.d('🔄 Ensuring checkout state from: ${currentState.runtimeType}');

    if (currentState is CheckoutActive) {
      _logger.d('✅ Already in CheckoutActive state');
      return;
    }

    if (currentState is PlanningComplete) {
      _logger.d('🔄 Converting PlanningComplete to CheckoutActive');
      goToCheckout();
      return;
    }

    if (currentState is WeekSelectionActive &&
        currentState.isAllWeeksComplete) {
      _logger.d(
        '🔄 Converting completed WeekSelection to Checkout via Summary',
      );
      _goToSummary();
      // Will need another call to goToCheckout after this
      WidgetsBinding.instance.addPostFrameCallback((_) {
        goToCheckout();
      });
      return;
    }

    _logger.e(
      '❌ Cannot ensure checkout state from: ${currentState.runtimeType}',
    );
    emit(
      SubscriptionPlanningError('Cannot prepare checkout from current state'),
    );
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

  /// 🔥 UPDATED: Create subscription with new state emissions
  Future<void> createSubscription() async {
    final currentState = state;
    if (currentState is! CheckoutActive) return;

    if (!currentState.canSubmit) {
      emit(
        SubscriptionCreationError(
          message: 'Please complete all required fields',
          startDate: currentState.startDate,
          dietaryPreference: currentState.dietaryPreference,
          duration: currentState.duration,
          mealPlan: currentState.mealPlan,
          weekSelections: currentState.weekSelections,
          weekPackageIds: currentState.weekPackageIds,
          weekPricing: currentState.weekPricing, // 🔥 NEW
          selectedAddressId: currentState.selectedAddressId,
          instructions: currentState.instructions,
          noOfPersons: currentState.noOfPersons,
        ),
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

          // 🔥 NEW: Emit specific creation error state with pricing
          emit(
            SubscriptionCreationError(
              message: failure.message ?? 'Failed to create subscription',
              startDate: currentState.startDate,
              dietaryPreference: currentState.dietaryPreference,
              duration: currentState.duration,
              mealPlan: currentState.mealPlan,
              weekSelections: currentState.weekSelections,
              weekPackageIds: currentState.weekPackageIds,
              weekPricing: currentState.weekPricing, // 🔥 NEW
              selectedAddressId: currentState.selectedAddressId,
              instructions: currentState.instructions,
              noOfPersons: currentState.noOfPersons,
            ),
          );
        },
        (subscription) {
          _logger.i('Subscription created successfully: ${subscription.id}');

          // 🔥 NEW: Emit success state with subscription and pricing
          emit(
            SubscriptionCreationSuccess(
              subscription: subscription,
              startDate: currentState.startDate,
              dietaryPreference: currentState.dietaryPreference,
              duration: currentState.duration,
              mealPlan: currentState.mealPlan,
              weekSelections: currentState.weekSelections,
              weekPackageIds: currentState.weekPackageIds,
              weekPricing: currentState.weekPricing, // 🔥 NEW
              selectedAddressId: currentState.selectedAddressId!,
              instructions: currentState.instructions,
              noOfPersons: currentState.noOfPersons,
            ),
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error creating subscription', error: e);

      // 🔥 NEW: Emit creation error state with pricing
      emit(
        SubscriptionCreationError(
          message: 'An unexpected error occurred',
          startDate: currentState.startDate,
          dietaryPreference: currentState.dietaryPreference,
          duration: currentState.duration,
          mealPlan: currentState.mealPlan,
          weekSelections: currentState.weekSelections,
          weekPackageIds: currentState.weekPackageIds,
          weekPricing: currentState.weekPricing, // 🔥 NEW
          selectedAddressId: currentState.selectedAddressId,
          instructions: currentState.instructions,
          noOfPersons: currentState.noOfPersons,
        ),
      );
    }
  }

  /// Retry subscription creation from error state
  Future<void> retryCreateSubscription() async {
    final currentState = state;
    if (currentState is! SubscriptionCreationError) return;

    if (!currentState.canRetry) {
      emit(
        SubscriptionCreationError(
          message: 'Please complete all required fields before retrying',
          startDate: currentState.startDate,
          dietaryPreference: currentState.dietaryPreference,
          duration: currentState.duration,
          mealPlan: currentState.mealPlan,
          weekSelections: currentState.weekSelections,
          weekPackageIds: currentState.weekPackageIds,
          weekPricing: currentState.weekPricing, // 🔥 NEW
          selectedAddressId: currentState.selectedAddressId,
          instructions: currentState.instructions,
          noOfPersons: currentState.noOfPersons,
        ),
      );
      return;
    }

    // Go back to checkout state and retry
    emit(
      CheckoutActive(
        startDate: currentState.startDate,
        dietaryPreference: currentState.dietaryPreference,
        duration: currentState.duration,
        mealPlan: currentState.mealPlan,
        weekSelections: currentState.weekSelections,
        weekPackageIds: currentState.weekPackageIds,
        weekPricing: currentState.weekPricing, // 🔥 NEW
        selectedAddressId: currentState.selectedAddressId,
        instructions: currentState.instructions,
        noOfPersons: currentState.noOfPersons,
      ),
    );

    // Immediately retry creation
    await createSubscription();
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
      _logger.i('🔄 Loading week $week data...');

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
          _logger.e('❌ Failed to load week $week: ${failure.message}');

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
          _logger.d('✅ Week $week data loaded successfully');

          // 🔥 ENHANCED: Detailed package and pricing debug
          String? packageId;
          double pricePerMeal = 0.0;

          _logger.d('🔍 ===== PACKAGE DEBUG =====');
          _logger.d(
            '📦 CalculatedPlan exists: ${weekCache.calculatedPlan != null}',
          );

          if (weekCache.calculatedPlan?.package != null) {
            final package = weekCache.calculatedPlan!.package!;
            packageId = package.id;

            _logger.d('📦 Package ID: $packageId');
            _logger.d('📦 Package Name: ${package.name}');
            _logger.d(
              '📦 Package priceOptions: ${package.priceOptions?.length ?? 0} options',
            );

            // Debug each price option
            if (package.priceOptions != null) {
              for (int i = 0; i < package.priceOptions!.length; i++) {
                final option = package.priceOptions![i];
                _logger.d(
                  '   🏷️  Option $i: ${option.numberOfMeals} meals = ₹${option.price}',
                );
              }
            } else {
              _logger.e('❌ CRITICAL: package.priceOptions is NULL!');
            }

            _logger.d(
              '🎯 Current meal plan selection: ${currentState.mealPlan}',
            );

            // Extract pricing
            pricePerMeal = _extractPriceForMealPlan(
              package.priceOptions ?? [],
              currentState.mealPlan,
            );

            _logger.i(
              '💰 Final extracted price: ₹$pricePerMeal for ${currentState.mealPlan} meals',
            );
          } else {
            _logger.e('❌ CRITICAL: No package found in CalculatedPlan!');
          }

          // Update status to loaded with pricing
          final loadedStatus = Map<int, WeekDataStatus>.from(
            currentState.weekDataStatus,
          );
          loadedStatus[week] = WeekDataStatus.loaded(
            week: week,
            calculatedPlan: weekCache.calculatedPlan!,
            packageId: packageId ?? '',
            pricePerMeal: pricePerMeal,
          );

          // Update week pricing map
          final updatedPricing = Map<int, double>.from(
            currentState.weekPricing,
          );
          updatedPricing[week] = pricePerMeal;

          _logger.d('📊 Updated pricing map: $updatedPricing');
          _logger.d(
            '💰 Total pricing so far: ${updatedPricing.values.fold(0.0, (sum, price) => sum + price)}',
          );

          if (!isClosed) {
            emit(
              currentState.copyWith(
                weekDataStatus: loadedStatus,
                weekPricing: updatedPricing,
              ),
            );
          }

          _logger.d('🔍 ===== WEEK $week LOAD COMPLETE =====');
        },
      );
    } catch (e) {
      _logger.e('💥 Unexpected error loading week $week', error: e);

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

  /// 🔥 NEW: Extract price for specific meal plan from price options
  double _extractPriceForMealPlan(
    List<PriceOption> priceOptions,
    int selectedMealPlan,
  ) {
    _logger.d('🔍 ===== PRICING DEBUG START =====');
    _logger.d('📋 Available Price Options:');

    for (int i = 0; i < priceOptions.length; i++) {
      final option = priceOptions[i];
      _logger.d('   [$i] ${option.numberOfMeals} meals = ₹${option.price}');
    }

    _logger.d('🎯 User selected: $selectedMealPlan meals');

    if (priceOptions.isEmpty) {
      _logger.e('❌ CRITICAL: No price options available!');
      return 0.0;
    }

    // Try exact match first
    for (final option in priceOptions) {
      if (option.numberOfMeals == selectedMealPlan) {
        _logger.i(
          '✅ EXACT MATCH: ${option.numberOfMeals} meals = ₹${option.price}',
        );
        return option.price;
      }
    }

    _logger.w('⚠️  No exact match found for $selectedMealPlan meals');

    // 🔥 NEW: Fallback to closest match
    final sortedOptions = List<PriceOption>.from(priceOptions);
    sortedOptions.sort(
      (a, b) => (a.numberOfMeals - selectedMealPlan).abs().compareTo(
        (b.numberOfMeals - selectedMealPlan).abs(),
      ),
    );

    final closestOption = sortedOptions.first;
    _logger.i(
      '📍 FALLBACK: Using closest match: ${closestOption.numberOfMeals} meals = ₹${closestOption.price}',
    );

    return closestOption.price;
  }

  /// 🔥 NEW: Get total pricing across all loaded weeks
  double getTotalPricing() {
    final currentState = state;

    _logger.d('🔍 ===== GET TOTAL PRICING DEBUG =====');
    _logger.d('📊 Current state type: ${currentState.runtimeType}');

    double total = 0.0;

    if (currentState is WeekSelectionActive) {
      total = currentState.totalPricing;
      _logger.d('📊 WeekSelection pricing: ${currentState.weekPricing}');
    } else if (currentState is PlanningComplete) {
      total = currentState.totalPricing;
      _logger.d('📊 Complete pricing: ${currentState.weekPricing}');
    } else if (currentState is CheckoutActive) {
      total = currentState.totalPricing;
      _logger.d('📊 Checkout pricing: ${currentState.weekPricing}');
    } else if (currentState is SubscriptionCreationSuccess) {
      total = currentState.totalPricing;
      _logger.d('📊 Success pricing: ${currentState.weekPricing}');
    } else if (currentState is SubscriptionCreationError) {
      total = currentState.totalPricing;
      _logger.d('📊 Error pricing: ${currentState.weekPricing}');
    } else {
      _logger.w('⚠️  State does not have pricing: ${currentState.runtimeType}');
    }

    _logger.d('💰 Total pricing result: ₹$total');
    _logger.d('🔍 ===== GET TOTAL PRICING END =====');

    return total;
  }

  void debugPriceExtraction() {
    _logger.d('🧪 ===== MANUAL PRICE TEST =====');

    // Simulate the API response data
    final testPriceOptions = [
      PriceOption(numberOfMeals: 10, price: 1.0),
      PriceOption(numberOfMeals: 15, price: 2.0),
      PriceOption(numberOfMeals: 18, price: 3.0),
      PriceOption(numberOfMeals: 21, price: 1.0),
    ];

    // Test various meal plan selections
    final testMealPlans = [7, 10, 12, 15, 20, 21, 25];

    for (final mealPlan in testMealPlans) {
      final price = _extractPriceForMealPlan(testPriceOptions, mealPlan);
      _logger.d('🧪 Test: $mealPlan meals → ₹$price');
    }

    _logger.d('🧪 ===== MANUAL PRICE TEST END =====');
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
      instructions:
          state.instructions?.isNotEmpty == true ? state.instructions! : "",
      noOfPersons: state.noOfPersons,
      weeks: weeks,
    );
  }
}
