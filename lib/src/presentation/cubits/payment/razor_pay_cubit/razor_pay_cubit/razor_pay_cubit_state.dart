// lib/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_state.dart
import 'package:foodam/src/domain/entities/payment_entity.dart';

// State class for Razorpay payment
abstract class RazorpayPaymentState {
  const RazorpayPaymentState();
}

class RazorpayPaymentInitial extends RazorpayPaymentState {}

class RazorpayPaymentLoading extends RazorpayPaymentState {}

// Simple success state with just the payment
class RazorpayPaymentSuccess extends RazorpayPaymentState {
  final Payment payment;

  RazorpayPaymentSuccess({required this.payment});
}

// Success state with just IDs, for when we don't have a payment object yet
class RazorpayPaymentSuccessWithId extends RazorpayPaymentState {
  final String paymentId;
  final String orderId;
  final String signature;

  RazorpayPaymentSuccessWithId({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });
}

class RazorpayPaymentError extends RazorpayPaymentState {
  final String message;

  RazorpayPaymentError({required this.message});
}

class RazorpayExternalWallet extends RazorpayPaymentState {
  final String walletName;

  RazorpayExternalWallet({required this.walletName});
}
