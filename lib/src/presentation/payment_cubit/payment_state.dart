// lib/src/presentation/payment_cubit/payment_state.dart
part of 'payment_cubit.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentProcessing extends PaymentState {}

class PaymentReady extends PaymentState {
  final Plan plan;
  final String paymentUrl;
  
  const PaymentReady({
    required this.plan,
    required this.paymentUrl,
  });
  
  @override
  List<Object?> get props => [plan, paymentUrl];
}

class PaymentCompleted extends PaymentState {
  final Plan plan;
  
  const PaymentCompleted({required this.plan});
  
  @override
  List<Object?> get props => [plan];
}

class PaymentError extends PaymentState {
  final String message;
  
  const PaymentError(this.message);
  
  @override
  List<Object?> get props => [message];
}