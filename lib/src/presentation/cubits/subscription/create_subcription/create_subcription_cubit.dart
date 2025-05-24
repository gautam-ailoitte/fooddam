// lib/src/presentation/cubits/subscription/create_subcription/create_subcription_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/calculated_plan.dart';
import 'package:foodam/src/domain/entities/pacakge_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';
import 'package:foodam/src/domain/usecase/calendar_usecase.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';

import '../../../../data/datasource/remote_data_source.dart';
import 'create_subcription_state.dart';

class SubscriptionCreationCubit extends Cubit<SubscriptionCreationState> {
  final SubscriptionUseCase _subscriptionUseCase;
  final CalendarUseCase _calendarUseCase;
  final LoggerService _logger = LoggerService();

  SubscriptionCreationCubit({
    required SubscriptionUseCase subscriptionUseCase,
    required CalendarUseCase calendarUseCase,
  }) : _subscriptionUseCase = subscriptionUseCase,
       _calendarUseCase = calendarUseCase,
       super(SubscriptionCreationInitial());

  // Step 1: Select package and meal count
  void selectPackageAndMealCount({
    required Package package,
    required int mealCount, // 10, 15, 18, or 21
    required DateTime startDate,
    required int durationDays,
  }) {
    try {
      _logger.i('Selecting package ${package.id} with $mealCount meals/week');

      // Find the price for selected meal count
      final priceOption = package.priceOptions?.firstWhere(
        (option) => option.numberOfMeals == mealCount,
        orElse: () => throw Exception('Invalid meal count selected'),
      );

      emit(
        PackageSelectionActive(
          packageId: package.id,
          selectedMealCount: mealCount,
          pricePerWeek: priceOption!.price,
          startDate: startDate,
          durationDays: durationDays,
        ),
      );

      // Automatically fetch calculated plan
      fetchCalculatedPlan(
        packageId: package.id,
        startDate: startDate,
        durationDays: durationDays,
        dietaryPreference:
            package.isVegetarian ? 'vegetarian' : 'non-vegetarian',
      );
    } catch (e) {
      _logger.e('Error selecting package', error: e);
      emit(
        SubscriptionCreationError('Failed to select package: ${e.toString()}'),
      );
    }
  }

  // Step 2: Fetch calculated plan
  Future<void> fetchCalculatedPlan({
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    required String dietaryPreference,
  }) async {
    final currentPackageData =
        state is PackageSelectionActive
            ? state as PackageSelectionActive
            : null;

    emit(CalculatedPlanLoading());

    try {
      // Calculate the week parameter based on duration
      final week = _calculateWeekFromDuration(durationDays);

      final result = await _calendarUseCase.getCalculatedPlan(
        dietaryPreference: dietaryPreference,
        week: week,
        startDate: startDate,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to get calculated plan', error: failure);
          emit(
            SubscriptionCreationError(
              failure.message ?? 'Failed to get meal plan',
            ),
          );
        },
        (calculatedPlan) {
          _logger.i('Calculated plan loaded successfully');

          // Pass the stored package data instead of casting current state
          _initializeMealSelection(
            calculatedPlan: calculatedPlan,
            packageId: packageId,
            startDate: startDate,
            durationDays: durationDays,
            packageSelectionData: currentPackageData, // Pass the stored data
          );
        },
      );
    } catch (e) {
      _logger.e('Error fetching calculated plan', error: e);
      emit(SubscriptionCreationError('Failed to load meal plan'));
    }
  }

  int _calculateWeekFromDuration(int durationDays) {
    switch (durationDays) {
      case 7: // 1 week
        return 1;
      case 14: // 2 weeks
        return 2;
      case 21: // 3 weeks
        return 3;
      case 28: // 4 weeks
        return 4;
      default:
        // For custom durations, calculate weeks
        return (durationDays / 7).ceil();
    }
  }

  // Initialize meal selection with calculated plan
  // Initialize meal selection with calculated plan - FIXED
  void _initializeMealSelection({
    required CalculatedPlan calculatedPlan,
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    PackageSelectionActive? packageSelectionData,
  }) {
    try {
      if (packageSelectionData == null) {
        emit(SubscriptionCreationError('Package selection data not found'));
        return;
      }

      final endDate = startDate.add(Duration(days: durationDays - 1));
      final numberOfWeeks = (durationDays / 7).ceil();

      // Create week selections based on our duration
      final List<WeekSelection> weekSelections = [];

      for (int weekIndex = 0; weekIndex < numberOfWeeks; weekIndex++) {
        final weekStartDate = startDate.add(Duration(days: weekIndex * 7));
        final weekEndDate = weekStartDate.add(Duration(days: 6));

        // Ensure we don't go past the subscription end date
        final actualWeekEndDate =
            weekEndDate.isAfter(endDate) ? endDate : weekEndDate;

        // Create day selections for this week
        final List<DaySelection> daySelections = [];

        // Calculate days in this week (might be less than 7 for the last week)
        final daysInWeek =
            actualWeekEndDate.difference(weekStartDate).inDays + 1;

        for (int dayIndex = 0; dayIndex < daysInWeek; dayIndex++) {
          final currentDate = weekStartDate.add(Duration(days: dayIndex));
          final dayName = _getDayName(currentDate.weekday);

          // Try to get meals from calculated plan for this date
          final dailyMeal = calculatedPlan.getMealForDate(currentDate);

          // Create meal selections - ALWAYS START UNSELECTED
          final Map<String, MealSelection> mealSelections = {};

          if (dailyMeal?.slot.meal != null) {
            final dayMeal = dailyMeal!.slot.meal!;

            // Create meal options based on available dishes
            mealSelections['breakfast'] = MealSelection(
              mealId: dayMeal.breakfastDish?.id ?? '',
              mealName: dayMeal.breakfastDish?.name,
              isSelected: false, // ALWAYS START UNSELECTED
              isAvailable: dayMeal.breakfastDish != null,
            );

            mealSelections['lunch'] = MealSelection(
              mealId: dayMeal.lunchDish?.id ?? '',
              mealName: dayMeal.lunchDish?.name,
              isSelected: false, // ALWAYS START UNSELECTED
              isAvailable: dayMeal.lunchDish != null,
            );

            mealSelections['dinner'] = MealSelection(
              mealId: dayMeal.dinnerDish?.id ?? '',
              mealName: dayMeal.dinnerDish?.name,
              isSelected: false, // ALWAYS START UNSELECTED
              isAvailable: dayMeal.dinnerDish != null,
            );
          } else {
            // No meals available from API for this day - create placeholder options
            mealSelections['breakfast'] = MealSelection(
              mealId: '',
              mealName: 'Breakfast option',
              isSelected: false,
              isAvailable: true, // Make available so users can select
            );
            mealSelections['lunch'] = MealSelection(
              mealId: '',
              mealName: 'Lunch option',
              isSelected: false,
              isAvailable: true, // Make available so users can select
            );
            mealSelections['dinner'] = MealSelection(
              mealId: '',
              mealName: 'Dinner option',
              isSelected: false,
              isAvailable: true, // Make available so users can select
            );
          }

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
            packageId: packageId,
            weekStartDate: weekStartDate,
            weekEndDate: actualWeekEndDate,
            daySelections: daySelections,
            requiredMealCount: packageSelectionData.selectedMealCount,
          ),
        );
      }

      // Calculate total price
      final totalPrice = packageSelectionData.pricePerWeek * numberOfWeeks;

      emit(
        MealSelectionActive(
          startDate: startDate,
          endDate: endDate,
          durationDays: durationDays,
          packageId: packageId,
          mealCountPerWeek: packageSelectionData.selectedMealCount,
          pricePerWeek: packageSelectionData.pricePerWeek,
          calculatedPlan: calculatedPlan,
          weekSelections: weekSelections,
          totalPrice: totalPrice,
        ),
      );

      _logger.i('Meal selection initialized with $numberOfWeeks weeks');
    } catch (e) {
      _logger.e('Error initializing meal selection', error: e);
      emit(SubscriptionCreationError('Failed to initialize meal selection'));
    }
  }

  // Toggle meal selection
  void toggleMealSelection({
    required int weekIndex,
    required int dayIndex,
    required String mealType,
  }) {
    if (state is! MealSelectionActive) return;

    final currentState = state as MealSelectionActive;

    try {
      // Deep copy week selections
      final updatedWeekSelections = List<WeekSelection>.from(
        currentState.weekSelections.map((week) {
          if (currentState.weekSelections.indexOf(week) == weekIndex) {
            // Update this week
            final updatedDaySelections = List<DaySelection>.from(
              week.daySelections.map((day) {
                if (week.daySelections.indexOf(day) == dayIndex) {
                  // Update this day
                  final updatedMealSelections = Map<String, MealSelection>.from(
                    day.mealSelections,
                  );

                  final currentMeal = updatedMealSelections[mealType]!;

                  // Only toggle if available
                  if (currentMeal.isAvailable) {
                    updatedMealSelections[mealType] = MealSelection(
                      mealId: currentMeal.mealId,
                      mealName: currentMeal.mealName,
                      isSelected: !currentMeal.isSelected,
                      isAvailable: currentMeal.isAvailable,
                    );
                  }

                  return DaySelection(
                    date: day.date,
                    day: day.day,
                    mealSelections: updatedMealSelections,
                  );
                }
                return day;
              }),
            );

            return WeekSelection(
              weekNumber: week.weekNumber,
              packageId: week.packageId,
              weekStartDate: week.weekStartDate,
              weekEndDate: week.weekEndDate,
              daySelections: updatedDaySelections,
              requiredMealCount: week.requiredMealCount,
            );
          }
          return week;
        }),
      );

      emit(currentState.copyWith(weekSelections: updatedWeekSelections));

      _logger.i(
        'Toggled meal: Week ${weekIndex + 1}, Day ${dayIndex + 1}, $mealType',
      );
    } catch (e) {
      _logger.e('Error toggling meal selection', error: e);
    }
  }

  // Update delivery details
  void updateDeliveryDetails({
    int? personCount,
    String? addressId,
    String? instructions,
  }) {
    if (state is! MealSelectionActive) return;

    final currentState = state as MealSelectionActive;

    emit(
      currentState.copyWith(
        personCount: personCount,
        addressId: addressId,
        instructions: instructions,
      ),
    );

    _logger.i('Updated delivery details');
  }

  // Create subscription
  Future<void> createSubscription() async {
    if (state is! MealSelectionActive) return;

    final currentState = state as MealSelectionActive;

    // Validate all weeks have correct meal count
    if (!currentState.isValid) {
      emit(
        SubscriptionCreationError(
          'Please select exactly ${currentState.mealCountPerWeek} meals for each week',
        ),
      );
      return;
    }

    // Validate address
    if (currentState.addressId == null || currentState.addressId!.isEmpty) {
      emit(SubscriptionCreationError('Please select a delivery address'));
      return;
    }

    emit(SubscriptionCreationLoading());

    try {
      // Convert week selections to API format
      final weeks =
          currentState.weekSelections.map((week) {
            return WeekSubscription(
              packageId: week.packageId,
              slots:
                  week.toSlotList().map((slot) {
                    return MealSlotRequest(
                      day: slot['day'] as String,
                      date: DateTime.parse(slot['date'] as String),
                      timing: slot['timing'] as String,
                      dishId: slot['meal'] as String,
                    );
                  }).toList(),
            );
          }).toList();
      final temp = WeekSubscriptionRequest(packageId: '', slots: []);
      final list = <WeekSubscriptionRequest>[];
      // Create subscription parameters
      final params = SubscriptionParams(
        startDate: currentState.startDate,
        durationDays: currentState.durationDays,
        addressId: currentState.addressId!,
        instructions: currentState.instructions,
        noOfPersons: currentState.personCount,
        weeks: list, //todo:
      );

      // Call the use case
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

  // Helper method to get day name
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

  // Reset state
  void resetState() {
    emit(SubscriptionCreationInitial());
  }
}
