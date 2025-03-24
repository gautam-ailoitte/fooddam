// lib/src/presentation/cubits/payment/payment_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/usecase/payment_usecase.dart';
import 'package:foodam/src/presentation/cubits/payment_history/payment_state.dart';

/// Consolidated Payment Cubit
///
/// This class combines multiple previously separate cubits:
/// - PaymentCubit
/// - PaymentHistoryCubit
class PaymentCubit extends Cubit<PaymentState> {
  final PaymentUseCase _paymentUseCase;
  final LoggerService _logger = LoggerService();

  PaymentCubit({
    required PaymentUseCase paymentUseCase,
  }) : 
    _paymentUseCase = paymentUseCase,
    super(const PaymentInitial());

  /// Process a payment for a subscription
  Future<void> processPayment({
    required String subscriptionId,
    required double amount,
    required PaymentMethod method,
  }) async {
    emit(const PaymentLoading());
    
    final params = PaymentParams(
      subscriptionId: subscriptionId,
      amount: amount,
      method: method,
    );
    
    final result = await _paymentUseCase.processPayment(params);
    
    result.fold(
      (failure) {
        _logger.e('Payment processing failed', error: failure);
        emit(PaymentError(message: 'Failed to process payment'));
      },
      (payment) {
        _logger.i('Payment processed successfully: ${payment.id}');
        emit(PaymentSuccess(payment: payment));
      },
    );
  }

  /// Load payment history
  Future<void> loadPaymentHistory() async {
    emit(const PaymentLoading());
    
    final result = await _paymentUseCase.getPaymentHistory();
    
    result.fold(
      (failure) {
        _logger.e('Failed to get payment history', error: failure);
        emit(PaymentError(message: 'Failed to load payment history'));
      },
      (payments) {
        _logger.i('Payment history loaded: ${payments.length} payments');
        emit(PaymentHistoryLoaded(
          payments: payments,
          filteredPayments: payments,
        ));
      },
    );
  }

  /// Filter payment history by date range
  Future<void> filterPaymentsByDateRange(DateTime? startDate, DateTime? endDate) async {
    if (state is! PaymentHistoryLoaded) {
      return;
    }
    
    final currentState = state as PaymentHistoryLoaded;
    
    emit(const PaymentLoading());
    
    final result = await _paymentUseCase.filterPaymentsByDateRange(startDate, endDate);
    
    result.fold(
      (failure) {
        _logger.e('Failed to filter payments', error: failure);
        emit(PaymentError(message: 'Failed to filter payment history'));
        
        // Restore previous state
        emit(currentState);
      },
      (filteredPayments) {
        _logger.i('Payment history filtered: ${filteredPayments.length} payments');
        emit(PaymentHistoryLoaded(
          payments: currentState.payments,
          filteredPayments: filteredPayments,
          startDate: startDate,
          endDate: endDate,
        ));
      },
    );
  }

  /// Load payment details
  Future<void> loadPaymentDetails(String paymentId) async {
    emit(const PaymentLoading());
    
    final result = await _paymentUseCase.getPaymentDetails(paymentId);
    
    result.fold(
      (failure) {
        _logger.e('Failed to get payment details', error: failure);
        emit(PaymentError(message: 'Failed to load payment details'));
      },
      (payment) {
        _logger.i('Payment details loaded: ${payment.id}');
        emit(PaymentDetailLoaded(payment: payment));
      },
    );
  }
  
  /// Clear date filters for payment history
  void clearDateFilters() {
    if (state is PaymentHistoryLoaded) {
      final currentState = state as PaymentHistoryLoaded;
      emit(PaymentHistoryLoaded(
        payments: currentState.payments,
        filteredPayments: currentState.payments,
      ));
    }
  }
}