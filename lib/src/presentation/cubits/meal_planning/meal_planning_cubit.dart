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

  // Initialize planning form
  void initializePlanning() {
    _logger.logger.i('Initializing meal planning', tag: 'MealPlanning');
    emit(const StartPlanningActive());
  }

  // Update form selections
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

  // Start week grid planning
  Future<void> startWeekPlanning({
    required DateTime startDate,
    required String dietaryPreference,
    required int mealCount,
    int numberOfWeeks = 1,
  }) async {
    try {
      print(
        '🚀 Starting week planning: weeks=$numberOfWeeks, meals=$mealCount',
      );
      _logger.logger.i('Starting week planning', tag: 'MealPlanning');

      // Create planning configuration
      final config = MealPlanningConfigFactory.createWeekly(
        startDate: startDate,
        dietaryPreference: dietaryPreference,
        mealCountPerWeek: mealCount,
        numberOfWeeks: numberOfWeeks,
      );

      // Initialize week selections
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

  // Load calculated plan for specific week
  Future<void> _loadWeekData(
    int week,
    DateTime startDate,
    String dietaryPreference,
    MealPlanningConfig config,
    Map<int, WeekSelectionData> weekSelections,
  ) async {
    print('📥 Loading week $week data');
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
        // Update week selection data with calculated plan
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
          ),
        );
      },
    );
  }

  void updateWeekCount(int count) {
    final currentState = state;
    if (currentState is StartPlanningActive) {
      if (count >= 1 && count <= 4) {
        emit(currentState.copyWith(selectedWeekCount: count));
      }
    }
  }

  // Toggle meal slot selection
  void toggleMealSlot(String slotKey) {
    final currentState = state;
    if (currentState is! WeekGridLoaded) return;

    final currentWeek = currentState.currentWeek;
    final updatedWeekSelections = Map<int, WeekSelectionData>.from(
      currentState.weekSelections,
    );

    // Toggle the slot
    updatedWeekSelections[currentWeek] = updatedWeekSelections[currentWeek]!
        .toggleSlot(slotKey);

    emit(
      WeekGridLoaded(
        currentWeek: currentState.currentWeek,
        totalWeeks: currentState.totalWeeks,
        weekSelections: updatedWeekSelections,
        currentWeekValidation: updatedWeekSelections[currentWeek]!.validation,
        totalPrice: _calculateTotalPrice(updatedWeekSelections),
        config: currentState.config,
      ),
    );
  }

  // Switch to different week
  Future<void> switchToWeek(int week) async {
    final currentState = state;
    if (currentState is! WeekGridLoaded) return;

    // If week data doesn't exist, load it
    if (currentState.weekSelections[week]?.weekData == null) {
      final config = currentState.config!;
      await _loadWeekData(
        week,
        config.startDate,
        config.dietaryPreference,
        config,
        Map.from(currentState.weekSelections),
      );
    } else {
      // Just switch to existing week
      emit(
        WeekGridLoaded(
          currentWeek: week,
          totalWeeks: currentState.totalWeeks,
          weekSelections: currentState.weekSelections,
          currentWeekValidation: currentState.weekSelections[week]!.validation,
          totalPrice: currentState.totalPrice,
          config: currentState.config,
        ),
      );
    }
  }

  // Create subscription
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

      // Build subscription request
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

  // Calculate total price across all weeks
  double _calculateTotalPrice(Map<int, WeekSelectionData> weekSelections) {
    return weekSelections.values.fold(
      0.0,
      (total, week) => total + week.weekPrice,
    );
  }

  // Reset to initial state
  void reset() {
    emit(MealPlanningInitial());
  }
}
