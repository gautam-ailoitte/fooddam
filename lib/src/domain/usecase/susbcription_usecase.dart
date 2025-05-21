// lib/src/domain/usecase/susbcription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order_entity;
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

/// Subscription action enum for managing subscriptions
enum SubscriptionAction { pause, resume, cancel }

/// Consolidated Subscription Use Case
///
/// This class combines multiple previously separate use cases related to subscriptions:
/// - GetActiveSubscriptionsUseCase
/// - GetSubscriptionByIdUseCase
/// - CreateSubscriptionUseCase
/// - PauseSubscriptionUseCase
/// - ResumeSubscriptionUseCase
/// - CancelSubscriptionUseCase
/// - GetUpcomingOrdersUseCase
/// - GetPastOrdersUseCase
class SubscriptionUseCase {
  final SubscriptionRepository repository;

  SubscriptionUseCase(this.repository);

  /// Get subscriptions with pagination
  Future<Either<Failure, PaginatedSubscriptions>> getSubscriptions({
    int? page,
    int? limit,
  }) {
    return repository.getSubscriptions(page: page, limit: limit);
  }

  /// Get active subscriptions (filter client-side)
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions() async {
    final result = await repository.getSubscriptions();

    return result.fold((failure) => Left(failure), (paginated) {
      final active =
          paginated.subscriptions
              .where(
                (sub) =>
                    sub.status == SubscriptionStatus.active && !sub.isPaused,
              )
              .toList();

      return Right(active);
    });
  }

  /// Get details of a specific subscription by ID
  Future<Either<Failure, Subscription>> getSubscriptionById(
    String subscriptionId,
  ) {
    return repository.getSubscriptionById(subscriptionId);
  }

  /// Create a new subscription
  Future<Either<Failure, Subscription>> createSubscription(
    SubscriptionParams params,
  ) {
    return repository.createSubscription(
      startDate: params.startDate,
      endDate: params.startDate.add(Duration(days: params.durationDays)),
      durationDays: params.durationDays,
      addressId: params.addressId,
      instructions: params.instructions,
      noOfPersons: params.noOfPersons,
      weeks: params.weeks,
    );
  }

  /// Get upcoming orders with pagination
  Future<Either<Failure, PaginatedOrders>> getUpcomingOrders({
    int? page,
    int? limit,
    String? dayContext,
  }) {
    return repository.getUpcomingOrders(
      page: page,
      limit: limit,
      dayContext: dayContext,
    );
  }

  /// Get past orders with pagination
  Future<Either<Failure, PaginatedOrders>> getPastOrders({
    int? page,
    int? limit,
    String? dayContext,
  }) {
    return repository.getPastOrders(
      page: page,
      limit: limit,
      dayContext: dayContext,
    );
  }

  /// Get today's orders
  Future<Either<Failure, PaginatedOrders>> getTodayOrders() async {
    // Use dayContext = 'today' to get only today's orders
    return getUpcomingOrders(dayContext: 'today');
  }

  /// Manage subscription (pause, resume, cancel)
  Future<Either<Failure, void>> manageSubscription(
    String subscriptionId,
    SubscriptionAction action, {
    DateTime? untilDate,
  }) async {
    switch (action) {
      case SubscriptionAction.pause:
        return repository.pauseSubscription(subscriptionId);

      case SubscriptionAction.resume:
        return repository.resumeSubscription(subscriptionId);

      case SubscriptionAction.cancel:
        return repository.cancelSubscription(subscriptionId);
    }
  }

  /// Calculate total meals in a subscription
  int calculateRemainingDays(Subscription subscription) {
    final now = DateTime.now();

    // Try to get endDate directly if available
    if (subscription.endDate != null) {
      if (now.isAfter(subscription.endDate!)) {
        return 0;
      }
      return subscription.endDate!.difference(now).inDays;
    }

    // Calculate based on startDate and durationDays
    final endDate = subscription.startDate.add(
      Duration(days: subscription.durationDays),
    );

    if (now.isAfter(endDate)) {
      return 0;
    }

    return endDate.difference(now).inDays;
  }

  /// Helper method to check if a date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Group orders by date
  Map<DateTime, List<order_entity.Order>> groupOrdersByDate(
    List<order_entity.Order> orders,
  ) {
    final Map<DateTime, List<order_entity.Order>> result = {};

    for (final order in orders) {
      // Normalize the date to ignore time
      final normalizedDate = DateTime(
        order.date.year,
        order.date.month,
        order.date.day,
      );

      if (!result.containsKey(normalizedDate)) {
        result[normalizedDate] = [];
      }

      result[normalizedDate]!.add(order);
    }

    return result;
  }

  /// Sort orders by date and timing
  List<order_entity.Order> sortOrders(List<order_entity.Order> orders) {
    // Create a copy to avoid modifying the original list
    final sortedOrders = List<order_entity.Order>.from(orders);

    // Define timing priority (breakfast first, then lunch, then dinner)
    const Map<String, int> timingPriority = {
      'breakfast': 0,
      'lunch': 1,
      'dinner': 2,
    };

    // Sort by date first, then by timing
    sortedOrders.sort((a, b) {
      // Compare dates first
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) {
        return dateComparison;
      }

      // If same date, compare by timing
      final aPriority = timingPriority[a.timing.toLowerCase()] ?? 3;
      final bPriority = timingPriority[b.timing.toLowerCase()] ?? 3;
      return aPriority - bPriority;
    });

    return sortedOrders;
  }
}

/// Parameters for creating a subscription
class SubscriptionParams {
  final DateTime startDate;
  final int durationDays;
  final String addressId;
  final String? instructions;
  final int noOfPersons;
  final List<WeekSubscription> weeks;

  SubscriptionParams({
    required this.startDate,
    required this.durationDays,
    required this.addressId,
    this.instructions,
    required this.noOfPersons,
    required this.weeks,
  });
}

/// Parameters for pausing a subscription
class PauseSubscriptionParams {
  final String subscriptionId;

  PauseSubscriptionParams({required this.subscriptionId});
}
