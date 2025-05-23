// lib/src/presentation/cubits/subscription/subscription_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Always contains ALL subscriptions - filtering happens at UI level
class SubscriptionLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;

  const SubscriptionLoaded({required this.subscriptions});

  @override
  List<Object?> get props => [subscriptions];

  bool get isEmpty => subscriptions.isEmpty;
  bool get hasSubscriptions => subscriptions.isNotEmpty;

  /// Helper methods for UI-level filtering
  List<Subscription> get activeSubscriptions =>
      subscriptions
          .where((s) => s.status == SubscriptionStatus.active && !s.isPaused)
          .toList();

  List<Subscription> get pendingSubscriptions =>
      subscriptions
          .where((s) => s.status == SubscriptionStatus.pending)
          .toList();

  List<Subscription> get pausedSubscriptions =>
      subscriptions
          .where((s) => s.status == SubscriptionStatus.paused || s.isPaused)
          .toList();

  List<Subscription> get cancelledSubscriptions =>
      subscriptions
          .where((s) => s.status == SubscriptionStatus.cancelled)
          .toList();

  List<Subscription> get expiredSubscriptions =>
      subscriptions
          .where((s) => s.status == SubscriptionStatus.expired)
          .toList();

  /// Get filtered subscriptions based on status
  List<Subscription> getFilteredSubscriptions(String? filter) {
    switch (filter?.toLowerCase()) {
      case 'active':
        return activeSubscriptions;
      case 'pending':
        return pendingSubscriptions;
      case 'paused':
        return pausedSubscriptions;
      case 'cancelled':
        return cancelledSubscriptions;
      case 'expired':
        return expiredSubscriptions;
      default:
        return subscriptions; // Return all subscriptions
    }
  }

  /// Sort subscriptions by date
  List<Subscription> getSortedSubscriptions(
    List<Subscription> subscriptionsToSort, {
    bool ascending = false, // Default to newest first
  }) {
    final sortedList = List<Subscription>.from(subscriptionsToSort);
    sortedList.sort((a, b) {
      return ascending
          ? a.startDate.compareTo(b.startDate)
          : b.startDate.compareTo(a.startDate);
    });
    return sortedList;
  }

  /// Get subscriptions that need payment
  List<Subscription> get subscriptionsNeedingPayment =>
      subscriptions
          .where(
            (s) =>
                s.status == SubscriptionStatus.pending &&
                s.paymentStatus == PaymentStatus.pending,
          )
          .toList();

  /// Get count by status
  int getCountByStatus(SubscriptionStatus status) {
    return subscriptions.where((s) => s.status == status).length;
  }

  // Convenience getters for home screen
  bool get hasActiveSubscriptions => activeSubscriptions.isNotEmpty;
  bool get hasPausedSubscriptions => pausedSubscriptions.isNotEmpty;
  bool get hasPendingSubscriptions => pendingSubscriptions.isNotEmpty;
}

class SubscriptionDetailLoaded extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionDetailLoaded({required this.subscription});

  @override
  List<Object?> get props => [subscription];

  /// Helper getters for subscription details
  bool get hasWeeks =>
      subscription.weeks != null && subscription.weeks!.isNotEmpty;
  bool get needsPayment =>
      subscription.status == SubscriptionStatus.pending &&
      subscription.paymentStatus == PaymentStatus.pending;
  bool get isActive =>
      subscription.status == SubscriptionStatus.active &&
      !subscription.isPaused;
  bool get isPaused =>
      subscription.isPaused || subscription.status == SubscriptionStatus.paused;
  bool get canBePaused => isActive;
  bool get canBeResumed => isPaused;
  bool get canBeCancelled => isActive || isPaused;

  /// Calculate days remaining
  int get daysRemaining {
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

    // Calculate end date
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

  /// Get today's meals from subscription
  List<dynamic> get todayMeals {
    if (!hasWeeks) return [];

    final today = DateTime.now();
    final todayMeals = <dynamic>[];

    for (final week in subscription.weeks!) {
      for (final slot in week.slots) {
        if (slot.date != null &&
            slot.date!.year == today.year &&
            slot.date!.month == today.month &&
            slot.date!.day == today.day &&
            slot.meal != null) {
          todayMeals.add(slot);
        }
      }
    }

    return todayMeals;
  }

  /// Get upcoming meals from subscription
  List<dynamic> get upcomingMeals {
    if (!hasWeeks) return [];

    final now = DateTime.now();
    final upcomingMeals = <dynamic>[];

    for (final week in subscription.weeks!) {
      for (final slot in week.slots) {
        if (slot.date != null && slot.date!.isAfter(now) && slot.meal != null) {
          upcomingMeals.add(slot);
        }
      }
    }

    // Sort by date
    upcomingMeals.sort((a, b) => a.date.compareTo(b.date));

    return upcomingMeals;
  }
}
