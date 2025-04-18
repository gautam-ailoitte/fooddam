// lib/src/presentation/cubits/orders/orders_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';

/// Base state for order-related states
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no order data has been loaded
class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

/// Loading state when fetching orders
class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

/// Refreshing state when refreshing orders but keeping current data visible
class OrdersRefreshing extends OrdersState {
  const OrdersRefreshing();
}

/// Loaded state with today's orders data
class TodayOrdersLoaded extends OrdersState {
  final List<Order> orders;
  final Map<String, List<Order>> ordersByType;
  final String currentMealPeriod;

  const TodayOrdersLoaded({
    required this.orders,
    required this.ordersByType,
    required this.currentMealPeriod,
  });

  @override
  List<Object?> get props => [orders, ordersByType, currentMealPeriod];

  // Helper getters
  bool get hasOrdersToday => orders.isNotEmpty;

  bool get hasBreakfast => ordersByType['Breakfast']?.isNotEmpty ?? false;
  bool get hasLunch => ordersByType['Lunch']?.isNotEmpty ?? false;
  bool get hasDinner => ordersByType['Dinner']?.isNotEmpty ?? false;

  int get breakfastCount => ordersByType['Breakfast']?.length ?? 0;
  int get lunchCount => ordersByType['Lunch']?.length ?? 0;
  int get dinnerCount => ordersByType['Dinner']?.length ?? 0;

  bool get hasUpcomingDeliveries =>
      orders.any((order) => order.status == OrderStatus.coming);

  List<Order> get upcomingDeliveries =>
      orders.where((order) => order.status == OrderStatus.coming).toList();

  List<Order> get deliveredOrders =>
      orders.where((order) => order.status == OrderStatus.delivered).toList();

  bool get hasOrdersForCurrentPeriod =>
      ordersByType[currentMealPeriod]?.isNotEmpty ?? false;

  List<Order> get currentPeriodOrders => ordersByType[currentMealPeriod] ?? [];

  // Get orders for a specific type
  List<Order> getOrdersByType(String type) => ordersByType[type] ?? [];
}

/// Loaded state with upcoming orders data
class UpcomingOrdersLoaded extends OrdersState {
  final List<Order> orders;
  final Map<DateTime, List<Order>> ordersByDate;

  const UpcomingOrdersLoaded({
    required this.orders,
    required this.ordersByDate,
  });

  @override
  List<Object?> get props => [orders, ordersByDate];

  // Helper getters
  bool get hasUpcomingOrders => orders.isNotEmpty;

  int get totalOrderCount => orders.length;

  List<DateTime> get datesSorted {
    final dates = ordersByDate.keys.toList();
    dates.sort();
    return dates;
  }
}

/// Loaded state with past orders data
class PastOrdersLoaded extends OrdersState {
  final List<Order> orders;
  final Map<DateTime, List<Order>> ordersByDate;

  const PastOrdersLoaded({required this.orders, required this.ordersByDate});

  @override
  List<Object?> get props => [orders, ordersByDate];

  // Helper getters
  bool get hasPastOrders => orders.isNotEmpty;

  int get totalOrderCount => orders.length;

  List<DateTime> get datesSorted {
    final dates = ordersByDate.keys.toList();
    dates.sort((a, b) => b.compareTo(a)); // Most recent first
    return dates;
  }
}

/// Error state for order operations
class OrdersError extends OrdersState {
  final String message;

  const OrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}
