// lib/src/presentation/cubits/payment/payment_history_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/usecase/payment/get_payment_history_usecase.dart';
import 'package:foodam/src/presentation/cubits/payment_history/payment_history_state.dart';

class PaymentHistoryCubit extends Cubit<PaymentHistoryState> {
  final GetPaymentHistoryUseCase _getPaymentHistoryUseCase;
  final LoggerService _logger = LoggerService();

  PaymentHistoryCubit({
    required GetPaymentHistoryUseCase getPaymentHistoryUseCase,
  }) : 
    _getPaymentHistoryUseCase = getPaymentHistoryUseCase,
    super(PaymentHistoryInitial());

  Future<void> getPaymentHistory() async {
    emit(PaymentHistoryLoading());
    
    final result = await _getPaymentHistoryUseCase();
    
    result.fold(
      (failure) {
        _logger.e('Failed to get payment history', error: failure);
        emit(PaymentHistoryError('Failed to load payment history'));
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

  void filterByDate(DateTime? startDate, DateTime? endDate) {
    if (state is PaymentHistoryLoaded) {
      final currentState = state as PaymentHistoryLoaded;
      
      if (startDate == null && endDate == null) {
        emit(PaymentHistoryLoaded(
          payments: currentState.payments,
          filteredPayments: currentState.payments,
        ));
        return;
      }
      
      List<Payment> filtered = List.from(currentState.payments);
      
      if (startDate != null) {
        filtered = filtered.where((payment) => 
          payment.timestamp.isAfter(startDate) || 
          payment.timestamp.isAtSameMomentAs(startDate)
        ).toList();
      }
      
      if (endDate != null) {
        // Make the end date inclusive by setting it to the end of the day
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        
        filtered = filtered.where((payment) => 
          payment.timestamp.isBefore(endOfDay) || 
          payment.timestamp.isAtSameMomentAs(endOfDay)
        ).toList();
      }
      
      _logger.i('Payment history filtered: ${filtered.length} payments');
      emit(PaymentHistoryLoaded(
        payments: currentState.payments,
        filteredPayments: filtered,
        startDate: startDate,
        endDate: endDate,
      ));
    }
  }
}