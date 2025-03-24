// lib/src/presentation/cubits/payment/payment_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

/// Base state for all payment-related states
abstract class PaymentState extends Equatable {
  const PaymentState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when no payment data has been loaded
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// Loading state for payment operations
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// State for when a payment is successfully processed
class PaymentSuccess extends PaymentState {
  final Payment payment;
  final String? message;
  
  const PaymentSuccess({
    required this.payment,
    this.message,
  });
  
  @override
  List<Object?> get props => [payment, message];
}

/// State for when payment history is loaded
class PaymentHistoryLoaded extends PaymentState {
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
  
  bool get isFiltered => 
      startDate != null || endDate != null;
      
  bool get hasPayments => 
      filteredPayments.isNotEmpty;
      
  double get totalAmount => 
      filteredPayments.fold(0, (sum, payment) => sum + payment.amount);
      
  Map<PaymentMethod, int> get paymentMethodCounts {
    final counts = <PaymentMethod, int>{};
    for (final payment in filteredPayments) {
      counts[payment.method] = (counts[payment.method] ?? 0) + 1;
    }
    return counts;
  }
  
  Map<PaymentStatus, int> get paymentStatusCounts {
    final counts = <PaymentStatus, int>{};
    for (final payment in filteredPayments) {
      counts[payment.status] = (counts[payment.status] ?? 0) + 1;
    }
    return counts;
  }
  
  List<Payment> getPaymentsByMonth(int month, int year) {
    return filteredPayments.where((payment) => 
      payment.timestamp.month == month && 
      payment.timestamp.year == year
    ).toList();
  }
}

/// State for when a specific payment's details are loaded
class PaymentDetailLoaded extends PaymentState {
  final Payment payment;
  
  const PaymentDetailLoaded({required this.payment});
  
  @override
  List<Object?> get props => [payment];
  
  bool get isSuccessful => 
      payment.status == PaymentStatus.paid;
      
  bool get isFailed => 
      payment.status == PaymentStatus.failed;
      
  bool get isPending => 
      payment.status == PaymentStatus.pending;
      
  bool get isRefunded => 
      payment.status == PaymentStatus.refunded;
}

/// Error state for payment operations
class PaymentError extends PaymentState {
  final String message;
  
  const PaymentError({required this.message});
  
  @override
  List<Object?> get props => [message];
}