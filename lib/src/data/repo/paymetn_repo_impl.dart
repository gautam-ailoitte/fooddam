// lib/src/data/repo/payment_repo_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Payment>> processPayment(
      String subscriptionId, double amount, PaymentMethod method) async {
    if (await networkInfo.isConnected) {
      try {
        // Implementation for processing payment
        // In a real implementation, this would call the remote data source
        // For now, we'll return a mock payment
        return Right(Payment(
          id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
          subscriptionId: subscriptionId,
          amount: amount,
          method: method,
          status: PaymentStatus.paid,
          timestamp: DateTime.now(),
          transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        ));
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getPaymentHistory() async {
    if (await networkInfo.isConnected) {
      try {
        // Implementation for getting payment history
        // In a real implementation, this would call the remote data source
        // For now, we'll return an empty list
        return const Right([]);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Payment>> getPaymentDetails(String paymentId) async {
    if (await networkInfo.isConnected) {
      try {
        // Implementation for getting payment details
        // In a real implementation, this would call the remote data source
        // For now, we'll return a mock payment
        return Right(Payment(
          id: paymentId,
          subscriptionId: 'sub_123',
          amount: 100.0,
          method: PaymentMethod.creditCard,
          status: PaymentStatus.paid,
          timestamp: DateTime.now(),
          transactionId: 'txn_123',
        ));
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}