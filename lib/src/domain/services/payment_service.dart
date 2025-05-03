// lib/src/domain/services/payment_service.dart
import 'dart:convert';

import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef OnPaymentSuccessCallback =
    void Function(PaymentSuccessResponse response);
typedef OnPaymentErrorCallback = void Function(PaymentFailureResponse response);
typedef OnExternalWalletCallback =
    void Function(ExternalWalletResponse response);

class PaymentService {
  final Razorpay _razorpay = Razorpay();
  final LoggerService _logger = LoggerService();

  final OnPaymentSuccessCallback onPaymentSuccess;
  final OnPaymentErrorCallback onPaymentError;
  final OnExternalWalletCallback onExternalWallet;

  PaymentService({
    required this.onPaymentSuccess,
    required this.onPaymentError,
    required this.onExternalWallet,
  }) {
    _logger.i('PaymentService: Initializing Razorpay event handlers');
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccessInternal);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentErrorInternal);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWalletInternal);
    _logger.i('PaymentService: Event handlers initialized');
  }

  // Wrapper methods with logging
  void _onPaymentSuccessInternal(PaymentSuccessResponse response) {
    _logger.i('PaymentService: Payment success callback received');
    _logger.i('PaymentService: Payment ID: ${response.paymentId}');
    _logger.i('PaymentService: Order ID: ${response.orderId}');
    _logger.i('PaymentService: Signature: ${response.signature}');
    onPaymentSuccess(response);
  }

  void _onPaymentErrorInternal(PaymentFailureResponse response) {
    _logger.e('PaymentService: Payment error callback received');
    _logger.e('PaymentService: Error code: ${response.code}');
    _logger.e('PaymentService: Error message: ${response.message}');
    _logger.e(
      'PaymentService: Error details: ${response.error?.toString() ?? 'No details'}',
    );
    onPaymentError(response);
  }

  void _onExternalWalletInternal(ExternalWalletResponse response) {
    _logger.i('PaymentService: External wallet callback received');
    _logger.i('PaymentService: Wallet name: ${response.walletName}');
    onExternalWallet(response);
  }

  void startPayment({
    required String orderId,
    required double amount,
    required String name,
    required String description,
    required String email,
    required String contact,
    String? keyId,
    String? prefillMethod,
  }) {
    try {
      _logger.i('PaymentService: Starting payment with the following details:');
      _logger.i('PaymentService: Order ID: $orderId');
      _logger.i('PaymentService: Amount: $amount');
      _logger.i('PaymentService: Name: $name');
      _logger.i('PaymentService: Description: $description');
      _logger.i('PaymentService: Email: $email');
      _logger.i('PaymentService: Contact: $contact');
      _logger.i('PaymentService: Key ID: ${keyId ?? 'Using default'}');
      _logger.i('PaymentService: Prefill method: ${prefillMethod ?? 'None'}');

      final options = {
        'key':
            keyId ?? 'rzp_test_NgeGgZwX4WcI6d', // Use provided key or default
        'amount':
            amount
                .toInt()
                .toString(), // Amount is already in paise from backend
        'name': name,
        'description': description,
        'order_id': orderId,
        'prefill': {'contact': contact, 'email': email},
        'theme': {'color': '#3399cc'},
      };

      // // Add method if provided
      // if (prefillMethod != null) {
      //   options['prefill']['method'] = prefillMethod;
      // }

      _logger.i('PaymentService: Final options: ${jsonEncode(options)}');
      _razorpay.open(options);
      _logger.i('PaymentService: Razorpay checkout opened successfully');
    } catch (e) {
      _logger.e('PaymentService: Error opening Razorpay checkout', error: e);
      _logger.e(
        'PaymentService: Error stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}',
      );
      throw Exception('Error starting payment: ${e.toString()}');
    }
  }

  // Convert our payment method enum to Razorpay's expected string format
  String? getPaymentMethodForRazorpay(PaymentMethod method) {
    String? result;
    switch (method) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        result = 'card';
        break;
      case PaymentMethod.upi:
        result = 'upi';
        break;
      case PaymentMethod.netBanking:
        result = 'netbanking';
        break;
      case PaymentMethod.wallet:
        result = 'wallet';
        break;
    }
    _logger.i(
      'PaymentService: Converted ${method.toString()} to Razorpay method: $result',
    );
    return result;
  }

  void dispose() {
    _logger.i('PaymentService: Disposing Razorpay instance');
    _razorpay.clear();
    _logger.i('PaymentService: Razorpay instance disposed');
  }
}
