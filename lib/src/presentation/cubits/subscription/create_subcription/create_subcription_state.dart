// lib/src/presentation/cubits/subscription/create_subscription/create_subscription_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

abstract class CreateSubscriptionState extends Equatable {
  const CreateSubscriptionState();
  
  @override
  List<Object?> get props => [];
}

// Initial state
class CreateSubscriptionInitial extends CreateSubscriptionState {}

// Loading state
class CreateSubscriptionLoading extends CreateSubscriptionState {}

// Simple state to indicate data was updated
class DataUpdated extends CreateSubscriptionState {}

// Success state with the created subscription
class CreateSubscriptionSuccess extends CreateSubscriptionState {
  final Subscription subscription;
  
  const CreateSubscriptionSuccess({required this.subscription});
  
  @override
  List<Object?> get props => [subscription];
}

// Error state
class CreateSubscriptionError extends CreateSubscriptionState {
  final String message;
  
  const CreateSubscriptionError(this.message);
  
  @override
  List<Object?> get props => [message];
}