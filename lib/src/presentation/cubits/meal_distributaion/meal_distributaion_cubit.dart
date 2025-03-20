// lib/src/presentation/cubits/meal_distributaion/meal_distributaion_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/model/meal_plan_selection_model.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/presentation/cubits/meal_distributaion/meal_distributaion_state.dart';

class MealDistributionCubit extends Cubit<MealDistributionState> {
  final LoggerService _logger = LoggerService();

  // Keep track of total meals for validation
  int _totalMeals = 0;

  MealDistributionCubit() : super(MealDistributionInitial());

  void initializeDistribution(int totalMeals, DateTime startDate, DateTime endDate) {
    emit(MealDistributionLoading());
    
    _totalMeals = totalMeals;
    
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
      
      if (newTotal > _totalMeals) {
        emit(MealDistributionError(
          'Total allocation exceeds the available meals ($_totalMeals)'
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
    } else if (state is MealDistributionCompleted) {
      // Allow modifications even after distribution is complete
      final completedState = state as MealDistributionCompleted;
      
      // Convert back to Distributing state for updates
      final currentDistribution = Map<String, List<MealDistribution>>.from(completedState.distribution);
      
      final mealTypeAllocation = {
        'Breakfast': currentDistribution['Breakfast']?.length ?? 0,
        'Lunch': currentDistribution['Lunch']?.length ?? 0,
        'Dinner': currentDistribution['Dinner']?.length ?? 0,
      };
      
      // Update the specific meal type allocation
      mealTypeAllocation[mealType] = count;
      
      // Calculate total distributed meals
      int distributedMeals = 0;
      mealTypeAllocation.values.forEach((count) => distributedMeals += count);
      
      emit(MealDistributing(
        mealTypeAllocation: mealTypeAllocation,
        currentDistribution: currentDistribution,
        totalMeals: _totalMeals,
        distributedMeals: distributedMeals,
      ));
    } else {
      emit(MealDistributionError('Meal distribution not initialized'));
    }
  }

  void addMealDistribution(String mealType, DateTime date, String? mealId) {
    if (state is MealDistributing) {
      final currentState = state as MealDistributing;
      
      // Verify allocation for this meal type
      final allocation = currentState.mealTypeAllocation[mealType] ?? 0;
      final current = currentState.currentDistribution[mealType]?.length ?? 0;
      
      // Check if this would exceed the allocation
      if (current >= allocation) {
        // Instead of error, just log a warning and proceed
        _logger.w('Allocation limit reached for $mealType but proceeding with update');
      }
      
      final updatedDistribution = Map<String, List<MealDistribution>>.from(currentState.currentDistribution);
      
      // Check if this date already exists for this meal type
      bool dateExists = false;
      if (updatedDistribution[mealType] != null) {
        dateExists = updatedDistribution[mealType]!.any((dist) => 
          dist.date.year == date.year && 
          dist.date.month == date.month && 
          dist.date.day == date.day
        );
      }
      
      if (dateExists) {
        _logger.i('Date already exists for this meal type, skipping');
        return;
      }
      
      updatedDistribution[mealType] = [
        ...updatedDistribution[mealType] ?? [],
        MealDistributionModel(
          mealType: mealType,
          date: date,
          mealId: mealId,
        ),
      ];
      
      // Recalculate total distributed meals
      int newDistributedMeals = 0;
      updatedDistribution.forEach((_, distributions) {
        newDistributedMeals += distributions.length;
      });
      
      _logger.i('Added meal distribution: $mealType on ${date.toIso8601String()}');
      emit(MealDistributing(
        mealTypeAllocation: currentState.mealTypeAllocation,
        currentDistribution: updatedDistribution,
        totalMeals: currentState.totalMeals,
        distributedMeals: newDistributedMeals,
      ));
    } else if (state is MealDistributionCompleted) {
      // Allow adding even in completed state - convert back to distributing first
      final completedState = state as MealDistributionCompleted;
      
      final updatedDistribution = Map<String, List<MealDistribution>>.from(completedState.distribution);
      
      // Add the new distribution
      updatedDistribution[mealType] = [
        ...updatedDistribution[mealType] ?? [],
        MealDistributionModel(
          mealType: mealType,
          date: date,
          mealId: mealId,
        ),
      ];
      
      // Calculate meal type allocations
      final mealTypeAllocation = {
        'Breakfast': updatedDistribution['Breakfast']?.length ?? 0,
        'Lunch': updatedDistribution['Lunch']?.length ?? 0,
        'Dinner': updatedDistribution['Dinner']?.length ?? 0,
      };
      
      // Calculate total distributed meals
      int newDistributedMeals = 0;
      updatedDistribution.forEach((_, distributions) {
        newDistributedMeals += distributions.length;
      });
      
      _logger.i('Added meal distribution to completed state: $mealType on ${date.toIso8601String()}');
      emit(MealDistributing(
        mealTypeAllocation: mealTypeAllocation,
        currentDistribution: updatedDistribution,
        totalMeals: _totalMeals,
        distributedMeals: newDistributedMeals,
      ));
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
      
      // Update the allocation accordingly
      final updatedAllocation = Map<String, int>.from(currentState.mealTypeAllocation);
      updatedAllocation[mealType] = updatedDistribution[mealType]!.length;
      
      // Recalculate total distributed meals
      int newDistributedMeals = 0;
      updatedDistribution.forEach((_, distributions) {
        newDistributedMeals += distributions.length;
      });
      
      _logger.i('Removed meal distribution: $mealType at index $index');
      emit(MealDistributing(
        mealTypeAllocation: updatedAllocation,
        currentDistribution: updatedDistribution,
        totalMeals: currentState.totalMeals,
        distributedMeals: newDistributedMeals,
      ));
    } else if (state is MealDistributionCompleted) {
      // Allow removing even in completed state
      final completedState = state as MealDistributionCompleted;
      
      final updatedDistribution = Map<String, List<MealDistribution>>.from(completedState.distribution);
      
      if (index < 0 || index >= (updatedDistribution[mealType]?.length ?? 0)) {
        emit(MealDistributionError('Invalid meal distribution index'));
        return;
      }
      
      updatedDistribution[mealType]!.removeAt(index);
      
      // Calculate meal type allocations
      final mealTypeAllocation = {
        'Breakfast': updatedDistribution['Breakfast']?.length ?? 0,
        'Lunch': updatedDistribution['Lunch']?.length ?? 0,
        'Dinner': updatedDistribution['Dinner']?.length ?? 0,
      };
      
      // Calculate total distributed meals
      int newDistributedMeals = 0;
      updatedDistribution.forEach((_, distributions) {
        newDistributedMeals += distributions.length;
      });
      
      _logger.i('Removed meal distribution from completed state: $mealType at index $index');
      emit(MealDistributing(
        mealTypeAllocation: mealTypeAllocation,
        currentDistribution: updatedDistribution,
        totalMeals: _totalMeals,
        distributedMeals: newDistributedMeals,
      ));
    } else {
      emit(MealDistributionError('Meal distribution not initialized'));
    }
  }

  void completeDistribution() {
    if (state is MealDistributing) {
      final currentState = state as MealDistributing;
      
      // No longer require all meals to be distributed
      int distributedTotal = 0;
      for (var list in currentState.currentDistribution.values) {
        distributedTotal += list.length;
      }
      
      // Warn if distribution is incomplete but allow to proceed
      if (distributedTotal < currentState.totalMeals) {
        _logger.w('Incomplete distribution: $distributedTotal / ${currentState.totalMeals} meals distributed');
      }
      
      // At least one meal should be distributed
      if (distributedTotal == 0) {
        emit(MealDistributionError('Please select at least one meal before continuing'));
        return;
      }
      
      _logger.i('Meal distribution completed with $distributedTotal / ${currentState.totalMeals} meals');
      emit(MealDistributionCompleted(currentState.currentDistribution));
    } else {
      emit(MealDistributionError('Meal distribution not initialized'));
    }
  }

  void resetDistribution() {
    _totalMeals = 0;
    emit(MealDistributionInitial());
  }
  
  // Helper method to get a distribution by meal type and date
  MealDistribution? getDistributionByDate(String mealType, DateTime date) {
    if (state is MealDistributing) {
      final currentState = state as MealDistributing;
      final distributions = currentState.currentDistribution[mealType];
      
      if (distributions != null) {
        return distributions.firstWhere(
          (dist) => 
            dist.date.year == date.year && 
            dist.date.month == date.month && 
            dist.date.day == date.day,
          orElse: () => null as MealDistribution,
        );
      }
    } else if (state is MealDistributionCompleted) {
      final completedState = state as MealDistributionCompleted;
      final distributions = completedState.distribution[mealType];
      
      if (distributions != null) {
        return distributions.firstWhere(
          (dist) => 
            dist.date.year == date.year && 
            dist.date.month == date.month && 
            dist.date.day == date.day,
          orElse: () => null as MealDistribution,
        );
      }
    }
    
    return null;
  }
}