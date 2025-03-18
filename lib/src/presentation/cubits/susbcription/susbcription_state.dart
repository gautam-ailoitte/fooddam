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

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ActiveSubscriptionLoaded extends SubscriptionState {
  final Subscription subscription;

  const ActiveSubscriptionLoaded({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class NoActiveSubscription extends SubscriptionState {}

class AvailableSubscriptionsLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;

  const AvailableSubscriptionsLoaded({required this.subscriptions});

  @override
  List<Object?> get props => [subscriptions];
}

class SubscriptionCreated extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionCreated({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionCustomized extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionCustomized({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionPaused extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionPaused({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionResumed extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionResumed({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionCancelled extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionCancelled({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionHistoryLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;

  const SubscriptionHistoryLoaded({required this.subscriptions});

  @override
  List<Object?> get props => [subscriptions];
}

class DraftSubscriptionSaved extends SubscriptionState {
  final Subscription subscription;

  const DraftSubscriptionSaved({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class DraftSubscriptionLoaded extends SubscriptionState {
  final Subscription subscription;

  const DraftSubscriptionLoaded({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class NoDraftSubscription extends SubscriptionState {}

class DraftSubscriptionCleared extends SubscriptionState {}