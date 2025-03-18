// lib/src/presentation/cubits/payment/payment_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/usecase/payment/process_payment_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/verify_coupon_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/get_payment_history_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/get_payment_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/payment/request_refund_usecase.dart';
import 'package:foodam/src/presentation/cubits/payment/payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final ProcessPaymentUseCase _processPaymentUseCase;
  final VerifyCouponUseCase _verifyCouponUseCase;
  final GetPaymentHistoryUseCase _getPaymentHistoryUseCase;
  final GetPaymentByIdUseCase _getPaymentByIdUseCase;
  final RequestRefundUseCase _requestRefundUseCase;

  PaymentCubit({
    required ProcessPaymentUseCase processPaymentUseCase,
    required VerifyCouponUseCase verifyCouponUseCase,
    required GetPaymentHistoryUseCase getPaymentHistoryUseCase,
    required GetPaymentByIdUseCase getPaymentByIdUseCase,
    required RequestRefundUseCase requestRefundUseCase,
  })  : _processPaymentUseCase = processPaymentUseCase,
        _verifyCouponUseCase = verifyCouponUseCase,
        _getPaymentHistoryUseCase = getPaymentHistoryUseCase,
        _getPaymentByIdUseCase = getPaymentByIdUseCase,
        _requestRefundUseCase = requestRefundUseCase,
        super(PaymentInitial());

  Future<void> processPayment({
    required String orderId,
    required PaymentMethod paymentMethod,
    String? couponCode,
    Map<String, dynamic>? paymentDetails,
  }) async {
    emit(PaymentLoading());
    
    final params = ProcessPaymentParams(
      orderId: orderId,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
      paymentDetails: paymentDetails,
    );
    
    final result = await _processPaymentUseCase(params);
    
    result.fold(
      (failure) => emit(PaymentError(message: _mapFailureToMessage(failure))),
      (payment) => emit(PaymentProcessed(payment: payment)),
    );
  }

  Future<void> verifyCoupon(String couponCode, double orderAmount) async {
    emit(PaymentLoading());
    
    final params = VerifyCouponParams(
      couponCode: couponCode,
      orderAmount: orderAmount,
    );
    
    final result = await _verifyCouponUseCase(params);
    
    result.fold(
      (failure) => emit(PaymentError(message: _mapFailureToMessage(failure))),
      (coupon) => emit(CouponVerified(coupon: coupon)),
    );
  }

  Future<void> getPaymentHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    emit(PaymentLoading());
    
    final params = GetPaymentHistoryParams(
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
    
    final result = await _getPaymentHistoryUseCase(params);
    
    result.fold(
      (failure) => emit(PaymentError(message: _mapFailureToMessage(failure))),
      (payments) => emit(PaymentHistoryLoaded(payments: payments)),
    );
  }

  Future<void> getPaymentById(String paymentId) async {
    emit(PaymentLoading());
    
    final result = await _getPaymentByIdUseCase(paymentId);
    
    result.fold(
      (failure) => emit(PaymentError(message: _mapFailureToMessage(failure))),
      (payment) => emit(PaymentLoaded(payment: payment)),
    );
  }

  Future<void> requestRefund(
    String paymentId,
    double amount,
    String reason,
  ) async {
    emit(PaymentLoading());
    
    final params = RequestRefundParams(
      paymentId: paymentId,
      amount: amount,
      reason: reason,
    );
    
    final result = await _requestRefundUseCase(params);
    
    result.fold(
      (failure) => emit(PaymentError(message: _mapFailureToMessage(failure))),
      (payment) => emit(RefundRequested(payment: payment)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again.';
      case NetworkFailure:
        return 'Network error occurred. Please check your connection.';
      case CacheFailure:
        return 'Cache error occurred. Please restart the app.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}