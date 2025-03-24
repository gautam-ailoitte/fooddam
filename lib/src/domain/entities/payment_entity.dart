

// lib/src/domain/entities/payment.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

class Payment extends Equatable {
  final String id;
  final String subscriptionId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime timestamp;
  final String? transactionId;

  const Payment({
    required this.id,
    required this.subscriptionId,
    required this.amount,
    required this.method,
    required this.status,
    required this.timestamp,
    this.transactionId,
  });

  @override
  List<Object?> get props => [
        id,
        subscriptionId,
        amount,
        method,
        status,
        timestamp,
        transactionId,
      ];
}

enum PaymentMethod {
  creditCard,
  debitCard,
  upi,
  netBanking,
  wallet,
}