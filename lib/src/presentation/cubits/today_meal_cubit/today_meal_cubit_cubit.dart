// lib/src/presentation/cubits/today_meal/today_meal_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/usecase/meal/get_meal_byid_usecase.dart';
import 'package:foodam/src/domain/usecase/subscription/getactivesubscription_usecase.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_state.dart';
import 'package:foodam/src/presentation/utlis/meal_timing_utlil.dart';
import 'package:intl/intl.dart';

class TodayMealCubit extends Cubit<TodayMealState> {
  final GetActiveSubscriptionsUseCase _getActiveSubscriptionsUseCase;
  final GetMealByIdUseCase _getMealByIdUseCase;
  final LoggerService _logger = LoggerService();
  final MealTimingUtil _mealTimingUtil = MealTimingUtil();

  TodayMealCubit({
    required GetActiveSubscriptionsUseCase getActiveSubscriptionsUseCase,
    required GetMealByIdUseCase getMealByIdUseCase,
  }) : 
    _getActiveSubscriptionsUseCase = getActiveSubscriptionsUseCase,
    _getMealByIdUseCase = getMealByIdUseCase,
    super(TodayMealInitial());

  Future<void> getTodayMeals() async {
    emit(TodayMealLoading());
    
    // Get current day of week
    final today = DateTime.now();
    final dayOfWeek = DateFormat('EEEE').format(today).toLowerCase();
    
    _logger.i('Getting meals for today: $dayOfWeek');
    
    // Get active subscriptions
    final subscriptionResult = await _getActiveSubscriptionsUseCase();
    
    await subscriptionResult.fold(
      (failure) {
        _logger.e('Failed to get active subscriptions', error: failure);
        emit(TodayMealError('Failed to load today\'s meals'));
      },
      (subscriptions) async {
        // Process active subscriptions that aren't paused
        final activeSubscriptions = subscriptions.where(
          (sub) => sub.status == SubscriptionStatus.active && !sub.isPaused
        ).toList();
        
        if (activeSubscriptions.isEmpty) {
          _logger.i('No active subscriptions found for today');
          emit(const TodayMealLoaded(
            orders: [],
            ordersByType: {
              'Breakfast': [],
              'Lunch': [],
              'Dinner': [],
            },
            currentMealPeriod: '',
          ));
          return;
        }
        
        // Extract today's slots from the subscriptions
        final todaySlots = _extractTodaySlots(activeSubscriptions, dayOfWeek);
        
        if (todaySlots.isEmpty) {
          _logger.i('No meals found for today');
          emit(const TodayMealLoaded(
            orders: [],
            ordersByType: {
              'Breakfast': [],
              'Lunch': [],
              'Dinner': [],
            },
            currentMealPeriod: '',
          ));
          return;
        }
        
        // Convert slots to meal orders
        final orders = await _convertSlotsToMealOrders(todaySlots);
        
        // Categorize by meal type
        final ordersByType = _categorizeMealsByType(orders);
        
        // Get the current meal period
        final currentPeriod = _mealTimingUtil.getCurrentMealPeriod();
        
        _logger.i('Today\'s meals loaded: ${orders.length} meals');
        emit(TodayMealLoaded(
          orders: orders,
          ordersByType: ordersByType,
          currentMealPeriod: currentPeriod,
        ));
      },
    );
  }
  
  // Extract slots that match today's day of week
  List<Map<String, dynamic>> _extractTodaySlots(
    List<Subscription> subscriptions, 
    String dayOfWeek
  ) {
    final List<Map<String, dynamic>> result = [];
    
    for (final subscription in subscriptions) {
      // Find slots matching today's day of week
      final matchingSlots = subscription.slots.where(
        (slot) => slot.day.toLowerCase() == dayOfWeek.toLowerCase()
      ).toList();
      
      // Add to result with subscription info
      for (final slot in matchingSlots) {
        result.add({
          'slot': slot,
          'subscription': subscription,
        });
      }
    }
    
    return result;
  }
  
  // Convert slots to meal orders
  Future<List<MealOrder>> _convertSlotsToMealOrders(
    List<Map<String, dynamic>> slotData
  ) async {
    final List<MealOrder> result = [];
    
    for (final data in slotData) {
      final slot = data['slot'];
      final subscription = data['subscription'];
      
      if (slot.mealId == null) {
        // Skip slots without a meal ID
        continue;
      }
      
      // Get meal details
      final mealResult = await _getMealByIdUseCase(slot.mealId);
      
      await mealResult.fold(
        (failure) {
          _logger.e('Failed to get meal details for ${slot.mealId}', error: failure);
          // Continue with the next slot
        },
        (meal) async {
          // Calculate delivery time based on meal type
          final now = DateTime.now();
          DateTime deliveryTime;
          
          switch (slot.mealTime.toLowerCase()) {
            case 'breakfast':
              deliveryTime = DateTime(now.year, now.month, now.day, 8, 0);
              break;
            case 'lunch':
              deliveryTime = DateTime(now.year, now.month, now.day, 12, 30);
              break;
            case 'dinner':
              deliveryTime = DateTime(now.year, now.month, now.day, 19, 0);
              break;
            default:
              deliveryTime = now;
          }
          
          // Determine status based on current time
          final OrderStatus status = _determineOrderStatus(deliveryTime);
          
          // Create the meal order
          final order = MealOrder(
            id: 'order_${slot.mealId}_${now.millisecondsSinceEpoch}',
            subscriptionId: subscription.id,
            mealId: slot.mealId,
            mealName: meal.name,
            mealType: _capitalizeFirst(slot.mealTime),
            status: status,
            orderDate: now,
            expectedTime: deliveryTime,
            deliveredAt: status == OrderStatus.delivered ? deliveryTime : null,
          );
          
          result.add(order);
        },
      );
    }
    
    return result;
  }
  
  // Determine order status based on delivery time
  OrderStatus _determineOrderStatus(DateTime deliveryTime) {
    final now = DateTime.now();
    
    // If delivery time is in the past, mark as delivered
    if (deliveryTime.isBefore(now)) {
      return OrderStatus.delivered;
    }
    
    // Otherwise, it's coming
    return OrderStatus.coming;
  }
  
  // Helper to capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

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