// lib/src/presentation/cubits/meal_plan/meal_distribution_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/model/meal_plan_selection_model.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/presentation/cubits/meal_distributaion/meal_distributaion_state.dart';

class MealDistributionCubit extends Cubit<MealDistributionState> {
  final LoggerService _logger = LoggerService();

  MealDistributionCubit() : super(MealDistributionInitial());

  void initializeDistribution(int totalMeals, DateTime startDate, DateTime endDate) {
    emit(MealDistributionLoading());
    
    final mealTypeAllocation = {
      'Breakfast': 0,
      'Lunch': 0,
      'Dinner': 0,
    };
    
    final currentDistribution = {
      'Breakfast': <MealDistribution>[],
      'Lunch': <MealDistribution>[],
      'Dinner': <MealDistribution>[],
    };
    
    _logger.i('Meal distribution initialized: $totalMeals meals');
    emit(MealDistributing(
      mealTypeAllocation: mealTypeAllocation,
      currentDistribution: currentDistribution,
      totalMeals: totalMeals,
      distributedMeals: 0,
    ));
  }

  void updateMealTypeAllocation(String mealType, int count) {
    if (state is MealDistributing) {
      final currentState = state as MealDistributing;
      
      // Check if the total allocation exceeds the total meals
      int newTotal = 0;
      final updatedAllocation = Map<String, int>.from(currentState.mealTypeAllocation);
      updatedAllocation[mealType] = count;
      
      for (var value in updatedAllocation.values) {
        newTotal += value;
      }
      
      if (newTotal > currentState.totalMeals) {
        emit(MealDistributionError(
          'Total allocation exceeds the available meals (${currentState.totalMeals})'
        ));
        return;
      }
      
      _logger.i('Updated meal type allocation: $mealType = $count');
      emit(MealDistributing(
        mealTypeAllocation: updatedAllocation,
        currentDistribution: currentState.currentDistribution,
        totalMeals: currentState.totalMeals,
        distributedMeals: currentState.distributedMeals,
      ));
    } else {
      emit(MealDistributionError('Meal distribution not initialized'));
    }
  }

  void addMealDistribution(String mealType, DateTime date, String? mealId) {
    if (state is MealDistributing) {
      final currentState = state as MealDistributing;
      
      // Check if there's remaining allocation for this meal type
      final allocation = currentState.mealTypeAllocation[mealType] ?? 0;
      final current = currentState.currentDistribution[mealType]?.length ?? 0;
      
      if (current >= allocation) {
        emit(MealDistributionError(
          'No more allocation available for $mealType'
        ));
        return;
      }
      
      final updatedDistribution = Map<String, List<MealDistribution>>.from(currentState.currentDistribution);
      
      updatedDistribution[mealType] = [
        ...updatedDistribution[mealType] ?? [],
        MealDistributionModel(
          mealType: mealType,
          date: date,
          mealId: mealId,
        ),
      ];
      
      final newDistributedMeals = currentState.distributedMeals + 1;
      
      _logger.i('Added meal distribution: $mealType on ${date.toIso8601String()}');
      emit(MealDistributing(
        mealTypeAllocation: currentState.mealTypeAllocation,
        currentDistribution: updatedDistribution,
        totalMeals: currentState.totalMeals,
        distributedMeals: newDistributedMeals,
      ));
      
      // Check if distribution is complete
      if (newDistributedMeals == currentState.totalMeals) {
        _logger.i('Meal distribution completed');
        emit(MealDistributionCompleted(updatedDistribution));
      }
    } else {
      emit(MealDistributionError('Meal distribution not initialized'));
    }
  }

  void removeMealDistribution(String mealType, int index) {
    if (state is MealDistributing) {
      final currentState = state as MealDistributing;
      
      final updatedDistribution = Map<String, List<MealDistribution>>.from(currentState.currentDistribution);
      
      if (index < 0 || index >= (updatedDistribution[mealType]?.length ?? 0)) {
        emit(MealDistributionError('Invalid meal distribution index'));
        return;
      }
      
      updatedDistribution[mealType]!.removeAt(index);
      
      _logger.i('Removed meal distribution: $mealType at index $index');
      emit(MealDistributing(
        mealTypeAllocation: currentState.mealTypeAllocation,
        currentDistribution: updatedDistribution,
        totalMeals: currentState.totalMeals,
        distributedMeals: currentState.distributedMeals - 1,
      ));
    } else {
      emit(MealDistributionError('Meal distribution not initialized'));
    }
  }

  void completeDistribution() {
    if (state is MealDistributing) {
      final currentState = state as MealDistributing;
      
      int distributedTotal = 0;
      for (var list in currentState.currentDistribution.values) {
        distributedTotal += list.length;
      }
      
      if (distributedTotal != currentState.totalMeals) {
        emit(MealDistributionError(
          'Distribution incomplete: $distributedTotal / ${currentState.totalMeals} meals distributed'
        ));
        return;
      }
      
      _logger.i('Meal distribution completed');
      emit(MealDistributionCompleted(currentState.currentDistribution));
    } else {
      emit(MealDistributionError('Meal distribution not initialized'));
    }
  }

  void resetDistribution() {
    emit(MealDistributionInitial());
  }
}