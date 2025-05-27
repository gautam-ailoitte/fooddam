// lib/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit.dart
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/data/client/dio_api_client.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/services/payment_service.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_state.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentCubit extends Cubit<RazorpayPaymentState> {
  final DioApiClient _apiClient;
  final LoggerService _logger = LoggerService();

  late final PaymentService _paymentService;

  RazorpayPaymentCubit({required DioApiClient apiClient})
    : _apiClient = apiClient,
      super(RazorpayPaymentInitial()) {
    _initPaymentService();
    _logger.i('RazorpayPaymentCubit initialized');
  }

  void _initPaymentService() {
    _logger.i('Initializing PaymentService');
    _paymentService = PaymentService(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
    _logger.i('PaymentService initialized successfully');
  }

  // Process payment for a specific subscription ID
  Future<void> processPaymentForSubscription(
    String subscriptionId,
    PaymentMethod paymentMethod,
  ) async {
    try {
      _logger.i('=============== PAYMENT FLOW STARTED ===============');
      _logger.i(
        'Processing payment for subscription: $subscriptionId with method: ${paymentMethod.toString()}',
      );

      emit(RazorpayPaymentLoading());

      // Log the request data
      final requestBody = {
        'subscriptionId': subscriptionId,
        'paymentMethod': _convertPaymentMethodToString(paymentMethod),
      };
      _logger.i('Payment process request: ${jsonEncode(requestBody)}');

      // 1. First API call to create the Razorpay order
      _logger.i('Making API call to create Razorpay order...');
      final response = await _apiClient.post(
        '/api/payment/process',
        body: requestBody,
      );

      // Log full response for debugging
      _logger.i('Payment process response: ${jsonEncode(response)}');

      if (response['status'] != 'success' || !response.containsKey('data')) {
        _logger.e(
          'Invalid payment process response format',
          error: 'Missing data or success status',
        );
        throw Exception('Invalid payment process response format');
      }

      final paymentData = response['data'];
      _logger.i('Payment data extracted: ${jsonEncode(paymentData)}');

      final orderId = paymentData['orderId'] as String;
      final amount = (paymentData['amount'] as num).toDouble();
      final keyId = paymentData['key_id'] as String;
      final customerInfo = paymentData['customerInfo'] as Map<String, dynamic>;

      _logger.i(
        'Order created with ID: $orderId, amount: $amount, keyId: $keyId',
      );
      _logger.i('Customer info: ${jsonEncode(customerInfo)}');

      // 2. Start the Razorpay payment flow
      _logger.i('Starting Razorpay payment flow...');
      final paymentOptions = {
        'orderId': orderId,
        'amount': amount,
        'name': 'Foodam',
        'description': 'Payment for food delivery subscription',
        'email': customerInfo['email'] ?? '',
        'contact': customerInfo['phone'] ?? '',
        'keyId': keyId,
        'prefillMethod': _getPaymentMethodForRazorpay(paymentMethod),
      };
      _logger.i('Payment options: ${jsonEncode(paymentOptions)}');

      _paymentService.startPayment(
        orderId: orderId,
        amount: amount,
        name: 'Foodam',
        description: 'Payment for food delivery subscription',
        email: customerInfo['email'] ?? '',
        contact: customerInfo['phone'] ?? '',
        keyId: keyId, // Use the key_id received from API
        prefillMethod: _getPaymentMethodForRazorpay(paymentMethod),
      );
      _logger.i('Razorpay payment flow started successfully');
    } catch (e) {
      _logger.e('Failed to process payment', error: e);
      _logger.e(
        'Error stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}',
      );
      emit(
        RazorpayPaymentError(
          message: 'Failed to process payment: ${e.toString()}',
        ),
      );
    }
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
      _logger.i('=============== DIRECT PAYMENT FLOW STARTED ===============');
      _logger.i('Initiating direct payment for amount $amount');
      _logger.i('User: $userName, Email: $email, Contact: $contact');
      _logger.i('Payment method: ${paymentMethod.toString()}');

      emit(RazorpayPaymentLoading());

      // If no order ID is provided, generate one for demo purposes
      final String paymentOrderId =
          orderId ?? 'order_demo_${DateTime.now().millisecondsSinceEpoch}';
      _logger.i('Using order ID: $paymentOrderId');

      final paymentOptions = {
        'orderId': paymentOrderId,
        'amount': amount,
        'name': 'Foodam ${userName.isNotEmpty ? "- $userName" : ""}',
        'description': description ?? 'Payment for food delivery subscription',
        'email': email,
        'contact': contact,
        'prefillMethod': _getPaymentMethodForRazorpay(paymentMethod),
      };
      _logger.i('Payment options: ${jsonEncode(paymentOptions)}');

      _paymentService.startPayment(
        orderId: paymentOrderId,
        amount: amount,
        name: 'Foodam ${userName.isNotEmpty ? "- $userName" : ""}',
        description: description ?? 'Payment for food delivery subscription',
        email: email,
        contact: contact,
        prefillMethod: _getPaymentMethodForRazorpay(paymentMethod),
      );
      _logger.i('Direct payment flow started successfully');
    } catch (e) {
      _logger.e('Failed to initiate direct payment', error: e);
      _logger.e(
        'Error stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}',
      );
      emit(
        RazorpayPaymentError(
          message: 'Failed to initiate payment: ${e.toString()}',
        ),
      );
    }
  }

  // Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _logger.i('=============== PAYMENT SUCCESS CALLBACK ===============');
    _logger.i('Payment successful with following details:');
    _logger.i('Payment ID: ${response.paymentId}');
    _logger.i('Order ID: ${response.orderId}');
    _logger.i('Signature: ${response.signature}');

    emit(RazorpayPaymentLoading());

    try {
      // Verify the payment with our backend
      _logger.i('Starting payment verification process...');
      final verificationBody = {
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
      };
      _logger.i('Verification request: ${jsonEncode(verificationBody)}');

      final verifyResponse = await _apiClient.post(
        '/api/payment/verify-razorpay',
        body: verificationBody,
      );

      _logger.i('Verification response: ${jsonEncode(verifyResponse)}');

      if (verifyResponse['status'] != 'success') {
        final errorMessage = verifyResponse['message'] ?? 'Unknown error';
        _logger.e('Payment verification failed', error: errorMessage);
        throw Exception('Failed to verify payment: $errorMessage');
      }

      _logger.i('Payment verified successfully!');

      // Extra data logging if available
      if (verifyResponse.containsKey('data')) {
        _logger.i('Verification data: ${jsonEncode(verifyResponse['data'])}');
      }

      // Emit success state with the payment details
      emit(
        RazorpayPaymentSuccessWithId(
          paymentId: response.paymentId ?? '',
          orderId: response.orderId ?? '',
          signature: response.signature ?? '',
        ),
      );
      _logger.i('Payment success state emitted');
    } catch (e) {
      _logger.e('Error during payment verification', error: e);
      _logger.e(
        'Error stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}',
      );
      emit(
        RazorpayPaymentError(
          message: 'Error verifying payment: ${e.toString()}',
        ),
      );
    }
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    _logger.e('=============== PAYMENT ERROR CALLBACK ===============');
    _logger.e('Payment error occurred with following details:');
    _logger.e('Error code: ${response.code}');
    _logger.e('Error message: ${response.message}');
    _logger.e('Error details: ${response.error?.toString() ?? 'No details'}');

    emit(
      RazorpayPaymentError(
        message: 'Payment failed: ${response.message ?? "Unknown error"}',
      ),
    );
    _logger.i('Payment error state emitted');
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    _logger.i('=============== EXTERNAL WALLET CALLBACK ===============');
    _logger.i('External wallet selected: ${response.walletName}');

    emit(
      RazorpayExternalWallet(
        walletName: response.walletName ?? 'Unknown wallet',
      ),
    );
    _logger.i('External wallet state emitted');
  }

  // Convert our enum to the string value expected by the API
  String _convertPaymentMethodToString(PaymentMethod method) {
    String result;
    switch (method) {
      case PaymentMethod.creditCard:
        result = 'credit_card';
        break;
      case PaymentMethod.debitCard:
        result = 'debit_card';
        break;
      case PaymentMethod.upi:
        result = 'upi';
        break;
      case PaymentMethod.netBanking:
        result = 'net_banking';
        break;
      case PaymentMethod.wallet:
        result = 'wallet';
        break;
    }
    _logger.i('Converted payment method ${method.toString()} to: $result');
    return result;
  }

  // Get the payment method string for Razorpay
  String? _getPaymentMethodForRazorpay(PaymentMethod method) {
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
    _logger.i('Razorpay payment method for ${method.toString()}: $result');
    return result;
  }

  @override
  Future<void> close() {
    _logger.i('Disposing RazorpayPaymentCubit');
    _paymentService.dispose();
    return super.close();
  }
}
