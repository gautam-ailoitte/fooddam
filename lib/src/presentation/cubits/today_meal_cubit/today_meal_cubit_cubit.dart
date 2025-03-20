// lib/src/presentation/cubits/today_meals/today_meals_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/usecase/order/get_today_mealorder_usecase.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_state.dart';
import 'package:foodam/src/presentation/utlis/meal_timing_utlil.dart';

class TodayMealsCubit extends Cubit<TodayMealsState> {
  final GetTodayMealOrdersUseCase _getTodayMealOrdersUseCase;
  final LoggerService _logger = LoggerService();
  final MealTimingUtil _mealTimingUtil = MealTimingUtil();

  TodayMealsCubit({
    required GetTodayMealOrdersUseCase getTodayMealOrdersUseCase,
  }) : 
    _getTodayMealOrdersUseCase = getTodayMealOrdersUseCase,
    super(TodayMealsInitial());

  Future<void> getTodayMeals() async {
    emit(TodayMealsLoading());
    
    final result = await _getTodayMealOrdersUseCase();
    
    result.fold(
     // lib/src/presentation/cubits/today_meals/today_meals_cubit.dart (continued)
      (failure) {
        _logger.e('Failed to get today\'s meals', error: failure);
        emit(TodayMealsError('Failed to load today\'s meals'));
      },
      (orders) {
        final ordersByType = _categorizeMealsByType(orders);
        _logger.i('Today\'s meals loaded: ${orders.length} meals');
        emit(TodayMealsLoaded(orders: orders, ordersByType: ordersByType));
      },
    );
  }

  Map<String, List<MealOrder>> _categorizeMealsByType(List<MealOrder> orders) {
    Map<String, List<MealOrder>> result = {
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
  
  String getDeliveryStatusMessage(MealOrder order) {
    switch (order.status) {
      case OrderStatus.coming:
        return "Coming soon - Expected at ${_mealTimingUtil.formatTime(order.expectedTime)}";
      case OrderStatus.delivered:
        return "Delivered at ${_mealTimingUtil.formatTime(order.deliveredAt!)}";
      case OrderStatus.noMeal:
        return "No meal scheduled for this slot";
      case OrderStatus.notChosen:
        return "No meal selected for this slot";
      }
  }
}