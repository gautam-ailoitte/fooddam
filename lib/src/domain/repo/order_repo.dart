// lib/src/domain/repo/order_repo.dart
import 'package:dartz/dartz.dart' as either;
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/pagination_entity.dart';

abstract class OrderRepository {
  /// Get upcoming orders (including today)
  /// Uses dayContext=upcoming3days to get next 3 days of orders
  Future<either.Either<Failure, PaginatedOrders>> getUpcomingOrders({
    int? page,
    int? limit,
    String? dayContext,
  });

  /// Get past orders (orders before today)
  /// Uses default endpoint and filters client-side for past orders
  Future<either.Either<Failure, PaginatedOrders>> getPastOrders({
    int? page,
    int? limit,
  });

  /// Get today's orders specifically
  /// Extracted from upcoming orders response
  Future<either.Either<Failure, List<Order>>> getTodayOrders();

  /// Get all orders (for fallback scenarios)
  Future<either.Either<Failure, PaginatedOrders>> getAllOrders({
    int? page,
    int? limit,
  });
}

/// Paginated orders response
class PaginatedOrders {
  final List<Order> orders;
  final Pagination pagination;

  PaginatedOrders({required this.orders, required this.pagination});
}

/// Helper class to categorize orders by date
class CategorizedOrders {
  final List<Order> todayOrders;
  final List<Order> upcomingOrders;
  final List<Order> pastOrders;

  CategorizedOrders({
    required this.todayOrders,
    required this.upcomingOrders,
    required this.pastOrders,
  });

  /// Create from a list of orders
  factory CategorizedOrders.fromOrderList(List<Order> orders) {
    final today = <Order>[];
    final upcoming = <Order>[];
    final past = <Order>[];

    for (final order in orders) {
      if (order.isToday) {
        today.add(order);
      } else if (order.isPast) {
        past.add(order);
      } else {
        upcoming.add(order);
      }
    }

    return CategorizedOrders(
      todayOrders: today,
      upcomingOrders: upcoming,
      pastOrders: past,
    );
  }
}

/// Helper class to group orders by date
class GroupedOrders {
  final Map<DateTime, List<Order>> ordersByDate;

  GroupedOrders({required this.ordersByDate});

  /// Create from a list of orders
  factory GroupedOrders.fromOrderList(List<Order> orders) {
    final Map<DateTime, List<Order>> grouped = {};

    for (final order in orders) {
      if (order.deliveryDate == null) continue;

      // Create a date key (year, month, day only)
      final dateKey = DateTime(
        order.deliveryDate!.year,
        order.deliveryDate!.month,
        order.deliveryDate!.day,
      );

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(order);
    }

    return GroupedOrders(ordersByDate: grouped);
  }

  /// Get sorted dates (ascending)
  List<DateTime> get sortedDatesAsc {
    final dates = ordersByDate.keys.toList();
    dates.sort((a, b) => a.compareTo(b));
    return dates;
  }

  /// Get sorted dates (descending)
  List<DateTime> get sortedDatesDesc {
    final dates = ordersByDate.keys.toList();
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }
}
