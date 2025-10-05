// lib/src/presentation/cubits/meal_planning/meal_planning_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/loggin_manager.dart';
import 'package:foodam/src/domain/entities/meal_planning/meal_planning_config_entity.dart';
import 'package:foodam/src/domain/entities/meal_planning/subscription_request_entity.dart';
import 'package:foodam/src/domain/entities/meal_planning/week_selection_data_entity.dart';
import 'package:foodam/src/domain/entities/meal_planning/week_validation_entity.dart';
import 'package:foodam/src/domain/usecase/meal_planning/create_subscription_use_case.dart';
import 'package:foodam/src/domain/usecase/meal_planning/get_calculated_plan_use_case.dart';

part 'meal_planning_state.dart';

class MealPlanningCubit extends Cubit<MealPlanningState> {
  final GetCalculatedPlanUseCase _getCalculatedPlanUseCase;
  final CreateSubscriptionUseCase _createSubscriptionUseCase;
  final LoggingManager _logger;

  MealPlanningCubit({
    required GetCalculatedPlanUseCase getCalculatedPlanUseCase,
    required CreateSubscriptionUseCase createSubscriptionUseCase,
    required LoggingManager logger,
  }) : _getCalculatedPlanUseCase = getCalculatedPlanUseCase,
       _createSubscriptionUseCase = createSubscriptionUseCase,
       _logger = logger,
       super(MealPlanningInitial());

  void initializePlanning() {
    _logger.logger.i('Initializing meal planning', tag: 'MealPlanning');
    emit(const StartPlanningActive());
  }

  void updateStartDate(DateTime date) {
    final currentState = state;
    if (currentState is StartPlanningActive) {
      emit(currentState.copyWith(selectedStartDate: date));
    }
  }

  void updateDietaryPreference(String preference) {
    final currentState = state;
    if (currentState is StartPlanningActive) {
      emit(currentState.copyWith(selectedDietaryPreference: preference));
    }
  }

  void updateMealCount(int count) {
    final currentState = state;
    if (currentState is StartPlanningActive) {
      emit(currentState.copyWith(selectedMealCount: count));
    }
  }

  void updateWeekCount(int count) {
    final currentState = state;
    if (currentState is StartPlanningActive) {
      if (count >= 1 && count <= 4) {
        emit(currentState.copyWith(selectedWeekCount: count));
      }
    }
  }

  Future<void> startWeekPlanning({
    required DateTime startDate,
    required String dietaryPreference,
    required int mealCount,
    int numberOfWeeks = 1,
  }) async {
    try {
      _logger.logger.i('Starting week planning', tag: 'MealPlanning');

      final config = MealPlanningConfigFactory.createWeekly(
        startDate: startDate,
        dietaryPreference: dietaryPreference,
        mealCountPerWeek: mealCount,
        numberOfWeeks: numberOfWeeks,
      );

      // Initialize week selections with default config
      final Map<int, WeekSelectionData> weekSelections = {};
      for (int week = 1; week <= numberOfWeeks; week++) {
        weekSelections[week] = WeekSelectionDataFactory.create(
          targetMealCount: mealCount,
          dietaryPreference: dietaryPreference,
        );
      }

      // Load first week data
      await _loadWeekData(
        1,
        startDate,
        dietaryPreference,
        config,
        weekSelections,
        {},
      );
    } catch (e) {
      _logger.logger.e(
        'Error starting week planning',
        error: e,
        tag: 'MealPlanning',
      );
      emit(MealPlanningError('Failed to start planning: ${e.toString()}'));
    }
  }

  Future<void> _loadWeekData(
    int week,
    DateTime startDate,
    String dietaryPreference,
    MealPlanningConfig config,
    Map<int, WeekSelectionData> weekSelections,
    Map<int, bool> hasSeenConfigPrompt,
  ) async {
    emit(WeekGridLoading(week: week, message: 'Loading week $week meals...'));

    final params = GetCalculatedPlanParams(
      dietaryPreference: dietaryPreference,
      week: week,
      startDate: startDate,
    );

    final result = await _getCalculatedPlanUseCase(params);

    result.fold(
      (failure) {
        _logger.logger.e(
          'Failed to load week data',
          error: failure.message,
          tag: 'MealPlanning',
        );
        emit(MealPlanningError(failure.message ?? ""));
      },
      (calculatedPlan) {
        weekSelections[week] = weekSelections[week]!.copyWith(
          weekData: calculatedPlan,
        );

        emit(
          WeekGridLoaded(
            currentWeek: week,
            totalWeeks: config.numberOfWeeks,
            weekSelections: weekSelections,
            currentWeekValidation: weekSelections[week]!.validation,
            totalPrice: _calculateTotalPrice(weekSelections),
            config: config,

            hasSeenConfigPrompt: hasSeenConfigPrompt,
          ),
        );
      },
    );
  }

  // NEW: Check if can select more meals (hard limit)
  bool canSelectMoreMeals() {
    final currentState = state;
    if (currentState is! WeekGridLoaded) return false;

    return currentState.currentWeekValidation.selectedCount <
        currentState.currentWeekValidation.targetCount;
  }

  void toggleMealSlot(String slotKey) {
    final currentState = state;
    if (currentState is! WeekGridLoaded) return;

    final currentWeek = currentState.currentWeek;
    final updatedWeekSelections = Map<int, WeekSelectionData>.from(
      currentState.weekSelections,
    );

    final isCurrentlySelected = updatedWeekSelections[currentWeek]!
        .isSlotSelected(slotKey);

    // Always allow deselection
    if (isCurrentlySelected) {
      updatedWeekSelections[currentWeek] = updatedWeekSelections[currentWeek]!
          .toggleSlot(slotKey);
    } else {
      // Check hard limit before allowing selection
      final validation = updatedWeekSelections[currentWeek]!.validation;
      if (validation.selectedCount < validation.targetCount) {
        updatedWeekSelections[currentWeek] = updatedWeekSelections[currentWeek]!
            .toggleSlot(slotKey);
      } else {
        // Hard limit reached - do nothing, UI will show feedback
        return;
      }
    }

    emit(
      WeekGridLoaded(
        currentWeek: currentState.currentWeek,
        totalWeeks: currentState.totalWeeks,
        weekSelections: updatedWeekSelections,
        currentWeekValidation: updatedWeekSelections[currentWeek]!.validation,
        totalPrice: _calculateTotalPrice(updatedWeekSelections),
        config: currentState.config,
        hasSeenConfigPrompt: currentState.hasSeenConfigPrompt,
      ),
    );
  }

  // NEW: Mark config prompt as seen
  void markConfigPromptSeen(int week) {
    final currentState = state;
    if (currentState is! WeekGridLoaded) return;

    final updatedPrompts = Map<int, bool>.from(
      currentState.hasSeenConfigPrompt,
    );
    updatedPrompts[week] = true;

    emit(
      WeekGridLoaded(
        currentWeek: currentState.currentWeek,
        totalWeeks: currentState.totalWeeks,
        weekSelections: currentState.weekSelections,
        currentWeekValidation: currentState.currentWeekValidation,
        totalPrice: currentState.totalPrice,
        config: currentState.config,
        hasSeenConfigPrompt: updatedPrompts,
      ),
    );
  }

  // NEW: Update week configuration and reload data
  Future<void> updateWeekConfiguration({
    required int week,
    required String dietaryPreference,
    required int targetMealCount,
    bool isSkipped = false,
  }) async {
    final currentState = state;
    if (currentState is! WeekGridLoaded) return;

    try {
      final updatedWeekSelections = Map<int, WeekSelectionData>.from(
        currentState.weekSelections,
      );

      // Reset week selections
      updatedWeekSelections[week] = WeekSelectionDataFactory.create(
        targetMealCount: isSkipped ? 0 : targetMealCount,
        dietaryPreference: dietaryPreference,
      );

      if (!isSkipped) {
        // Reload week data with new config
        await _loadWeekData(
          week,
          currentState.config!.startDate,
          dietaryPreference,
          currentState.config!,
          updatedWeekSelections,
          currentState.hasSeenConfigPrompt,
        );
      } else {
        // Emit skipped week state
        emit(
          WeekGridLoaded(
            currentWeek: week,
            totalWeeks: currentState.totalWeeks,
            weekSelections: updatedWeekSelections,
            currentWeekValidation: updatedWeekSelections[week]!.validation,
            totalPrice: _calculateTotalPrice(updatedWeekSelections),
            config: currentState.config,
            hasSeenConfigPrompt: currentState.hasSeenConfigPrompt,
          ),
        );
      }
    } catch (e) {
      _logger.logger.e(
        'Error updating week configuration',
        error: e,
        tag: 'MealPlanning',
      );
      emit(
        MealPlanningError('Failed to update configuration: ${e.toString()}'),
      );
    }
  }

  Future<void> switchToWeek(int week) async {
    final currentState = state;
    if (currentState is! WeekGridLoaded) return;

    // Check if week data already exists
    if (currentState.weekSelections[week]?.weekData != null) {
      // Just switch to existing week
      emit(
        WeekGridLoaded(
          currentWeek: week,
          totalWeeks: currentState.totalWeeks,
          weekSelections: currentState.weekSelections,
          currentWeekValidation: currentState.weekSelections[week]!.validation,
          totalPrice: currentState.totalPrice,
          config: currentState.config,
          hasSeenConfigPrompt: currentState.hasSeenConfigPrompt,
        ),
      );
    } else {
      // Load week data (config prompt should be handled by UI)
      final config = currentState.config!;
      final weekData = currentState.weekSelections[week]!;

      await _loadWeekData(
        week,
        config.startDate,
        weekData.dietaryPreference,
        config,
        Map.from(currentState.weekSelections),
        Map.from(currentState.hasSeenConfigPrompt),
      );
    }
  }

  Future<void> createSubscription({
    required String addressId,
    String instructions = '',
  }) async {
    final currentState = state;
    if (currentState is! WeekGridLoaded) return;

    if (!currentState.allWeeksComplete) {
      emit(
        const MealPlanningError('Please complete all weeks before subscribing'),
      );
      return;
    }

    try {
      emit(const SubscriptionCreating('Creating your subscription...'));

      final config = currentState.config!;

      final weekRequestData =
          currentState.weekSelections.entries.map((entry) {
            final weekData = entry.value;
            return WeekRequestData(
              dietaryPreference: weekData.dietaryPreference,
              slots: weekData.selectedSlotKeys,
            );
          }).toList();

      final subscriptionRequest = SubscriptionRequest(
        startDate: config.startDate,
        address: addressId,
        instructions: instructions,
        noOfPersons: config.noOfPersons,
        weeks: weekRequestData,
      );

      final params = CreateSubscriptionParams(request: subscriptionRequest);
      final result = await _createSubscriptionUseCase(params);

      result.fold(
        (failure) {
          _logger.logger.e(
            'Failed to create subscription',
            error: failure.message,
            tag: 'MealPlanning',
          );
          emit(MealPlanningError(failure.message ?? ""));
        },
        (response) {
          _logger.logger.i(
            'Subscription created successfully',
            tag: 'MealPlanning',
          );
          emit(
            SubscriptionSuccess(
              subscriptionId: response.id ?? '',
              message: response.message,
              totalAmount: response.totalAmount,
            ),
          );
        },
      );
    } catch (e) {
      _logger.logger.e(
        'Error creating subscription',
        error: e,
        tag: 'MealPlanning',
      );
      emit(MealPlanningError('Failed to create subscription: ${e.toString()}'));
    }
  }

  double _calculateTotalPrice(Map<int, WeekSelectionData> weekSelections) {
    return weekSelections.values.fold(
      0.0,
      (total, week) => total + week.weekPrice,
    );
  }

  void reset() {
    emit(MealPlanningInitial());
  }
}
