// lib/src/presentation/cubits/subscription_creation/subscription_creation_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';

import 'create_subcription_state.dart';

class SubscriptionCreationCubit extends Cubit<SubscriptionCreationState> {
  final SubscriptionUseCase _subscriptionUseCase;
  final LoggerService _logger = LoggerService();

  SubscriptionCreationCubit({required SubscriptionUseCase subscriptionUseCase})
    : _subscriptionUseCase = subscriptionUseCase,
      super(SubscriptionCreationInitial());

  /// Initialize subscription creation with package and calculated plan
  void initializeCreation({
    required Package package,
    required int selectedMealCount,
    required double selectedPrice,
    required CalculatedPlan calculatedPlan,
    required DateTime startDate,
    required DateTime endDate,
    required int durationDays,
  }) {
    try {
      _logger.i('Initializing subscription creation');

      // Determine number of weeks based on duration
      final int numberOfWeeks = (durationDays / 7).ceil();

      // Create initial week selections
      final List<WeekSelection> weekSelections = [];

      // For simplicity, we'll just use the same package for all weeks
      for (int weekIndex = 0; weekIndex < numberOfWeeks; weekIndex++) {
        final weekStartDate = startDate.add(Duration(days: weekIndex * 7));

        // Create day selections for this week (up to 7 days or end date)
        final List<DaySelection> daySelections = [];

        for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
          final currentDate = weekStartDate.add(Duration(days: dayIndex));

          // Stop if we've reached the end date
          if (currentDate.isAfter(endDate)) {
            break;
          }

          // Get day name
          final dayName = _getDayName(currentDate.weekday);

          // Create meal selections (breakfast, lunch, dinner)
          final Map<String, MealSelection> mealSelections = {
            'breakfast': MealSelection(
              mealId: _getMealIdForDay(
                calculatedPlan,
                currentDate,
                'breakfast',
              ),
              isSelected: false,
            ),
            'lunch': MealSelection(
              mealId: _getMealIdForDay(calculatedPlan, currentDate, 'lunch'),
              isSelected: false,
            ),
            'dinner': MealSelection(
              mealId: _getMealIdForDay(calculatedPlan, currentDate, 'dinner'),
              isSelected: false,
            ),
          };

          daySelections.add(
            DaySelection(
              date: currentDate,
              day: dayName,
              mealSelections: mealSelections,
            ),
          );
        }

        weekSelections.add(
          WeekSelection(
            weekNumber: weekIndex + 1,
            packageId: package.id,
            daySelections: daySelections,
          ),
        );
      }

      // Calculate total required meal count based on number of weeks
      final requiredMealCount = selectedMealCount * numberOfWeeks;

      // Calculate total price
      final totalPrice = selectedPrice * numberOfWeeks;

      emit(
        MealSelectionActive(
          startDate: startDate,
          endDate: endDate,
          durationDays: durationDays,
          weekSelections: weekSelections,
          totalSelectedMeals: 0,
          requiredMealCount: requiredMealCount,
          totalPrice: totalPrice,
        ),
      );

      _logger.i(
        'Subscription creation initialized with $numberOfWeeks weeks, requiring $requiredMealCount meals',
      );
    } catch (e) {
      _logger.e('Error initializing subscription creation', error: e);
      emit(
        SubscriptionCreationError('Failed to initialize subscription creation'),
      );
    }
  }

  /// Toggle meal selection
  void toggleMealSelection(int weekIndex, int dayIndex, String mealType) {
    if (state is! MealSelectionActive) {
      _logger.w('Cannot toggle meal - not in selection state');
      return;
    }

    final currentState = state as MealSelectionActive;

    try {
      // Create a deep copy of week selections
      final List<WeekSelection> updatedWeekSelections = [];

      for (int w = 0; w < currentState.weekSelections.length; w++) {
        final currentWeek = currentState.weekSelections[w];

        if (w != weekIndex) {
          // Keep this week unchanged
          updatedWeekSelections.add(currentWeek);
          continue;
        }

        // Create updated day selections for this week
        final List<DaySelection> updatedDaySelections = [];

        for (int d = 0; d < currentWeek.daySelections.length; d++) {
          final currentDay = currentWeek.daySelections[d];

          if (d != dayIndex) {
            // Keep this day unchanged
            updatedDaySelections.add(currentDay);
            continue;
          }

          // Update this day's meal selection
          final updatedMealSelections = Map<String, MealSelection>.from(
            currentDay.mealSelections,
          );
          final currentMeal = updatedMealSelections[mealType]!;

          // Toggle selection
          updatedMealSelections[mealType] = MealSelection(
            mealId: currentMeal.mealId,
            isSelected: !currentMeal.isSelected,
          );

          updatedDaySelections.add(
            DaySelection(
              date: currentDay.date,
              day: currentDay.day,
              mealSelections: updatedMealSelections,
            ),
          );
        }

        updatedWeekSelections.add(
          WeekSelection(
            weekNumber: currentWeek.weekNumber,
            packageId: currentWeek.packageId,
            daySelections: updatedDaySelections,
          ),
        );
      }

      // Calculate new total selected meal count
      final totalSelectedMeals = updatedWeekSelections.fold(
        0,
        (sum, week) => sum + week.selectedMealCount,
      );

      emit(
        currentState.copyWith(
          weekSelections: updatedWeekSelections,
          totalSelectedMeals: totalSelectedMeals,
        ),
      );

      _logger.i(
        'Toggled meal selection: Week $weekIndex, Day $dayIndex, Meal $mealType. Total selected: $totalSelectedMeals/${currentState.requiredMealCount}',
      );
    } catch (e) {
      _logger.e('Error toggling meal selection', error: e);
      // Don't change state on error
    }
  }

  /// Update subscription details
  void updateDetails({
    int? personCount,
    String? addressId,
    String? instructions,
  }) {
    if (state is! MealSelectionActive) {
      _logger.w('Cannot update details - not in selection state');
      return;
    }

    final currentState = state as MealSelectionActive;

    emit(
      currentState.copyWith(
        personCount: personCount,
        addressId: addressId,
        instructions: instructions,
      ),
    );

    _logger.i('Updated subscription details');
  }

  /// Create subscription with current selections
  Future<void> createSubscription() async {
    if (state is! MealSelectionActive) {
      _logger.w('Cannot create subscription - not in selection state');
      return;
    }

    final currentState = state as MealSelectionActive;

    // Validate required fields
    if (currentState.addressId == null || currentState.addressId!.isEmpty) {
      emit(SubscriptionCreationError('Please select a delivery address'));
      return;
    }

    // Validate meal count
    if (currentState.totalSelectedMeals != currentState.requiredMealCount) {
      emit(
        SubscriptionCreationError(
          'Please select exactly ${currentState.requiredMealCount} meals. Currently selected: ${currentState.totalSelectedMeals}',
        ),
      );
      return;
    }

    emit(SubscriptionCreationLoading());

    try {
      // Prepare weeks data for the API request
      final weeks =
          currentState.weekSelections.map((week) {
            return WeekSubscription(
              packageId: week.packageId,
              slots:
                  week
                      .toSlotList()
                      .map((slot) => MealSlotRequest.fromMap(slot))
                      .toList(),
            );
          }).toList();

      // Create subscription parameters
      final params = SubscriptionParams(
        startDate: currentState.startDate,
        durationDays: currentState.durationDays,
        addressId: currentState.addressId!,
        instructions: currentState.instructions,
        noOfPersons: currentState.personCount,
        weeks: weeks,
      );

      // Call the use case to create the subscription
      final result = await _subscriptionUseCase.createSubscription(params);

      result.fold(
        (failure) {
          _logger.e('Failed to create subscription', error: failure);
          emit(
            SubscriptionCreationError(
              failure.message ?? 'Failed to create subscription',
            ),
          );
        },
        (subscription) {
          _logger.i('Subscription created successfully: ${subscription.id}');
          emit(SubscriptionCreationSuccess(subscription: subscription));
        },
      );
    } catch (e) {
      _logger.e('Error creating subscription', error: e);
      emit(SubscriptionCreationError('An unexpected error occurred'));
    }
  }

  // Helper methods

  /// Get day name from weekday (1-7)
  String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[weekday - 1];
  }

  /// Get meal ID for a specific day and meal type from calculated plan
  String _getMealIdForDay(CalculatedPlan plan, DateTime date, String mealType) {
    // Find the daily meal for this date
    final dailyMeal = plan.getMealForDate(date);
    if (dailyMeal == null || dailyMeal.slot.meal == null) {
      return '';
    }

    // Get meal ID based on meal type
    switch (mealType) {
      case 'breakfast':
        return dailyMeal.slot.meal?.breakfastDish?.id ?? '';
      case 'lunch':
        return dailyMeal.slot.meal?.lunchDish?.id ?? '';
      case 'dinner':
        return dailyMeal.slot.meal?.dinnerDish?.id ?? '';
      default:
        return '';
    }
  }
}
