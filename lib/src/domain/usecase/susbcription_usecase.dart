// lib/src/domain/usecase/susbcription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
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

  /// Get all active subscriptions for the current user
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions() {
    return repository.getActiveSubscriptions();
  }

  /// Get details of a specific subscription by ID
  Future<Either<Failure, Subscription>> getSubscriptionById(
    String subscriptionId,
  ) {
    return repository.getSubscriptionById(subscriptionId);
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

  /// Create a new subscription
  Future<Either<Failure, List<String>>> createSubscription(
    SubscriptionParams params,
  ) async {
    // Convert slots to the format expected by the repository
    final slots =
        params.slots
            .map(
              (slot) => {
                'day': slot.day.toLowerCase(),
                'timing': slot.timing.toLowerCase(),
                'meal': slot.mealId ?? '',
              },
            )
            .toList();

    return await repository.createSubscription(
      packageId: params.packageId,
      startDate: params.startDate,
      durationDays: params.durationDays,
      addressId: params.addressId,
      instructions: params.instructions,
      slots: slots,
      personCount: params.personCount,
    );
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

  /// Calculate remaining days for a subscription
  int calculateRemainingDays(Subscription subscription) {
    final now = DateTime.now();
    final endDate = subscription.startDate.add(
      Duration(days: subscription.durationDays),
    );

    if (now.isAfter(endDate)) {
      return 0;
    }

    return endDate.difference(now).inDays;
  }

  /// Calculate total meals in a subscription
  int calculateTotalMeals(Subscription subscription) {
    // If slots are provided, count them
    if (subscription.slots.isNotEmpty) {
      return subscription.slots.length;
    }

    // Use noOfSlots if available
    if (subscription.noOfSlots > 0) {
      return subscription.noOfSlots;
    }

    // Default: 21 meals (7 days x 3 meals)
    return 21;
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
  final String packageId;
  final DateTime startDate;
  final int durationDays;
  final String addressId;
  final String? instructions;
  final List<MealSlot> slots;
  final int personCount;

  SubscriptionParams({
    required this.packageId,
    required this.startDate,
    required this.durationDays,
    required this.addressId,
    this.instructions,
    required this.slots,
    this.personCount = 1,
  });
}

/// Parameters for pausing a subscription
class PauseSubscriptionParams {
  final String subscriptionId;
  final DateTime until;

  PauseSubscriptionParams({required this.subscriptionId, required this.until});
}
