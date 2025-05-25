// lib/src/presentation/cubits/orders/orders_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/pagination_entity.dart';
import 'package:foodam/src/domain/usecase/order_usecase.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderUseCase _orderUseCase;
  final LoggerService _logger = LoggerService();

  // Pagination tracking
  int _currentPastPage = 1;
  bool _isLoadingMorePast = false;
  List<Order> _allPastOrders = [];
  Pagination? _lastPastPagination;
  DateTime? _lastRefreshTime;

  OrdersCubit({required OrderUseCase orderUseCase})
    : _orderUseCase = orderUseCase,
      super(const OrdersInitial());

  /// Load all orders data at once (upcoming, today, and past)
  Future<void> loadAllOrders() async {
    try {
      _logger.d('Loading all orders data at once', tag: 'OrdersCubit');
      emit(const OrdersLoading());

      // Reset pagination for fresh load
      _currentPastPage = 1;
      _allPastOrders = [];
      _lastPastPagination = null;

      // Load upcoming orders (includes today's orders)
      final upcomingResult = await _orderUseCase.getUpcomingOrders(
        dayContext: 'upcoming3days',
        limit: 50, // Get more to capture all upcoming orders
      );

      // Load first page of past orders
      final pastResult = await _orderUseCase.getPastOrders(page: 1, limit: 10);

      // Process results
      upcomingResult.fold(
        (failure) {
          _logger.e(
            'Failed to get upcoming orders',
            error: failure,
            tag: 'OrdersCubit',
          );
          emit(
            OrdersError(
              message: 'Failed to load upcoming orders: ${failure.message}',
            ),
          );
        },
        (paginatedUpcoming) {
          pastResult.fold(
            (failure) {
              _logger.e(
                'Failed to get past orders',
                error: failure,
                tag: 'OrdersCubit',
              );
              emit(
                OrdersError(
                  message: 'Failed to load past orders: ${failure.message}',
                ),
              );
            },
            (paginatedPast) {
              _allPastOrders = paginatedPast.orders;
              _lastPastPagination = paginatedPast.pagination;
              _lastRefreshTime = DateTime.now();

              _processOrderData(paginatedUpcoming.orders, _allPastOrders);
            },
          );
        },
      );
    } catch (e) {
      _logger.e(
        'Unexpected error loading orders',
        error: e,
        tag: 'OrdersCubit',
      );
      emit(OrdersError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Load more past orders (pagination)
  Future<void> loadMorePastOrders() async {
    // Check if we're already loading or if there are no more pages
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

      final result = await _orderUseCase.getPastOrders(
        page: nextPage,
        limit: 10,
      );

      result.fold(
        (failure) {
          _logger.e(
            'Failed to load more past orders',
            error: failure,
            tag: 'OrdersCubit',
          );
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
              currentState.todayOrders + currentState.upcomingOrders,
              _allPastOrders,
            );
          }
        },
      );
    } catch (e) {
      _logger.e('Error loading more past orders', error: e, tag: 'OrdersCubit');
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

  /// Refresh orders if needed (based on time)
  Future<void> refreshOrdersIfNeeded() async {
    if (_orderUseCase.shouldRefreshOrders(_lastRefreshTime)) {
      await loadAllOrders();
    }
  }

  /// Force refresh orders
  Future<void> refreshOrders() async {
    await loadAllOrders();
  }

  void _processOrderData(
    List<Order> allUpcomingOrders,
    List<Order> pastOrders,
  ) {
    try {
      // Categorize upcoming orders into today and future
      final categorized = _orderUseCase.categorizeOrders(allUpcomingOrders);
      final todayOrders = categorized.todayOrders;
      final futureUpcomingOrders = categorized.upcomingOrders;

      // Group orders by appropriate criteria
      final ordersByType = _orderUseCase.groupOrdersByType(todayOrders);
      final currentPeriod = _orderUseCase.getCurrentMealPeriod();

      // Group upcoming orders by date
      final upcomingOrdersByDate = _orderUseCase.groupOrdersByDate(
        futureUpcomingOrders,
      );

      // Group past orders by date
      final pastOrdersByDate = _orderUseCase.groupOrdersByDate(pastOrders);

      // Get upcoming deliveries for today
      final upcomingDeliveriesToday = _orderUseCase.getTodayUpcomingDeliveries(
        todayOrders,
      );

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
      _logger.e('Error processing order data', error: e, tag: 'OrdersCubit');
      emit(OrdersError(message: 'Error processing order data: $e'));
    }
  }

  /// Get order statistics
  OrderStatistics? getOrderStatistics() {
    if (state is OrdersDataLoaded) {
      final loadedState = state as OrdersDataLoaded;
      final allOrders = [
        ...loadedState.todayOrders,
        ...loadedState.upcomingOrders,
        ...loadedState.pastOrders,
      ];
      return _orderUseCase.getOrderStatistics(allOrders);
    }
    return null;
  }

  @override
  Future<void> close() {
    _logger.d('OrdersCubit closing', tag: 'OrdersCubit');
    return super.close();
  }
}
