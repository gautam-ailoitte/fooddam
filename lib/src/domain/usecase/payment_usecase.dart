// lib/src/domain/usecase/payment/payment_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

/// Consolidated Payment Use Case
///
/// This class combines multiple previously separate use cases related to payments:
/// - ProcessPaymentUseCase
/// - GetPaymentHistoryUseCase
/// - GetPaymentDetailsUseCase
class PaymentUseCase {
  final PaymentRepository repository;

  PaymentUseCase(this.repository);

  /// Process a payment for a subscription
  Future<Either<Failure, Payment>> processPayment(PaymentParams params) {
    return repository.processPayment(
      params.subscriptionId,
      params.amount,
      params.method,
    );
  }

  /// Get payment history for the current user
  Future<Either<Failure, List<Payment>>> getPaymentHistory() {
    return repository.getPaymentHistory();
  }

  /// Get details of a specific payment
  Future<Either<Failure, Payment>> getPaymentDetails(String paymentId) {
    return repository.getPaymentDetails(paymentId);
  }
  
  /// Filter payment history by date range
  Future<Either<Failure, List<Payment>>> filterPaymentsByDateRange(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final result = await getPaymentHistory();
    
    return result.fold(
      (failure) => Left(failure),
      (payments) {
        if (startDate == null && endDate == null) {
          return Right(payments);
        }
        
        List<Payment> filtered = List.from(payments);
        
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
        
        return Right(filtered);
      },
    );
  }
}

/// Parameters for processing a payment
class PaymentParams {
  final String subscriptionId;
  final double amount;
  final PaymentMethod method;

  PaymentParams({
    required this.subscriptionId,
    required this.amount,
    required this.method,
  });
}