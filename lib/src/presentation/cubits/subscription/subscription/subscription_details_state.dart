// lib/src/presentation/cubits/subscription/subscription/subscription_details_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
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

  // Selected subscription details
  final Subscription? selectedSubscription;
  final int? daysRemaining;

  // Weekly meal information for selected subscription
  final List<SubscriptionWeek>? weeklyMeals;
  final List<MealSlot>? upcomingMeals;

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
    this.weeklyMeals,
    this.upcomingMeals,
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
    weeklyMeals,
    upcomingMeals,
  ];

  bool get hasActiveSubscriptions => activeSubscriptions.isNotEmpty;
  bool get hasPausedSubscriptions => pausedSubscriptions.isNotEmpty;
  bool get hasPendingSubscriptions => pendingSubscriptions.isNotEmpty;
  bool get hasAnySubscriptions => subscriptions.isNotEmpty;
  bool get isFiltered => filteredSubscriptions != null;
  bool get hasSelectedSubscription => selectedSubscription != null;
  bool get hasWeeklyMeals => weeklyMeals != null && weeklyMeals!.isNotEmpty;
  bool get hasUpcomingMeals =>
      upcomingMeals != null && upcomingMeals!.isNotEmpty;

  // Based on the API response structure, get total meal count
  int get totalMealCount => selectedSubscription?.totalSlots ?? 0;

  // Get subscription status label for display
  String get statusLabel {
    if (selectedSubscription == null) return '';

    if (selectedSubscription!.isPaused) return 'Paused';

    switch (selectedSubscription!.status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.pending:
        return 'Pending';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  // Get payment status label for display
  String get paymentStatusLabel {
    if (selectedSubscription == null) return '';

    switch (selectedSubscription!.paymentStatus) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

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
    List<SubscriptionWeek>? updatedWeeklyMeals;
    List<MealSlot>? updatedUpcomingMeals;

    if (selectedSubscription != null) {
      try {
        updatedSelectedSubscription = subscriptions.firstWhere(
          (sub) => sub.id == selectedSubscription!.id,
        );
        updatedDaysRemaining = daysRemaining;
        updatedWeeklyMeals = weeklyMeals;
        updatedUpcomingMeals = upcomingMeals;
      } catch (_) {
        // Selected subscription no longer exists or has been removed
        updatedSelectedSubscription = null;
        updatedDaysRemaining = null;
        updatedWeeklyMeals = null;
        updatedUpcomingMeals = null;
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
      weeklyMeals: updatedWeeklyMeals,
      upcomingMeals: updatedUpcomingMeals,
    );
  }

  // Helper to select a specific subscription with weekly meal data
  SubscriptionLoaded withSelectedSubscription(
    Subscription subscription,
    int daysRemaining,
    List<SubscriptionWeek>? weeklyMeals,
    List<MealSlot>? upcomingMeals,
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
      weeklyMeals: weeklyMeals,
      upcomingMeals: upcomingMeals,
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

/// Helper class to represent a subscription week with meals
class SubscriptionWeek {
  final int weekNumber;
  final String packageId;
  final String packageName;
  final List<SubscriptionDayMeal> dailyMeals;

  SubscriptionWeek({
    required this.weekNumber,
    required this.packageId,
    required this.packageName,
    required this.dailyMeals,
  });
}

/// Helper class to represent a day's meals in a subscription
class SubscriptionDayMeal {
  final DateTime date;
  final String day;
  final Map<String, MealSlot?> mealsByType; // breakfast, lunch, dinner

  SubscriptionDayMeal({
    required this.date,
    required this.day,
    required this.mealsByType,
  });

  MealSlot? get breakfast => mealsByType['breakfast'];
  MealSlot? get lunch => mealsByType['lunch'];
  MealSlot? get dinner => mealsByType['dinner'];
}
