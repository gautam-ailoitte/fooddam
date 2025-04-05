// lib/src/presentation/cubits/subscription/subscription/subscription_details_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

/// Base state for all subscription-related states
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no subscription data has been loaded
class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

/// Loading state for subscription operations
class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

/// State for when subscription operation is in progress
class SubscriptionActionInProgress extends SubscriptionState {
  final String action;

  const SubscriptionActionInProgress({required this.action});

  @override
  List<Object?> get props => [action];
}

/// State for when subscriptions are loaded (list view)
class SubscriptionLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;
  final List<Subscription> activeSubscriptions;
  final List<Subscription> pausedSubscriptions;
  final List<Subscription> pendingSubscriptions;
  final List<Subscription>? filteredSubscriptions;
  final String? filterType;
  final String? filterValue;

  // Add this optional field for the currently viewed subscription
  final Subscription? selectedSubscription;
  final int? daysRemaining;

  const SubscriptionLoaded({
    required this.subscriptions,
    required this.activeSubscriptions,
    required this.pausedSubscriptions,
    required this.pendingSubscriptions,
    this.filteredSubscriptions,
    this.filterType,
    this.filterValue,
    this.selectedSubscription,
    this.daysRemaining,
  });

  @override
  List<Object?> get props => [
    subscriptions,
    activeSubscriptions,
    pausedSubscriptions,
    pendingSubscriptions,
    filteredSubscriptions,
    filterType,
    filterValue,
    selectedSubscription,
    daysRemaining,
  ];

  bool get hasActiveSubscriptions => activeSubscriptions.isNotEmpty;
  bool get hasPausedSubscriptions => pausedSubscriptions.isNotEmpty;
  bool get hasPendingSubscriptions => pendingSubscriptions.isNotEmpty;
  bool get hasAnySubscriptions => subscriptions.isNotEmpty;
  bool get isFiltered => filteredSubscriptions != null;
  bool get hasSelectedSubscription => selectedSubscription != null;

  // Helper method to create a copy with updated subscription lists
  SubscriptionLoaded copyWithUpdatedLists({
    required List<Subscription> subscriptions,
    required List<Subscription> activeSubscriptions,
    required List<Subscription> pausedSubscriptions,
    required List<Subscription> pendingSubscriptions,
  }) {
    // If we had a selected subscription, try to find its updated version
    Subscription? updatedSelectedSubscription;
    int? updatedDaysRemaining;

    if (selectedSubscription != null) {
      try {
        updatedSelectedSubscription = subscriptions.firstWhere(
          (sub) => sub.id == selectedSubscription!.id,
        );
        updatedDaysRemaining = daysRemaining;
      } catch (_) {
        // Selected subscription no longer exists or has been removed
        updatedSelectedSubscription = null;
        updatedDaysRemaining = null;
      }
    }

    return SubscriptionLoaded(
      subscriptions: subscriptions,
      activeSubscriptions: activeSubscriptions,
      pausedSubscriptions: pausedSubscriptions,
      pendingSubscriptions: pendingSubscriptions,
      filteredSubscriptions: filteredSubscriptions,
      filterType: filterType,
      filterValue: filterValue,
      selectedSubscription: updatedSelectedSubscription,
      daysRemaining: updatedDaysRemaining,
    );
  }

  // Helper to select a specific subscription
  SubscriptionLoaded withSelectedSubscription(
    Subscription subscription,
    int daysRemaining,
  ) {
    return SubscriptionLoaded(
      subscriptions: subscriptions,
      activeSubscriptions: activeSubscriptions,
      pausedSubscriptions: pausedSubscriptions,
      pendingSubscriptions: pendingSubscriptions,
      filteredSubscriptions: filteredSubscriptions,
      filterType: filterType,
      filterValue: filterValue,
      selectedSubscription: subscription,
      daysRemaining: daysRemaining,
    );
  }

  // Helper to clear selected subscription
  SubscriptionLoaded withoutSelectedSubscription() {
    return SubscriptionLoaded(
      subscriptions: subscriptions,
      activeSubscriptions: activeSubscriptions,
      pausedSubscriptions: pausedSubscriptions,
      pendingSubscriptions: pendingSubscriptions,
      filteredSubscriptions: filteredSubscriptions,
      filterType: filterType,
      filterValue: filterValue,
    );
  }
}

/// Success state for subscription actions (pause, resume, cancel)
class SubscriptionActionSuccess extends SubscriptionState {
  final String action;
  final String message;

  const SubscriptionActionSuccess({
    required this.action,
    required this.message,
  });

  @override
  List<Object?> get props => [action, message];
}

/// Error state for subscription operations
class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}
