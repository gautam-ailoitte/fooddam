// lib/src/domain/usecase/meal/meal_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/meal_rep.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';
import 'package:intl/intl.dart';

/// Consolidated Meal Use Case
///
/// This class combines multiple previously separate use cases related to meals:
/// - GetMealByIdUseCase
/// - GetMealsByPreferenceUseCase
/// - GetDishByIdUseCase
/// - Plus new functionality for today's meals
class MealUseCase {
  final MealRepository repository;
  final SubscriptionRepository subscriptionRepository;

  MealUseCase(this.repository, this.subscriptionRepository);

  /// Get a specific meal by ID
  Future<Either<Failure, Meal>> getMealById(String mealId) {
    return repository.getMealById(mealId);
  }

  /// Get meals matching a specific dietary preference
  
  /// Get a specific dish by ID
  Future<Either<Failure, Dish>> getDishById(String dishId) {
    return repository.getDishById(dishId);
  }

  /// Get today's meals based on active subscriptions
  /// 
  /// Note: This is a client-side calculation, not an API call
  /// Get today's meals based on active subscriptions
  Future<Either<Failure, List<MealOrder>>> getTodayMeals() async {
    // Step 1: Get active subscriptions
    final subscriptionsResult = await subscriptionRepository.getActiveSubscriptions();
    
    return subscriptionsResult.fold(
      (failure) => Left(failure),
      (subscriptions) async {
        try {
          // Step 2: Filter active and non-paused subscriptions
          final activeSubscriptions = subscriptions.where(
            (sub) => sub.status == SubscriptionStatus.active && !sub.isPaused
          ).toList();
          
          if (activeSubscriptions.isEmpty) {
            return const Right([]);
          }
          
          // Step 3: Get today's day of week
          final today = DateTime.now();
          final dayOfWeek = DateFormat('EEEE').format(today).toLowerCase();
          
          // Step 4: Create list for today's meal orders
          final List<MealOrder> todayMeals = [];
          
          // Step 5: Process each subscription
          for (final subscription in activeSubscriptions) {
            // Step 6: Find slots for today in this subscription
            final todaySlots = subscription.slots.where(
              (slot) => slot.day.toLowerCase() == dayOfWeek.toLowerCase()
            ).toList();
            
            // Step 7: Process each slot to create a meal order
            for (final slot in todaySlots) {
              if (slot.mealId == null) {
                continue; // Skip slots without a meal
              }
              
              // Step 8: Get meal details
              final mealResult = await repository.getMealById(slot.mealId!);
              
              await mealResult.fold(
                (failure) {
                  // Skip this meal if we can't get details
                  return;
                },
                (meal) async {
                  // Step 9: Calculate delivery time based on slot timing
                  final deliveryTime = _calculateDeliveryTime(today, slot.timing);
                  
                  // Step 10: Determine status based on current time
                  final status = _determineOrderStatus(deliveryTime);
                  
                  // Step 11: Create meal order and add to list
                  final order = MealOrder(
                    id: 'order_${slot.mealId}_${today.millisecondsSinceEpoch}',
                    subscriptionId: subscription.id,
                    mealId: slot.mealId!,
                    mealName: meal.name,
                    mealType: _capitalizeFirst(slot.timing),
                    status: status,
                    orderDate: today,
                    expectedTime: deliveryTime,
                    deliveredAt: status == OrderStatus.delivered ? deliveryTime : null,
                  );
                  
                  todayMeals.add(order);
                },
              );
            }
          }
          
          return Right(todayMeals);
        } catch (e) {
          return Left(Failure as Failure);
        }
      },
    );
  }
  
  // Helper methods
  
  DateTime _calculateDeliveryTime(DateTime baseDate, String mealTiming) {
    switch (mealTiming.toLowerCase()) {
      case 'breakfast':
        return DateTime(baseDate.year, baseDate.month, baseDate.day, 8, 0);
      case 'lunch':
        return DateTime(baseDate.year, baseDate.month, baseDate.day, 12, 30);
      case 'dinner':
        return DateTime(baseDate.year, baseDate.month, baseDate.day, 19, 0);
      default:
        return baseDate;
    }
  }
  
  OrderStatus _determineOrderStatus(DateTime deliveryTime) {
    final now = DateTime.now();
    
    // If delivery time is in the past, mark as delivered
    if (deliveryTime.isBefore(now)) {
      return OrderStatus.delivered;
    }
    
    // Otherwise, it's coming
    return OrderStatus.coming;
  }  /// Capitalize the first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}