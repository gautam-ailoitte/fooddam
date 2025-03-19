// lib/src/presentation/cubits/subscription/subscription_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

enum SubscriptionStatus {
  initial,
  loading,
  active,
  inactive,
  creating,
  draft,
  error
}

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final Subscription? activeSubscription;
  final Subscription? draftSubscription;
  final List<Subscription> availableSubscriptions;
  final List<Subscription> subscriptionHistory;
  final bool isLoading;
  final String? errorMessage;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.activeSubscription,
    this.draftSubscription,
    this.availableSubscriptions = const [],
    this.subscriptionHistory = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    Subscription? activeSubscription,
    Subscription? draftSubscription,
    List<Subscription>? availableSubscriptions,
    List<Subscription>? subscriptionHistory,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      activeSubscription: activeSubscription ?? this.activeSubscription,
      draftSubscription: draftSubscription ?? this.draftSubscription,
      availableSubscriptions: availableSubscriptions ?? this.availableSubscriptions,
      subscriptionHistory: subscriptionHistory ?? this.subscriptionHistory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasActiveSubscription => activeSubscription != null;
  bool get hasDraftSubscription => draftSubscription != null;

  @override
  List<Object?> get props => [
    status,
    activeSubscription,
    draftSubscription,
    availableSubscriptions,
    subscriptionHistory,
    isLoading,
    errorMessage,
  ];
}