// lib/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/services/payment_service.dart';
import 'package:foodam/src/domain/usecase/payment_usecase.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_state.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentCubit extends Cubit<RazorpayPaymentState> {
  final PaymentUseCase _paymentUseCase;
  final LoggerService _logger = LoggerService();

  late final PaymentService _paymentService;

  RazorpayPaymentCubit({required PaymentUseCase paymentUseCase})
    : _paymentUseCase = paymentUseCase,
      super(RazorpayPaymentInitial()) {
    _initPaymentService();
  }

  void _initPaymentService() {
    _paymentService = PaymentService(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  // Initiate payment without requiring a subscription ID first
  Future<void> initiatePayment({
    required double amount,
    required String userName,
    required String email,
    required String contact,
    required PaymentMethod paymentMethod,
    String? orderId,
    String? description,
  }) async {
    try {
      emit(RazorpayPaymentLoading());

      _logger.i('Initiating payment for amount $amount');

      // If no order ID is provided, generate one for demo purposes
      final String paymentOrderId =
          orderId ?? 'order_demo_${DateTime.now().millisecondsSinceEpoch}';

      _paymentService.startPayment(
        orderId: paymentOrderId,
        amount: amount,
        name: 'Foodam ${userName.isNotEmpty ? "- $userName" : ""}',
        description: description ?? 'Payment for food delivery subscription',
        email: email,
        contact: contact,
        prefillMethod: _paymentService.getPaymentMethodForRazorpay(
          paymentMethod,
        ),
      );
    } catch (e) {
      _logger.e('Failed to initiate payment', error: e);
      emit(
        RazorpayPaymentError(
          message: 'Failed to initiate payment: ${e.toString()}',
        ),
      );
    }
  }

  // Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _logger.i('Payment successful: ${response.paymentId}');

    emit(RazorpayPaymentLoading());

    try {
      // We'll record this successful payment without requiring a subscription ID
      // In a real implementation, you would connect this payment to the appropriate subscription
      // or order in your backend

      // For now, we'll emit a success state with the payment ID
      emit(
        RazorpayPaymentSuccessWithId(
          paymentId: response.paymentId ?? '',
          orderId: response.orderId ?? '',
          signature: response.signature ?? '',
        ),
      );

      /* 
      // This code would be used if you wanted to record the payment in your system
      // But we'll skip this for now as you mentioned it's handled separately
      
      final paymentParams = PaymentParams(
        subscriptionId: "<subscription_id_placeholder>", // This would need to be determined
        amount: 0.0, // Amount would come from your system
        method: PaymentMethod.upi, // This would be determined based on actual method used
        paymentId: response.paymentId,
      );
      
      final paymentResult = await _paymentUseCase.processPayment(paymentParams);
      
      paymentResult.fold(
        (failure) {
          _logger.e('Failed to process payment', error: failure);
          emit(RazorpayPaymentError(message: 'Failed to process payment: ${failure.message}'));
        },
        (payment) {
          _logger.i('Payment processed successfully');
          emit(RazorpayPaymentSuccess(payment: payment));
        },
      );
      */
    } catch (e) {
      _logger.e('Error processing successful payment', error: e);
      emit(
        RazorpayPaymentError(
          message: 'Error processing payment: ${e.toString()}',
        ),
      );
    }
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    _logger.e('Payment error: ${response.message}', error: response.code);
    emit(
      RazorpayPaymentError(
        message: 'Payment failed: ${response.message ?? "Unknown error"}',
      ),
    );
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    _logger.i('External wallet selected: ${response.walletName}');
    emit(
      RazorpayExternalWallet(
        walletName: response.walletName ?? 'Unknown wallet',
      ),
    );
  }

  @override
  Future<void> close() {
    _paymentService.dispose();
    return super.close();
  }
}
