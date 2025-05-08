// lib/src/presentation/cubits/orders/orders_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/pagination_entity.dart';
import 'package:foodam/src/domain/usecase/susbcription_usecase.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final SubscriptionUseCase _subscriptionUseCase;
  final LoggerService _logger = LoggerService();

  // Pagination tracking
  int _currentPastPage = 1;
  bool _isLoadingMorePast = false;
  List<Order> _allPastOrders = [];
  Pagination? _lastPastPagination;

  OrdersCubit({required SubscriptionUseCase subscriptionUseCase})
    : _subscriptionUseCase = subscriptionUseCase,
      super(const OrdersInitial());

  /// Load all orders data at once (upcoming with upcoming3days context and past)
  Future<void> loadAllOrders() async {
    try {
      _logger.d('Loading all orders data at once', tag: 'OrdersCubit');
      emit(const OrdersLoading());

      // Reset pagination for fresh load
      _currentPastPage = 1;
      _allPastOrders = [];
      _lastPastPagination = null;

      // Load upcoming orders with upcoming3days context
      final upcomingResult = await _subscriptionUseCase.getUpcomingOrders(
        dayContext: 'upcoming3days',
      );

      // Load today's orders specifically
      final todayResult = await _subscriptionUseCase.getTodayOrders();

      // Load first page of past orders
      final pastResult = await _subscriptionUseCase.getPastOrders(page: 1);

      // Process results
      upcomingResult.fold(
        (failure) {
          _logger.e('Failed to get upcoming orders', error: failure);
          emit(OrdersError(message: 'Failed to load upcoming orders'));
        },
        (paginatedUpcoming) {
          todayResult.fold(
            (failure) {
              _logger.e('Failed to get today orders', error: failure);
              emit(OrdersError(message: 'Failed to load today orders'));
            },
            (paginatedToday) {
              pastResult.fold(
                (failure) {
                  _logger.e('Failed to get past orders', error: failure);
                  emit(OrdersError(message: 'Failed to load past orders'));
                },
                (paginatedPast) {
                  _allPastOrders = paginatedPast.orders;
                  _lastPastPagination = paginatedPast.pagination;
                  _processOrderData(
                    paginatedToday.orders,
                    paginatedUpcoming.orders,
                    _allPastOrders,
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error loading orders', error: e);
      emit(OrdersError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Load more past orders (pagination)
  Future<void> loadMorePastOrders() async {
    // First check if we're already loading or if there are no more pages
    if (_isLoadingMorePast) return;
    if (_lastPastPagination?.hasNextPage != true) return;

    try {
      // Set loading flag BEFORE emitting state
      _isLoadingMorePast = true;

      // Emit loading state immediately so UI shows loading indicator
      if (state is OrdersDataLoaded) {
        final currentState = state as OrdersDataLoaded;
        emit(
          OrdersDataLoaded(
            todayOrders: currentState.todayOrders,
            ordersByType: currentState.ordersByType,
            currentMealPeriod: currentState.currentMealPeriod,
            upcomingOrders: currentState.upcomingOrders,
            upcomingOrdersByDate: currentState.upcomingOrdersByDate,
            pastOrders: currentState.pastOrders,
            pastOrdersByDate: currentState.pastOrdersByDate,
            upcomingDeliveriesToday: currentState.upcomingDeliveriesToday,
            pagination: _lastPastPagination,
            isLoadingMore: true, // Set this to true
          ),
        );
      }

      final nextPage = (_lastPastPagination?.page ?? 0) + 1;
      _logger.d(
        'Loading more past orders, page: $nextPage',
        tag: 'OrdersCubit',
      );

      final result = await _subscriptionUseCase.getPastOrders(page: nextPage);

      result.fold(
        (failure) {
          _logger.e('Failed to load more past orders', error: failure);
          // Reset loading state on error
          _isLoadingMorePast = false;

          if (state is OrdersDataLoaded) {
            final currentState = state as OrdersDataLoaded;
            emit(
              OrdersDataLoaded(
                todayOrders: currentState.todayOrders,
                ordersByType: currentState.ordersByType,
                currentMealPeriod: currentState.currentMealPeriod,
                upcomingOrders: currentState.upcomingOrders,
                upcomingOrdersByDate: currentState.upcomingOrdersByDate,
                pastOrders: currentState.pastOrders,
                pastOrdersByDate: currentState.pastOrdersByDate,
                upcomingDeliveriesToday: currentState.upcomingDeliveriesToday,
                pagination: _lastPastPagination,
                isLoadingMore: false,
              ),
            );
          }
        },
        (paginatedOrders) {
          // Update data and reset loading state
          _allPastOrders.addAll(paginatedOrders.orders);
          _lastPastPagination = paginatedOrders.pagination;
          _isLoadingMorePast = false;

          // Re-emit state with updated data
          if (state is OrdersDataLoaded) {
            final currentState = state as OrdersDataLoaded;
            _processOrderData(
              currentState.todayOrders,
              currentState.upcomingOrders,
              _allPastOrders,
            );
          }
        },
      );
    } catch (e) {
      _logger.e('Error loading more past orders', error: e);
      _isLoadingMorePast = false;

      // Reset loading state on exception
      if (state is OrdersDataLoaded) {
        final currentState = state as OrdersDataLoaded;
        emit(
          OrdersDataLoaded(
            todayOrders: currentState.todayOrders,
            ordersByType: currentState.ordersByType,
            currentMealPeriod: currentState.currentMealPeriod,
            upcomingOrders: currentState.upcomingOrders,
            upcomingOrdersByDate: currentState.upcomingOrdersByDate,
            pastOrders: currentState.pastOrders,
            pastOrdersByDate: currentState.pastOrdersByDate,
            upcomingDeliveriesToday: currentState.upcomingDeliveriesToday,
            pagination: _lastPastPagination,
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  void _processOrderData(
    List<Order> todayOrders,
    List<Order> upcomingOrders,
    List<Order> pastOrders,
  ) {
    try {
      // Group orders by appropriate criteria
      final ordersByType = _groupOrdersByType(todayOrders);
      final currentPeriod = _getCurrentMealPeriod();

      // Filter upcoming orders to exclude today's orders
      final now = DateTime.now();
      final futureUpcomingOrders =
          upcomingOrders.where((order) {
            return order.date.year > now.year ||
                order.date.month > now.month ||
                order.date.day > now.day;
          }).toList();

      // Group upcoming orders by date
      final upcomingOrdersByDate = _subscriptionUseCase.groupOrdersByDate(
        futureUpcomingOrders,
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
          upcomingOrders: futureUpcomingOrders,
          upcomingOrdersByDate: upcomingOrdersByDate,
          pastOrders: pastOrders,
          pastOrdersByDate: pastOrdersByDate,
          upcomingDeliveriesToday: upcomingDeliveriesToday,
          pagination: _lastPastPagination,
          isLoadingMore: _isLoadingMorePast,
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
