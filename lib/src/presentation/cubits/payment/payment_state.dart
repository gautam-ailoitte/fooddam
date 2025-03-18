// lib/src/presentation/cubits/payment/payment_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PaymentProcessed extends PaymentState {
  final Payment payment;

  const PaymentProcessed({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class PaymentLoaded extends PaymentState {
  final Payment payment;

  const PaymentLoaded({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class PaymentHistoryLoaded extends PaymentState {
  final List<Payment> payments;

  const PaymentHistoryLoaded({required this.payments});

  @override
  List<Object?> get props => [payments];
}

class CouponVerified extends PaymentState {
  final Coupon coupon;

  const CouponVerified({required this.coupon});

  @override
  List<Object?> get props => [coupon];
}

class RefundRequested extends PaymentState {
  final Payment payment;

  const RefundRequested({required this.payment});

  @override
  List<Object?> get props => [payment];
}