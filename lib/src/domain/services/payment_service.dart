// lib/src/domain/services/payment_service.dart
import 'dart:convert';

import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Service to handle Razorpay payment gateway integration
class PaymentService {
  final LoggerService _logger = LoggerService();
  late Razorpay _razorpay;

  // Callbacks for payment results
  final Function(PaymentSuccessResponse) onPaymentSuccess;
  final Function(PaymentFailureResponse) onPaymentError;
  final Function(ExternalWalletResponse) onExternalWallet;

  PaymentService({
    required this.onPaymentSuccess,
    required this.onPaymentError,
    required this.onExternalWallet,
  }) {
    _initializeRazorpay();
  }

  /// Initialize Razorpay with event listeners
  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

    _logger.i('Razorpay initialized successfully');
  }

  /// Start payment with Razorpay checkout
  void startPayment({
    required String orderId,
    required double amount,
    required String name,
    required String description,
    required String email,
    required String contact,
    String? prefillMethod,
  }) {
    try {
      // Convert amount to paise (Razorpay requires amount in smallest currency unit)
      final amountInPaise = (amount * 100).toInt();

      final options = {
        'key':
            'rzp_live_0SSx4HlWWffD1t', // Replace with your actual Razorpay key
        'amount': amountInPaise,
        'name': name,
        'description': description,
        'order_id': orderId,
        'prefill': {
          'contact': contact,
          'email': email,
          'method': prefillMethod, // Optional - UPI, card, netbanking, etc.
        },
        'external': {
          'wallets': ['paytm'],
        },
        'theme': {
          'color': '#FF5722', // App primary color
        },
      };

      _logger.i(
        'Starting Razorpay payment with options: ${jsonEncode(options)}',
      );
      _razorpay.open(options);
    } catch (e) {
      _logger.e('Error starting Razorpay payment', error: e);
      onPaymentError(PaymentFailureResponse(0, 'error in payment', {}));
    }
  }

  /// Helper method to get payment method string for Razorpay
  String? getPaymentMethodForRazorpay(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.upi:
        return 'upi';
      case PaymentMethod.creditCard:
        return 'card';
      case PaymentMethod.debitCard:
        return 'card';
      case PaymentMethod.netBanking:
        return 'netbanking';
      case PaymentMethod.wallet:
        return 'wallet';
      default:
        return null;
    }
  }

  /// Dispose Razorpay instance
  void dispose() {
    _razorpay.clear();
    _logger.i('Razorpay instance disposed');
  }
}
