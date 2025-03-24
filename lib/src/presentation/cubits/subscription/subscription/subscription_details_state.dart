// lib/src/presentation/cubits/subscription/subscription_state.dart
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
  final List<Subscription>? filteredSubscriptions;
  final String? filterType;
  final String? filterValue;
  
  const SubscriptionLoaded({
    required this.subscriptions,
    required this.activeSubscriptions,
    required this.pausedSubscriptions,
    this.filteredSubscriptions,
    this.filterType,
    this.filterValue,
  });
  
  @override
  List<Object?> get props => [
    subscriptions, 
    activeSubscriptions, 
    pausedSubscriptions,
    filteredSubscriptions,
    filterType,
    filterValue,
  ];
  
  bool get hasActiveSubscriptions => activeSubscriptions.isNotEmpty;
  bool get hasPausedSubscriptions => pausedSubscriptions.isNotEmpty;
  bool get hasAnySubscriptions => subscriptions.isNotEmpty;
  bool get isFiltered => filteredSubscriptions != null;
  
  /// Create a copy with filtered subscriptions
  SubscriptionLoaded copyWithFilter({
    required List<Subscription> filteredSubscriptions,
    required String filterType,
    required String filterValue,
  }) {
    return SubscriptionLoaded(
      subscriptions: subscriptions,
      activeSubscriptions: activeSubscriptions,
      pausedSubscriptions: pausedSubscriptions,
      filteredSubscriptions: filteredSubscriptions,
      filterType: filterType,
      filterValue: filterValue,
    );
  }
  
  /// Create a copy with cleared filters
  SubscriptionLoaded copyWithoutFilter() {
    return SubscriptionLoaded(
      subscriptions: subscriptions,
      activeSubscriptions: activeSubscriptions,
      pausedSubscriptions: pausedSubscriptions,
    );
  }
}

/// State for when a specific subscription is loaded (detail view)
class SubscriptionDetailLoaded extends SubscriptionState {
  final Subscription subscription;
  final int daysRemaining;
  final List<MealSlot>? upcomingMeals;
  
  const SubscriptionDetailLoaded({
    required this.subscription,
    required this.daysRemaining,
    this.upcomingMeals,
  });
  
  @override
  List<Object?> get props => [subscription, daysRemaining, upcomingMeals];
  
  bool get canBePaused => 
    subscription.status == SubscriptionStatus.active && 
    !subscription.isPaused;
    
  bool get canBeResumed => 
    subscription.status == SubscriptionStatus.active && 
    subscription.isPaused;
    
  bool get canBeCancelled =>
    subscription.status == SubscriptionStatus.active ||
    subscription.status == SubscriptionStatus.paused;
    
  bool get isActive => 
    subscription.status == SubscriptionStatus.active && 
    !subscription.isPaused;
    
  bool get isPaused => 
    subscription.status == SubscriptionStatus.paused || 
    subscription.isPaused;
    
  bool get isCancelled => 
    subscription.status == SubscriptionStatus.cancelled;
    
  bool get isExpired => 
    subscription.status == SubscriptionStatus.expired;
}

/// State for subscription creation stages
class SubscriptionCreationStage extends SubscriptionState {
  final int stage;
  final String? selectedPackageId;
  final List<MealSlot>? mealSlots;
  final String? selectedAddressId;
  final int personCount;
  final String? instructions;
  
  const SubscriptionCreationStage({
    required this.stage,
    this.selectedPackageId,
    this.mealSlots,
    this.selectedAddressId,
    this.personCount = 1,
    this.instructions,
  });
  
  @override
  List<Object?> get props => [
    stage,
    selectedPackageId,
    mealSlots,
    selectedAddressId,
    personCount,
    instructions,
  ];
  
  bool get hasPackageSelected => selectedPackageId != null;
  bool get hasMealsSelected => mealSlots != null && mealSlots!.isNotEmpty;
  bool get hasAddressSelected => selectedAddressId != null;
  int get totalMeals => (mealSlots?.length ?? 0) * personCount;
  
  bool get isPackageSelectionStage => stage == 0;
  bool get isMealDistributionStage => stage == 1;
  bool get isAddressSelectionStage => stage == 2;
  bool get isSummaryStage => stage == 3;
  
  String get stageName {
    switch (stage) {
      case 0: return 'Package Selection';
      case 1: return 'Meal Selection';
      case 2: return 'Delivery Address';
      case 3: return 'Subscription Summary';
      default: return 'Unknown Stage';
    }
  }
}

/// Loading state specifically for subscription creation
class SubscriptionCreationLoading extends SubscriptionState {
  const SubscriptionCreationLoading();
}

/// Success state for when a subscription is successfully created
class SubscriptionCreationSuccess extends SubscriptionState {
  final Subscription subscription;
  
  const SubscriptionCreationSuccess({required this.subscription});
  
  @override
  List<Object?> get props => [subscription];
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