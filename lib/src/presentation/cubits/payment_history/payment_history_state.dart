// lib/src/presentation/cubits/payment/payment_history_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';

abstract class PaymentHistoryState extends Equatable {
  const PaymentHistoryState();
  
  @override
  List<Object?> get props => [];
}

class PaymentHistoryInitial extends PaymentHistoryState {}

class PaymentHistoryLoading extends PaymentHistoryState {}

class PaymentHistoryLoaded extends PaymentHistoryState {
  final List<Payment> payments;
  final List<Payment> filteredPayments;
  final DateTime? startDate;
  final DateTime? endDate;
  
  const PaymentHistoryLoaded({
    required this.payments,
    required this.filteredPayments,
    this.startDate,
    this.endDate,
  });
  
  @override
  List<Object?> get props => [payments, filteredPayments, startDate, endDate];
}

class PaymentHistoryError extends PaymentHistoryState {
  final String message;
  
  const PaymentHistoryError(this.message);
  
  @override
  List<Object?> get props => [message];
}