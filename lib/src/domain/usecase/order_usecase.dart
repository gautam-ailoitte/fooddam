// lib/src/domain/usecase/order_usecase.dart
import 'package:dartz/dartz.dart' as either;
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/repo/order_repo.dart';

class OrderUseCase {
  final OrderRepository _repository;

  OrderUseCase(this._repository);

  /// Get upcoming orders (next 3 days including today)
  Future<either.Either<Failure, PaginatedOrders>> getUpcomingOrders({
    int? page,
    int? limit,
    String? dayContext,
  }) async {
    return await _repository.getUpcomingOrders(
      page: page,
      limit: limit,
      dayContext: dayContext,
    );
  }

  /// Get past orders with pagination
  Future<either.Either<Failure, PaginatedOrders>> getPastOrders({
    int? page,
    int? limit,
  }) async {
    return await _repository.getPastOrders(page: page, limit: limit);
  }

  /// Get today's orders specifically
  Future<either.Either<Failure, List<Order>>> getTodayOrders() async {
    return await _repository.getTodayOrders();
  }

  /// Get all orders (fallback method)
  Future<either.Either<Failure, PaginatedOrders>> getAllOrders({
    int? page,
    int? limit,
  }) async {
    return await _repository.getAllOrders(page: page, limit: limit);
  }

  /// Group orders by date
  Map<DateTime, List<Order>> groupOrdersByDate(List<Order> orders) {
    final grouped = GroupedOrders.fromOrderList(orders);
    return grouped.ordersByDate;
  }

  /// Categorize orders into today, upcoming, and past
  CategorizedOrders categorizeOrders(List<Order> orders) {
    return CategorizedOrders.fromOrderList(orders);
  }

  /// Group orders by meal type (timing)
  Map<String, List<Order>> groupOrdersByType(List<Order> orders) {
    final Map<String, List<Order>> grouped = {
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
    };

    for (final order in orders) {
      final mealType = order.mealType;
      if (grouped.containsKey(mealType)) {
        grouped[mealType]!.add(order);
      }
    }

    return grouped;
  }

  /// Get current meal period based on time
  String getCurrentMealPeriod() {
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

  /// Filter orders for a specific date
  List<Order> getOrdersForDate(List<Order> orders, DateTime date) {
    return orders.where((order) {
      if (order.deliveryDate == null) return false;

      final orderDate = order.deliveryDate!;
      return orderDate.year == date.year &&
          orderDate.month == date.month &&
          orderDate.day == date.day;
    }).toList();
  }

  /// Filter orders for a specific meal type
  List<Order> getOrdersForMealType(List<Order> orders, String mealType) {
    return orders.where((order) => order.mealType == mealType).toList();
  }

  /// Get upcoming deliveries for today
  List<Order> getTodayUpcomingDeliveries(List<Order> todayOrders) {
    return todayOrders.where((order) => order.isPending).toList();
  }

  /// Get delivered orders for today
  List<Order> getTodayDeliveredOrders(List<Order> todayOrders) {
    return todayOrders.where((order) => order.isDelivered).toList();
  }

  /// Sort orders by delivery time
  List<Order> sortOrdersByDeliveryTime(
    List<Order> orders, {
    bool ascending = true,
  }) {
    final sortedOrders = List<Order>.from(orders);

    sortedOrders.sort((a, b) {
      final aTime = a.estimatedDeliveryTime ?? a.deliveryDate;
      final bTime = b.estimatedDeliveryTime ?? b.deliveryDate;

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
    });

    return sortedOrders;
  }

  /// Get order statistics
  OrderStatistics getOrderStatistics(List<Order> orders) {
    final total = orders.length;
    final delivered = orders.where((o) => o.isDelivered).length;
    final pending = orders.where((o) => o.isPending).length;
    final cancelled =
        orders.where((o) => o.status == OrderStatus.cancelled).length;

    final byMealType = groupOrdersByType(orders);
    final breakfastCount = byMealType['Breakfast']?.length ?? 0;
    final lunchCount = byMealType['Lunch']?.length ?? 0;
    final dinnerCount = byMealType['Dinner']?.length ?? 0;

    return OrderStatistics(
      totalOrders: total,
      deliveredOrders: delivered,
      pendingOrders: pending,
      cancelledOrders: cancelled,
      breakfastOrders: breakfastCount,
      lunchOrders: lunchCount,
      dinnerOrders: dinnerCount,
    );
  }

  /// Check if orders need refresh (based on time)
  bool shouldRefreshOrders(DateTime? lastRefresh) {
    if (lastRefresh == null) return true;

    final now = DateTime.now();
    final timeSinceRefresh = now.difference(lastRefresh);

    // Refresh every 5 minutes for real-time updates
    return timeSinceRefresh.inMinutes >= 5;
  }
}

/// Order statistics helper class
class OrderStatistics {
  final int totalOrders;
  final int deliveredOrders;
  final int pendingOrders;
  final int cancelledOrders;
  final int breakfastOrders;
  final int lunchOrders;
  final int dinnerOrders;

  OrderStatistics({
    required this.totalOrders,
    required this.deliveredOrders,
    required this.pendingOrders,
    required this.cancelledOrders,
    required this.breakfastOrders,
    required this.lunchOrders,
    required this.dinnerOrders,
  });

  double get deliveryRate =>
      totalOrders > 0 ? (deliveredOrders / totalOrders) * 100 : 0.0;

  String get mostPopularMealType {
    final counts = {
      'Breakfast': breakfastOrders,
      'Lunch': lunchOrders,
      'Dinner': dinnerOrders,
    };

    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
