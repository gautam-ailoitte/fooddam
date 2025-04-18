// lib/src/presentation/cubits/orders/orders_cubit.dart
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

  /// Load today's orders
  Future<void> loadTodayOrders() async {
    emit(const OrdersLoading());

    final result = await _subscriptionUseCase.getTodayOrders();

    result.fold(
      (failure) {
        _logger.e('Failed to get today\'s orders', error: failure);
        emit(OrdersError(message: 'Failed to load today\'s orders'));
      },
      (orders) {
        _logger.i('Today\'s orders loaded: ${orders.length} orders');

        // Group orders by meal type (breakfast, lunch, dinner)
        final ordersByType = _groupOrdersByType(orders);

        // Determine the current meal period
        final currentPeriod = _getCurrentMealPeriod();

        emit(
          TodayOrdersLoaded(
            orders: orders,
            ordersByType: ordersByType,
            currentMealPeriod: currentPeriod,
          ),
        );
      },
    );
  }

  /// Load upcoming orders
  Future<void> loadUpcomingOrders() async {
    emit(const OrdersLoading());

    final result = await _subscriptionUseCase.getUpcomingOrders();

    result.fold(
      (failure) {
        _logger.e('Failed to get upcoming orders', error: failure);
        emit(OrdersError(message: 'Failed to load upcoming orders'));
      },
      (orders) {
        _logger.i('Upcoming orders loaded: ${orders.length} orders');

        // Sort orders by date
        final sortedOrders = _subscriptionUseCase.sortOrders(orders);

        // Group orders by date
        final ordersByDate = _subscriptionUseCase.groupOrdersByDate(
          sortedOrders,
        );

        emit(
          UpcomingOrdersLoaded(
            orders: sortedOrders,
            ordersByDate: ordersByDate,
          ),
        );
      },
    );
  }

  /// Load past orders
  Future<void> loadPastOrders() async {
    emit(const OrdersLoading());

    final result = await _subscriptionUseCase.getPastOrders();

    result.fold(
      (failure) {
        _logger.e('Failed to get past orders', error: failure);
        emit(OrdersError(message: 'Failed to load order history'));
      },
      (orders) {
        _logger.i('Past orders loaded: ${orders.length} orders');

        // Sort orders by date (most recent first)
        final sortedOrders = List<Order>.from(orders);
        sortedOrders.sort((a, b) => b.date.compareTo(a.date));

        // Group orders by date
        final ordersByDate = _subscriptionUseCase.groupOrdersByDate(
          sortedOrders,
        );

        emit(
          PastOrdersLoaded(orders: sortedOrders, ordersByDate: ordersByDate),
        );
      },
    );
  }

  /// Get delivery status message for an order
  String getDeliveryStatusMessage(Order order) {
    switch (order.status) {
      case OrderStatus.coming:
        return "Coming soon - Expected at ${_formatTime(order.date, order.timing)}";
      case OrderStatus.delivered:
        return "Delivered at ${_formatTime(order.deliveredAt ?? order.date, order.timing)}";
      case OrderStatus.noMeal:
        return "No meal scheduled";
      case OrderStatus.notChosen:
        return "No meal selected";
    }
  }

  // Helper methods

  /// Group orders by meal type (breakfast, lunch, dinner)
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
  String _formatTime(DateTime time, String mealType) {
    // Estimate delivery time based on meal timing
    DateTime estimatedTime;

    if (mealType.toLowerCase() == 'breakfast') {
      estimatedTime = DateTime(time.year, time.month, time.day, 8, 0);
    } else if (mealType.toLowerCase() == 'lunch') {
      estimatedTime = DateTime(time.year, time.month, time.day, 12, 30);
    } else {
      estimatedTime = DateTime(time.year, time.month, time.day, 19, 0);
    }

    final hour =
        estimatedTime.hour > 12 ? estimatedTime.hour - 12 : estimatedTime.hour;
    final period = estimatedTime.hour >= 12 ? 'PM' : 'AM';
    final minute = estimatedTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
