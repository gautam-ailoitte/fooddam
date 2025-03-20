// lib/src/presentation/cubits/payment/payment_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentProcessing extends PaymentState {
  final double amount;
  final String subscriptionId;
  final PaymentMethod method;
  
  const PaymentProcessing({
    required this.amount,
    required this.subscriptionId,
    required this.method,
  });
  
  @override
  List<Object?> get props => [amount, subscriptionId, method];
}

class PaymentSuccess extends PaymentState {
  final Payment payment;
  final Subscription subscription;
  
  const PaymentSuccess({
    required this.payment,
    required this.subscription,
  });
  
  @override
  List<Object?> get props => [payment, subscription];
}

class PaymentFailed extends PaymentState {
  final String message;
  final PaymentMethod? method;
  
  const PaymentFailed({
    required this.message,
    this.method,
  });
  
  @override
  List<Object?> get props => [message, method];
}