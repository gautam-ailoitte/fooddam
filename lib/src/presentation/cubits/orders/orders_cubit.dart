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
  bool _isClosed = false;

  OrdersCubit({required SubscriptionUseCase subscriptionUseCase})
    : _subscriptionUseCase = subscriptionUseCase,
      super(const OrdersInitial());

  @override
  Future<void> close() {
    _logger.d('OrdersCubit being closed', tag: 'OrdersCubit');
    _isClosed = true;
    return super.close();
  }

  // Safe emit that checks if cubit is closed before emitting
  void _safeEmit(OrdersState state) {
    if (!_isClosed) {
      try {
        emit(state);
      } catch (e) {
        _logger.e('Error emitting state: $e', tag: 'OrdersCubit');
      }
    } else {
      _logger.w(
        'Attempted to emit state when cubit is closed',
        tag: 'OrdersCubit',
      );
    }
  }

  /// Load today's orders
  Future<void> loadTodayOrders() async {
    _logger.d('Loading today orders', tag: 'OrdersCubit');

    if (_isClosed) {
      _logger.w(
        'Skipping loadTodayOrders - cubit is closed',
        tag: 'OrdersCubit',
      );
      return;
    }

    _safeEmit(const OrdersLoading());

    try {
      final result = await _subscriptionUseCase.getTodayOrders();

      if (_isClosed) return;

      result.fold(
        (failure) {
          _logger.e(
            'Failed to get today\'s orders: ${failure.message}',
            error: failure,
          );
          _safeEmit(
            OrdersError(
              message: 'Failed to load today\'s orders: ${failure.message}',
            ),
          );
        },
        (orders) {
          _logger.i('Today\'s orders loaded: ${orders.length} orders');

          // Group orders by meal type (breakfast, lunch, dinner)
          final ordersByType = _groupOrdersByType(orders);

          // Determine the current meal period
          final currentPeriod = _getCurrentMealPeriod();

          _safeEmit(
            TodayOrdersLoaded(
              orders: orders,
              ordersByType: ordersByType,
              currentMealPeriod: currentPeriod,
            ),
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error in loadTodayOrders', error: e);
      if (!_isClosed) {
        _safeEmit(OrdersError(message: 'An unexpected error occurred: $e'));
      }
    }
  }

  /// Load upcoming orders
  Future<void> loadUpcomingOrders() async {
    _logger.d('Loading upcoming orders', tag: 'OrdersCubit');

    if (_isClosed) {
      _logger.w(
        'Skipping loadUpcomingOrders - cubit is closed',
        tag: 'OrdersCubit',
      );
      return;
    }

    _safeEmit(const OrdersLoading());

    try {
      _logger.d('Fetching upcoming orders from use case', tag: 'OrdersCubit');
      final result = await _subscriptionUseCase.getUpcomingOrders();

      if (_isClosed) {
        _logger.w(
          'Cubit closed during upcoming orders fetch',
          tag: 'OrdersCubit',
        );
        return;
      }

      result.fold(
        (failure) {
          _logger.e(
            'Failed to get upcoming orders: ${failure.message}',
            error: failure,
          );
          _safeEmit(
            OrdersError(
              message: 'Failed to load upcoming orders: ${failure.message}',
            ),
          );
        },
        (orders) {
          _logger.i(
            'Upcoming orders loaded: ${orders.length} orders',
            tag: 'OrdersCubit',
          );

          if (orders.isEmpty) {
            _safeEmit(UpcomingOrdersLoaded(orders: [], ordersByDate: {}));
            return;
          }

          try {
            // Sort orders by date
            final sortedOrders = _subscriptionUseCase.sortOrders(orders);

            // Group orders by date
            final ordersByDate = _subscriptionUseCase.groupOrdersByDate(
              sortedOrders,
            );

            _logger.d(
              'Emitting UpcomingOrdersLoaded with ${sortedOrders.length} orders',
              tag: 'OrdersCubit',
            );
            _safeEmit(
              UpcomingOrdersLoaded(
                orders: sortedOrders,
                ordersByDate: ordersByDate,
              ),
            );
          } catch (e) {
            _logger.e('Error processing upcoming orders', error: e);
            _safeEmit(
              OrdersError(message: 'Error processing upcoming orders: $e'),
            );
          }
        },
      );
    } catch (e) {
      _logger.e('Unexpected error in loadUpcomingOrders', error: e);
      if (!_isClosed) {
        _safeEmit(OrdersError(message: 'An unexpected error occurred: $e'));
      }
    }
  }

  /// Load past orders
  Future<void> loadPastOrders() async {
    _logger.d('Loading past orders', tag: 'OrdersCubit');

    if (_isClosed) {
      _logger.w(
        'Skipping loadPastOrders - cubit is closed',
        tag: 'OrdersCubit',
      );
      return;
    }

    _safeEmit(const OrdersLoading());

    try {
      final result = await _subscriptionUseCase.getPastOrders();

      if (_isClosed) return;

      result.fold(
        (failure) {
          _logger.e(
            'Failed to get past orders: ${failure.message}',
            error: failure,
          );
          _safeEmit(
            OrdersError(
              message: 'Failed to load order history: ${failure.message}',
            ),
          );
        },
        (orders) {
          _logger.i('Past orders loaded: ${orders.length} orders');

          if (orders.isEmpty) {
            _safeEmit(PastOrdersLoaded(orders: [], ordersByDate: {}));
            return;
          }

          try {
            // Sort orders by date (most recent first)
            final sortedOrders = List<Order>.from(orders);
            sortedOrders.sort((a, b) => b.date.compareTo(a.date));

            // Group orders by date
            final ordersByDate = _subscriptionUseCase.groupOrdersByDate(
              sortedOrders,
            );

            _safeEmit(
              PastOrdersLoaded(
                orders: sortedOrders,
                ordersByDate: ordersByDate,
              ),
            );
          } catch (e) {
            _logger.e('Error processing past orders', error: e);
            _safeEmit(OrdersError(message: 'Error processing past orders: $e'));
          }
        },
      );
    } catch (e) {
      _logger.e('Unexpected error in loadPastOrders', error: e);
      if (!_isClosed) {
        _safeEmit(OrdersError(message: 'An unexpected error occurred: $e'));
      }
    }
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
