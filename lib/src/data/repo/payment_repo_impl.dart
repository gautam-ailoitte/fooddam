import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
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
        // Convert PaymentMethod enum to string for API
        final methodString = _mapPaymentMethodToString(method);
        
        final payment = await remoteDataSource.processPayment(
          subscriptionId,
          amount,
          methodString,
        );
        return Right(payment);
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
        final payments = await remoteDataSource.getPaymentHistory();
        return Right(payments);
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
        final payment = await remoteDataSource.getPaymentDetails(paymentId);
        return Right(payment);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  String _mapPaymentMethodToString(PaymentMethod method) {
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
}