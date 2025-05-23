// lib/src/domain/usecase/subscription_usecase.dart (UPDATE)
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class SubscriptionUseCase {
  final SubscriptionRepository _repository;

  SubscriptionUseCase(this._repository);

  /// Get all active subscriptions (for list screen)
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions() async {
    return await _repository.getActiveSubscriptions();
  }

  /// Get subscription details by ID (for detail screen)
  Future<Either<Failure, Subscription>> getSubscriptionById(
    String subscriptionId,
  ) async {
    return await _repository.getSubscriptionById(subscriptionId);
  }

  /// Get paginated subscriptions (if needed for advanced filtering)
  Future<Either<Failure, PaginatedSubscriptions>> getSubscriptions({
    int? page,
    int? limit,
  }) async {
    return await _repository.getSubscriptions(page: page, limit: limit);
  }

  /// Create a new subscription
  Future<Either<Failure, Subscription>> createSubscription(
    SubscriptionParams params,
  ) {
    return _repository.createSubscription(
      startDate: params.startDate,
      endDate: params.startDate.add(Duration(days: params.durationDays)),
      durationDays: params.durationDays,
      addressId: params.addressId,
      instructions: params.instructions,
      noOfPersons: params.noOfPersons,
      weeks: params.weeks,
    );
  }

  /// Manage subscription actions (pause, resume, cancel)
  Future<Either<Failure, void>> manageSubscription(
    String subscriptionId,
    SubscriptionAction action,
  ) async {
    switch (action) {
      case SubscriptionAction.pause:
        return await _repository.pauseSubscription(subscriptionId);
      case SubscriptionAction.resume:
        return await _repository.resumeSubscription(subscriptionId);
      case SubscriptionAction.cancel:
        return await _repository.cancelSubscription(subscriptionId);
    }
  }

  /// Get upcoming orders
  Future<Either<Failure, PaginatedOrders>> getUpcomingOrders({
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

  /// Get past orders
  Future<Either<Failure, PaginatedOrders>> getPastOrders({
    int? page,
    int? limit,
    String? dayContext,
  }) async {
    return await _repository.getPastOrders(
      page: page,
      limit: limit,
      dayContext: dayContext,
    );
  }

  /// Helper method to calculate remaining days
  int calculateRemainingDays(Subscription subscription) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      subscription.startDate.year,
      subscription.startDate.month,
      subscription.startDate.day,
    );

    // If subscription hasn't started yet
    if (today.isBefore(startDate)) {
      return subscription.durationDays;
    }

    // Calculate end date (inclusive)
    final endDate = startDate.add(
      Duration(days: subscription.durationDays - 1),
    );

    // If subscription has ended
    if (today.isAfter(endDate)) {
      return 0;
    }

    // Return days remaining including today
    return endDate.difference(today).inDays + 1;
  }

  /// Helper method to check if subscription needs payment
  bool subscriptionNeedsPayment(Subscription subscription) {
    return subscription.status == SubscriptionStatus.pending &&
        subscription.paymentStatus == PaymentStatus.pending;
  }

  /// Helper method to get subscription status display text
  String getSubscriptionStatusText(Subscription subscription) {
    if (subscription.isPaused) return 'Paused';

    switch (subscription.status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.pending:
        return subscriptionNeedsPayment(subscription)
            ? 'Payment Pending'
            : 'Pending Activation';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }

  /// Filter subscriptions by status
  List<Subscription> filterSubscriptionsByStatus(
    List<Subscription> subscriptions,
    SubscriptionStatus status,
  ) {
    return subscriptions.where((sub) => sub.status == status).toList();
  }

  /// Filter subscriptions that need payment
  List<Subscription> getSubscriptionsNeedingPayment(
    List<Subscription> subscriptions,
  ) {
    return subscriptions.where(subscriptionNeedsPayment).toList();
  }

  /// Get active subscriptions (not paused)
  List<Subscription> getActiveSubscriptionsFromList(
    List<Subscription> subscriptions,
  ) {
    return subscriptions
        .where(
          (sub) => sub.status == SubscriptionStatus.active && !sub.isPaused,
        )
        .toList();
  }

  /// Get paused subscriptions
  List<Subscription> getPausedSubscriptionsFromList(
    List<Subscription> subscriptions,
  ) {
    return subscriptions
        .where((sub) => sub.isPaused || sub.status == SubscriptionStatus.paused)
        .toList();
  }

  /// Sort subscriptions by date
  List<Subscription> sortSubscriptionsByDate(
    List<Subscription> subscriptions, {
    bool ascending = false,
  }) {
    final sortedList = List<Subscription>.from(subscriptions);
    sortedList.sort((a, b) {
      return ascending
          ? a.startDate.compareTo(b.startDate)
          : b.startDate.compareTo(a.startDate);
    });
    return sortedList;
  }
}

/// Enum for subscription management actions
enum SubscriptionAction { pause, resume, cancel }

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
