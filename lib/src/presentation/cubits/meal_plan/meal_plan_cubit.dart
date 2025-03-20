// lib/src/presentation/cubits/meal_plan/meal_plan_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/model/meal_plan_selection_model.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_state.dart';
import 'package:foodam/src/presentation/utlis/plan_duration_calcluator.dart';

/// Manages the meal plan selection process
class MealPlanSelectionCubit extends Cubit<MealPlanSelectionState> {
  final LoggerService _logger = LoggerService();
  final PlanDurationCalculator _durationCalculator = PlanDurationCalculator();

  MealPlanSelectionCubit() : super(MealPlanSelectionInitial());

  /// Select the subscription plan type
  void selectPlanType(SubscriptionPlan plan) {
    _logger.i('Plan type selected: ${plan.name}');
    emit(MealPlanTypeSelected(plan));
  }

  /// Select the meal count AND duration (now separately handled)
  void selectMealCountAndDuration(int mealCount, int durationDays) {
    if (state is MealPlanTypeSelected) {
      final currentState = state as MealPlanTypeSelected;
      
      _logger.i('Meal count selected: $mealCount meals for $durationDays days');
      emit(MealPlanDurationSelected(
        selectedPlan: currentState.selectedPlan,
        duration: '$durationDays days',
        mealCount: mealCount,
        durationDays: durationDays,
      ));
    } else {
      emit(MealPlanSelectionError('Please select a plan type first'));
    }
  }

  /// Select the start and end dates for the plan
  void selectDates(DateTime startDate, DateTime endDate) {
    if (state is MealPlanDurationSelected) {
      final currentState = state as MealPlanDurationSelected;
      
      // Validate dates
      if (startDate.isAfter(endDate)) {
        emit(MealPlanSelectionError('Start date cannot be after end date'));
        return;
      }
      
      // Validate duration matches the selected duration days
      final actualDays = endDate.difference(startDate).inDays + 1;
      if (actualDays != currentState.durationDays) {
        emit(MealPlanSelectionError(
          'Selected dates should span exactly ${currentState.durationDays} days'
        ));
        return;
      }
      
      _logger.i('Dates selected: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      emit(MealPlanDatesSelected(
        selectedPlan: currentState.selectedPlan,
        duration: currentState.duration,
        mealCount: currentState.mealCount,
        durationDays: currentState.durationDays,
        startDate: startDate,
        endDate: endDate,
      ));
    } else {
      emit(MealPlanSelectionError('Please select meal count and duration first'));
    }
  }

  /// Complete the meal plan selection with the meal distribution
  void completeMealPlanSelection(Map<String, List<MealDistribution>> mealDistribution) {
    if (state is MealPlanDatesSelected) {
      final currentState = state as MealPlanDatesSelected;
      
      try {
        final mealPlanSelection = MealPlanSelectionModel(
          planType: currentState.selectedPlan.name,
          duration: currentState.duration,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          totalMeals: currentState.mealCount,
          mealDistribution: _convertToMealDistributionModel(mealDistribution),
        );
        
        _logger.i('Meal plan selection completed');
        emit(MealPlanCompleted(mealPlanSelection));
      } catch (e) {
        _logger.e('Error completing meal plan selection', error: e);
        emit(MealPlanSelectionError('Failed to complete meal plan selection'));
      }
    } else {
      emit(MealPlanSelectionError('Please complete all previous steps first'));
    }
  }

  Map<String, List<MealDistributionModel>> _convertToMealDistributionModel(
    Map<String, List<MealDistribution>> mealDistribution
  ) {
    Map<String, List<MealDistributionModel>> result = {};
    
    mealDistribution.forEach((key, value) {
      result[key] = value.map((dist) => dist as MealDistributionModel).toList();
    });
    
    return result;
  }

  void resetSelection() {
    emit(MealPlanSelectionInitial());
  }
}