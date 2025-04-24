// lib/src/presentation/cubits/orders/orders_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final SubscriptionUseCase _subscriptionUseCase;
  final LoggerService _logger = LoggerService();

  OrdersCubit({required SubscriptionUseCase subscriptionUseCase})
    : _subscriptionUseCase = subscriptionUseCase,
      super(const OrdersInitial());

  /// Load all orders data at once (upcoming and past)
  Future<void> loadAllOrders() async {
    try {
      _logger.d('Loading all orders data at once', tag: 'OrdersCubit');
      emit(const OrdersLoading());

      // Load upcoming orders (which include today's orders)
      final upcomingResult = await _subscriptionUseCase.getUpcomingOrders();

      // Also load past orders in parallel
      final pastResult = await _subscriptionUseCase.getPastOrders();

      // Process both results
      final upcomingOrders = upcomingResult.fold((failure) {
        _logger.e('Failed to get upcoming orders', error: failure);
        return <Order>[];
      }, (orders) => orders);

      final pastOrders = pastResult.fold((failure) {
        _logger.e('Failed to get past orders', error: failure);
        return <Order>[];
      }, (orders) => orders);

      // Process the data if we have it
      if (upcomingResult.isRight() || pastResult.isRight()) {
        _processOrderData(upcomingOrders, pastOrders);
      } else {
        emit(const OrdersError(message: 'Failed to load order data'));
      }
    } catch (e) {
      _logger.e('Unexpected error loading orders', error: e);
      emit(OrdersError(message: 'An unexpected error occurred: $e'));
    }
  }

  void _processOrderData(List<Order> upcomingOrders, List<Order> pastOrders) {
    try {
      // Filter today's orders from upcoming orders
      final now = DateTime.now();
      final todayOrders =
          upcomingOrders
              .where(
                (order) =>
                    order.date.year == now.year &&
                    order.date.month == now.month &&
                    order.date.day == now.day,
              )
              .toList();

      // Group orders by appropriate criteria
      final ordersByType = _groupOrdersByType(todayOrders);
      final currentPeriod = _getCurrentMealPeriod();

      // Group upcoming orders by date
      final upcomingOrdersByDate = _subscriptionUseCase.groupOrdersByDate(
        upcomingOrders,
      );

      // Group past orders by date
      final pastOrdersByDate = _subscriptionUseCase.groupOrdersByDate(
        pastOrders,
      );

      // Determine current meal period delivery status
      final upcomingDeliveriesToday =
          todayOrders
              .where((order) => order.status == OrderStatus.coming)
              .toList();

      // Emit consolidated state with all data
      emit(
        OrdersDataLoaded(
          todayOrders: todayOrders,
          ordersByType: ordersByType,
          currentMealPeriod: currentPeriod,
          upcomingOrders: upcomingOrders,
          upcomingOrdersByDate: upcomingOrdersByDate,
          pastOrders: pastOrders,
          pastOrdersByDate: pastOrdersByDate,
          upcomingDeliveriesToday: upcomingDeliveriesToday,
        ),
      );

      _logger.i('Successfully loaded all order data', tag: 'OrdersCubit');
    } catch (e) {
      _logger.e('Error processing order data', error: e);
      emit(OrdersError(message: 'Error processing order data: $e'));
    }
  }

  // Helper method to group orders by meal type
  Map<String, List<Order>> _groupOrdersByType(List<Order> orders) {
    final Map<String, List<Order>> result = {
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
    };

    for (final order in orders) {
      final mealType = order.mealType;
      if (result.containsKey(mealType)) {
        result[mealType]!.add(order);
      }
    }

    return result;
  }

  // Helper to determine current meal period based on time of day
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
}
