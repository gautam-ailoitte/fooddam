// lib/src/presentation/cubits/meal/today_meal_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/usecase/meal_usecase.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_state.dart';

/// Today Meal Cubit
///
/// This cubit manages the state of today's meals.
/// It fetches the meals scheduled for today based on active subscriptions.
class TodayMealCubit extends Cubit<TodayMealState> {
  final MealUseCase _mealUseCase;
  final LoggerService _logger = LoggerService();

  TodayMealCubit({
    required MealUseCase mealUseCase,
  }) : 
    _mealUseCase = mealUseCase,
    super(const TodayMealInitial());

  /// Load today's meals from active subscriptions
  Future<void> loadTodayMeals() async {
    emit(const TodayMealLoading());
    
    final result = await _mealUseCase.getTodayMeals();
    
    result.fold(
      (failure) {
        _logger.e('Failed to get today\'s meals', error: failure);
        emit(TodayMealError(message: 'Failed to load today\'s meals: '));
      },
      (mealOrders) {
        _logger.i('Today\'s meals loaded: ${mealOrders.length} meals');
        
        // Organize meals by type (breakfast, lunch, dinner)
        final mealsByType = _organizeMealsByType(mealOrders);
        
        // Determine the current meal period based on time of day
        final currentPeriod = _getCurrentMealPeriod();
        
        emit(TodayMealLoaded(
          meals: mealOrders,
          mealsByType: mealsByType,
          currentMealPeriod: currentPeriod,
        ));
      },
    );
  }

  /// Get delivery status message for a meal order
  String getDeliveryStatusMessage(MealOrder order) {
    switch (order.status) {
      case OrderStatus.coming:
        return "Coming soon - Expected at ${_formatTime(order.expectedTime)}";
      case OrderStatus.delivered:
        return "Delivered at ${_formatTime(order.deliveredAt!)}";
      case OrderStatus.noMeal:
        return "No meal scheduled for this slot";
      case OrderStatus.notChosen:
        return "No meal selected for this slot";
    }
  }
  
  /// Refresh today's meals
  Future<void> refreshTodayMeals() async {
    // Keep the current state while refreshing
    final currentState = state;
    
    if (currentState is TodayMealLoaded) {
      emit(TodayMealRefreshing(
        meals: currentState.meals,
        mealsByType: currentState.mealsByType,
        currentMealPeriod: currentState.currentMealPeriod,
      ));
    } else {
      emit(const TodayMealLoading());
    }
    
    await loadTodayMeals();
  }
  
  // Helper methods
  
  /// Organize meals by type (breakfast, lunch, dinner)
  Map<String, List<MealOrder>> _organizeMealsByType(List<MealOrder> meals) {
    final Map<String, List<MealOrder>> result = {
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
    };
    
    for (final meal in meals) {
      if (result.containsKey(meal.mealType)) {
        result[meal.mealType]!.add(meal);
      }
    }
    
    return result;
  }
  
  /// Get the current meal period based on time of day
  String _getCurrentMealPeriod() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour < 11) {
      return 'Breakfast';
    } else if (hour < 16) {
      return 'Lunch';
    } else {
      return 'Dinner';
    }
  }
  
  /// Format time for display
  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}