

import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.subscriptionId,
    required super.amount,
    required super.method,
    required super.status,
    required super.timestamp,
    super.transactionId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      subscriptionId: json['subscriptionId'],
      amount: json['amount'].toDouble(),
      method: _mapStringToPaymentMethod(json['method']),
      status: _mapStringToPaymentStatus(json['status']),
      timestamp: DateTime.parse(json['timestamp']),
      transactionId: json['transactionId'],
    );
  }

  static PaymentMethod _mapStringToPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'credit_card':
        return PaymentMethod.creditCard;
      case 'debit_card':
        return PaymentMethod.debitCard;
      case 'upi':
        return PaymentMethod.upi;
      case 'net_banking':
        return PaymentMethod.netBanking;
      case 'wallet':
        return PaymentMethod.wallet;
      default:
        return PaymentMethod.creditCard;
    }
  }

  static PaymentStatus _mapStringToPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'amount': amount,
      'method': _mapPaymentMethodToString(method),
      'status': _mapPaymentStatusToString(status),
      'timestamp': timestamp.toIso8601String(),
      'transactionId': transactionId,
    };
  }

  static String _mapPaymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.debitCard:
        return 'debit_card';
      case PaymentMethod.upi:
        return 'upi';
      case PaymentMethod.netBanking:
        return 'net_banking';
      case PaymentMethod.wallet:
        return 'wallet';
    }
  }

  static String _mapPaymentStatusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }
}

