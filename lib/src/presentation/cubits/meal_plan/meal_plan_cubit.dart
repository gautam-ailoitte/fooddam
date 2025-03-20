// lib/src/presentation/cubits/meal_plan/meal_plan_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/service/navigation_state_manager.dart';
import 'package:foodam/src/data/model/meal_plan_selection_model.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';
import 'package:foodam/src/presentation/cubits/meal_plan/meal_plan_state.dart';
/// Manages the meal plan selection process
class MealPlanSelectionCubit extends Cubit<MealPlanSelectionState> {
  final LoggerService _logger = LoggerService();
  final NavigationStateManager _navigationManager = NavigationStateManager();

  MealPlanSelectionCubit() : super(MealPlanSelectionInitial());

  /// Initialize state from navigation manager when returning to a previous screen
  void initializeFromSavedState() {
    final savedPlan = _navigationManager.getSavedPlan();
    final savedMealCount = _navigationManager.getSavedMealCount();
    final savedDurationDays = _navigationManager.getSavedDurationDays();
    final savedStartDate = _navigationManager.getSavedStartDate();
    final savedEndDate = _navigationManager.getSavedEndDate();
    final savedCompletedPlan = _navigationManager.getSavedCompletedPlanSelection();
    
    if (savedCompletedPlan != null) {
      // If we have a completed plan, that's the highest state
      _logger.i('Restoring from completed plan selection');
      emit(MealPlanCompleted(savedCompletedPlan));
    } else if (savedPlan != null && savedMealCount != null && savedDurationDays != null 
        && savedStartDate != null && savedEndDate != null) {
      // If we have all date selection data
      _logger.i('Restoring from dates selection');
      emit(MealPlanDatesSelected(
        selectedPlan: savedPlan,
        duration: '$savedDurationDays days',
        mealCount: savedMealCount,
        durationDays: savedDurationDays,
        startDate: savedStartDate,
        endDate: savedEndDate,
      ));
    } else if (savedPlan != null && savedMealCount != null && savedDurationDays != null) {
      // If we have duration selection data
      _logger.i('Restoring from duration selection');
      emit(MealPlanDurationSelected(
        selectedPlan: savedPlan,
        duration: '$savedDurationDays days',
        mealCount: savedMealCount,
        durationDays: savedDurationDays,
      ));
    } else if (savedPlan != null) {
      // If we only have plan selection
      _logger.i('Restoring from plan selection');
      emit(MealPlanTypeSelected(savedPlan));
    } else {
      // No saved state, remain in initial state
      _logger.i('No saved state to restore');
      emit(MealPlanSelectionInitial());
    }
  }

  /// Select the subscription plan type
  void selectPlanType(SubscriptionPlan plan) {
    _logger.i('Plan type selected: ${plan.name}');
    _navigationManager.savePlanSelectionState(plan);
    emit(MealPlanTypeSelected(plan));
  }

  /// Select the meal count AND duration
  void selectMealCountAndDuration(int mealCount, int durationDays) {
    if (state is MealPlanTypeSelected || state is MealPlanDurationSelected || 
        state is MealPlanDatesSelected || state is MealPlanCompleted) {
      
      SubscriptionPlan selectedPlan;
      
      // Extract the plan from whatever state we're in
      if (state is MealPlanTypeSelected) {
        selectedPlan = (state as MealPlanTypeSelected).selectedPlan;
      } else if (state is MealPlanDurationSelected) {
        selectedPlan = (state as MealPlanDurationSelected).selectedPlan;
      } else if (state is MealPlanDatesSelected) {
        selectedPlan = (state as MealPlanDatesSelected).selectedPlan;
      } else { // MealPlanCompleted
        // For completed state, we need to get from the navigation manager
        selectedPlan = _navigationManager.getSavedPlan()!;
      }
      
      _logger.i('Meal count selected: $mealCount meals for $durationDays days');
      _navigationManager.saveDurationState(mealCount, durationDays);
      
      emit(MealPlanDurationSelected(
        selectedPlan: selectedPlan,
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
    if (state is MealPlanDurationSelected || state is MealPlanDatesSelected || 
        state is MealPlanCompleted) {
      
      SubscriptionPlan selectedPlan;
      int mealCount, durationDays;
      
      // Extract info from current state
      if (state is MealPlanDurationSelected) {
        final currentState = state as MealPlanDurationSelected;
        selectedPlan = currentState.selectedPlan;
        mealCount = currentState.mealCount;
        durationDays = currentState.durationDays;
      } else if (state is MealPlanDatesSelected) {
        final currentState = state as MealPlanDatesSelected;
        selectedPlan = currentState.selectedPlan;
        mealCount = currentState.mealCount;
        durationDays = currentState.durationDays;
      } else { // MealPlanCompleted
        // For completed state, we need to get from the navigation manager
        selectedPlan = _navigationManager.getSavedPlan()!;
        mealCount = _navigationManager.getSavedMealCount()!;
        durationDays = _navigationManager.getSavedDurationDays()!;
      }
      
      // Validate dates
      if (startDate.isAfter(endDate)) {
        emit(MealPlanSelectionError('Start date cannot be after end date'));
        return;
      }
      
      // Validate duration matches the selected duration days
      final actualDays = endDate.difference(startDate).inDays + 1;
      if (actualDays != durationDays) {
        emit(MealPlanSelectionError(
          'Selected dates should span exactly $durationDays days'
        ));
        return;
      }
      
      _logger.i('Dates selected: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      _navigationManager.saveDateSelectionState(startDate, endDate);
      
      emit(MealPlanDatesSelected(
        selectedPlan: selectedPlan,
        duration: '$durationDays days',
        mealCount: mealCount,
        durationDays: durationDays,
        startDate: startDate,
        endDate: endDate,
      ));
    } else {
      emit(MealPlanSelectionError('Please select meal count and duration first'));
    }
  }

  /// Complete the meal plan selection with the meal distribution
  void completeMealPlanSelection(Map<String, List<MealDistribution>> mealDistribution) {
    if (state is MealPlanDatesSelected || state is MealPlanCompleted) {
      SubscriptionPlan selectedPlan;
      String duration;
      int mealCount;
      DateTime startDate, endDate;
      
      if (state is MealPlanDatesSelected) {
        final currentState = state as MealPlanDatesSelected;
        selectedPlan = currentState.selectedPlan;
        duration = currentState.duration;
        mealCount = currentState.mealCount;
        startDate = currentState.startDate;
        endDate = currentState.endDate;
      } else { // MealPlanCompleted
        final savedPlan = _navigationManager.getSavedPlan();
        final savedMealCount = _navigationManager.getSavedMealCount();
        final savedDurationDays = _navigationManager.getSavedDurationDays();
        final savedStartDate = _navigationManager.getSavedStartDate();
        final savedEndDate = _navigationManager.getSavedEndDate();
        
        if (savedPlan == null || savedMealCount == null || savedDurationDays == null ||
            savedStartDate == null || savedEndDate == null) {
          emit(MealPlanSelectionError('Missing required plan information. Please restart the process.'));
          return;
        }
        
        selectedPlan = savedPlan;
        duration = '$savedDurationDays days';
        mealCount = savedMealCount;
        startDate = savedStartDate;
        endDate = savedEndDate;
      }
      
      try {
        // Create the meal plan selection with distributed meals
        final mealPlanSelection = MealPlanSelectionModel(
          planType: selectedPlan.name,
          duration: duration,
          startDate: startDate,
          endDate: endDate,
          totalMeals: mealCount,
          mealDistribution: _convertToMealDistributionModel(mealDistribution),
        );
        
        _logger.i('Meal plan selection completed with ${_getTotalDistributedMeals(mealDistribution)} meals');
        
        // Assign meal IDs based on weekly template (this would normally be done by the backend)
        _assignMealIdsFromWeeklyTemplate(mealPlanSelection);
        
        // Save to navigation manager
        _navigationManager.saveCompletedPlanSelection(mealPlanSelection);
        
        emit(MealPlanCompleted(mealPlanSelection));
      } catch (e) {
        _logger.e('Error completing meal plan selection', error: e);
        emit(MealPlanSelectionError('Failed to complete meal plan selection: ${e.toString()}'));
      }
    } else {
      emit(MealPlanSelectionError('Please complete all previous steps first'));
    }
  }

  // Helper method to convert distribution to model
  Map<String, List<MealDistributionModel>> _convertToMealDistributionModel(
    Map<String, List<MealDistribution>> mealDistribution
  ) {
    Map<String, List<MealDistributionModel>> result = {};
    
    mealDistribution.forEach((key, value) {
      result[key] = value.map((dist) {
        if (dist is MealDistributionModel) {
          return dist;
        } else {
          return MealDistributionModel(
            mealType: dist.mealType,
            date: dist.date,
            mealId: dist.mealId,
          );
        }
      }).toList();
    });
    
    return result;
  }
  
  // Helper method to get total distributed meals
  int _getTotalDistributedMeals(Map<String, List<MealDistribution>> mealDistribution) {
    int total = 0;
    mealDistribution.forEach((_, list) => total += list.length);
    return total;
  }
  
  // Assign meal IDs based on the weekly template (simulated for demo purposes)
  void _assignMealIdsFromWeeklyTemplate(MealPlanSelectionModel mealPlanSelection) {
    // This would normally use the weekly template from the backend
    // For demo purposes, we'll just set a pattern based on day of week and meal type
    
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
    
    for (var mealType in mealTypes) {
      if (mealPlanSelection.mealDistribution.containsKey(mealType)) {
        final distributions = mealPlanSelection.mealDistribution[mealType]!;
        
        for (var i = 0; i < distributions.length; i++) {
          final dist = distributions[i] as MealDistributionModel;
          final dayOfWeek = dist.date.weekday; // 1 = Monday, 7 = Sunday
          
          // Format: meal_[mealType]_[dayOfWeek]
          // This is just for demo - in real app, it would use the actual meal IDs from backend
          final mealId = 'meal_${mealType.toLowerCase()}_$dayOfWeek';
          
          // Update the distribution with the meal ID
          distributions[i] = MealDistributionModel(
            mealType: dist.mealType,
            date: dist.date,
            mealId: mealId,
          );
        }
      }
    }
  }

  void resetSelection() {
    _navigationManager.resetNavigationState();
    emit(MealPlanSelectionInitial());
  }
}