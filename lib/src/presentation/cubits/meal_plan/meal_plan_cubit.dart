// lib/src/presentation/cubits/meal_plan/meal_plan_selection_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/model/meal_plan_selection_model.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_state.dart';
import 'package:foodam/src/presentation/utlis/plan_duration_calcluator.dart';


class MealPlanSelectionCubit extends Cubit<MealPlanSelectionState> {
  final LoggerService _logger = LoggerService();
  final PlanDurationCalculator _durationCalculator = PlanDurationCalculator();

  MealPlanSelectionCubit() : super(MealPlanSelectionInitial());

  void selectPlanType(SubscriptionPlan plan) {
    _logger.i('Plan type selected: ${plan.name}');
    emit(MealPlanTypeSelected(plan));
  }

  void selectDuration(String duration, int mealCount) {
    if (state is MealPlanTypeSelected) {
      final currentState = state as MealPlanTypeSelected;
      
      _logger.i('Duration selected: $duration with $mealCount meals');
      emit(MealPlanDurationSelected(
        selectedPlan: currentState.selectedPlan,
        duration: duration,
        mealCount: mealCount,
      ));
    } else {
      emit(MealPlanSelectionError('Please select a plan type first'));
    }
  }

  void selectDates(DateTime startDate, DateTime endDate) {
    if (state is MealPlanDurationSelected) {
      final currentState = state as MealPlanDurationSelected;
      
      // Validate dates
      if (startDate.isAfter(endDate)) {
        emit(MealPlanSelectionError('Start date cannot be after end date'));
        return;
      }
      
      // Validate duration
      final expectedDays = _durationCalculator.getDurationDays(currentState.duration);
      final actualDays = endDate.difference(startDate).inDays + 1;
      
      if (expectedDays != actualDays) {
        emit(MealPlanSelectionError(
          'Selected dates don\'t match the duration of ${currentState.duration}'
        ));
        return;
      }
      
      _logger.i('Dates selected: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      emit(MealPlanDatesSelected(
        selectedPlan: currentState.selectedPlan,
        duration: currentState.duration,
        mealCount: currentState.mealCount,
        startDate: startDate,
        endDate: endDate,
      ));
    } else {
      emit(MealPlanSelectionError('Please select a plan duration first'));
    }
  }

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