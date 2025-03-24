// lib/src/presentation/cubits/meal/meal_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/usecase/meal_usecase.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/presentation/cubits/meal/meal_state.dart';

/// Consolidated Meal Cubit
///
/// This class combines multiple previously separate cubits:
/// - MealCubit
/// - TodayMealCubit
class MealCubit extends Cubit<MealState> {
  final MealUseCase _mealUseCase;
  final SubscriptionUseCase _subscriptionUseCase;
  final LoggerService _logger = LoggerService();

  MealCubit({
    required MealUseCase mealUseCase,
    required SubscriptionUseCase subscriptionUseCase,
  }) : 
    _mealUseCase = mealUseCase,
    _subscriptionUseCase = subscriptionUseCase,
    super(const MealInitial());

  /// Get a specific meal by ID
  Future<void> getMealById(String mealId) async {
    emit(const MealLoading());
    
    final result = await _mealUseCase.getMealById(mealId);
    
    result.fold(
      (failure) {
        _logger.e('Failed to get meal details', error: failure);
        emit(MealError(message: 'Failed to load meal details'));
      },
      (meal) {
        _logger.i('Meal details loaded: ${meal.id}');
        emit(MealLoaded(meal: meal));
      },
    );
  }
  
  /// Get all meals for today based on active subscriptions
  Future<void> getTodayMeals() async {
    emit(const MealLoading());
    
    // First, get active subscriptions
    final subscriptionResult = await _subscriptionUseCase.getActiveSubscriptions();
    
    await subscriptionResult.fold(
      (failure) {
        _logger.e('Failed to get active subscriptions', error: failure);
        emit(MealError(message: 'Failed to load today\'s meals'));
      },
      (subscriptions) async {
        // Then get today's meals based on these subscriptions
        final mealsResult = await _mealUseCase.getTodayMeals();
        
        mealsResult.fold(
          (failure) {
            _logger.e('Failed to get today\'s meals', error: failure);
            emit(MealError(message: 'Failed to process today\'s meals'));
          },
          (mealOrders) {
            _logger.i('Today\'s meals loaded: ${mealOrders.length} meals');
            
            // Categorize meals by type
            final mealsByType = _categorizeMealsByType(mealOrders);
            
            // Determine current meal period
            final currentPeriod = _getCurrentMealPeriod();
            
            emit(TodayMealsLoaded(
              orders: mealOrders,
              mealsByType: mealsByType,
              currentMealPeriod: currentPeriod,
            ));
          },
        );
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
  
  /// Store meals for later use
  void cacheMeals(List<Meal> meals) {
    if (meals.isEmpty) {
      return;
    }
    
    _logger.i('Caching ${meals.length} meals for later use');
    emit(MealListLoaded(meals: meals));
  }
  
  // Helper methods
  
  /// Categorize meal orders by type (breakfast, lunch, dinner)
  Map<String, List<MealOrder>> _categorizeMealsByType(List<MealOrder> orders) {
    final Map<String, List<MealOrder>> result = {
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
    };
    
    for (var order in orders) {
      if (result.containsKey(order.mealType)) {
        result[order.mealType]!.add(order);
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