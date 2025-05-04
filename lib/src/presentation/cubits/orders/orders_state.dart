// lib/src/presentation/cubits/orders/orders_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/pagination_entity.dart';

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

/// Consolidated state for all orders data
class OrdersDataLoaded extends OrdersState {
  // Today's orders data
  final List<Order> todayOrders;
  final Map<String, List<Order>> ordersByType;
  final String currentMealPeriod;
  final List<Order> upcomingDeliveriesToday;

  // Upcoming orders data
  final List<Order> upcomingOrders;
  final Map<DateTime, List<Order>> upcomingOrdersByDate;

  // Past orders data
  final List<Order> pastOrders;
  final Map<DateTime, List<Order>> pastOrdersByDate;

  // Pagination info
  final Pagination? pagination;
  final bool isLoadingMore;

  const OrdersDataLoaded({
    required this.todayOrders,
    required this.ordersByType,
    required this.currentMealPeriod,
    required this.upcomingOrders,
    required this.upcomingOrdersByDate,
    required this.pastOrders,
    required this.pastOrdersByDate,
    required this.upcomingDeliveriesToday,
    this.pagination,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    todayOrders,
    ordersByType,
    currentMealPeriod,
    upcomingOrders,
    upcomingOrdersByDate,
    pastOrders,
    pastOrdersByDate,
    upcomingDeliveriesToday,
    pagination,
    isLoadingMore,
  ];

  // Helper getters for today tab
  bool get hasTodayOrders => todayOrders.isNotEmpty;
  bool get hasBreakfast => ordersByType['Breakfast']?.isNotEmpty ?? false;
  bool get hasLunch => ordersByType['Lunch']?.isNotEmpty ?? false;
  bool get hasDinner => ordersByType['Dinner']?.isNotEmpty ?? false;
  int get breakfastCount => ordersByType['Breakfast']?.length ?? 0;
  int get lunchCount => ordersByType['Lunch']?.length ?? 0;
  int get dinnerCount => ordersByType['Dinner']?.length ?? 0;
  bool get hasUpcomingDeliveries => upcomingDeliveriesToday.isNotEmpty;
  List<Order> get deliveredOrdersToday =>
      todayOrders
          .where((order) => order.status == OrderStatus.delivered)
          .toList();
  bool get hasOrdersForCurrentPeriod =>
      ordersByType[currentMealPeriod]?.isNotEmpty ?? false;
  List<Order> get currentPeriodOrders => ordersByType[currentMealPeriod] ?? [];

  // Helper getters for upcoming tab
  bool get hasUpcomingOrdersFuture => upcomingOrders.isNotEmpty;
  int get totalUpcomingCount => upcomingOrders.length;
  List<DateTime> get upcomingDatesSorted {
    final dates = upcomingOrdersByDate.keys.toList();
    dates.sort();
    return dates;
  }

  // Helper getters for past orders tab
  bool get hasPastOrders => pastOrders.isNotEmpty;
  int get totalPastOrderCount => pastOrders.length;
  List<DateTime> get pastDatesSorted {
    final dates = pastOrdersByDate.keys.toList();
    dates.sort((a, b) => b.compareTo(a)); // Most recent first
    return dates;
  }

  // Pagination helpers
  bool get hasMorePastOrders => pagination?.hasNextPage ?? false;
  bool get canLoadMore => hasMorePastOrders && !isLoadingMore;

  // Helper method to get orders by type
  List<Order> getOrdersByType(String type) => ordersByType[type] ?? [];
}

/// Error state for order operations
class OrdersError extends OrdersState {
  final String message;

  const OrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}
