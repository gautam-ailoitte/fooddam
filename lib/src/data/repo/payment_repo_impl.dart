// lib/src/data/repositories/payment_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/network/network_info.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
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
  Future<Either<Failure, Payment>> processPayment({
    required String orderId,
    required PaymentMethod paymentMethod,
    String? couponCode,
    Map<String, dynamic>? paymentDetails,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final payment = await remoteDataSource.processPayment(
          orderId: orderId,
          paymentMethod: paymentMethod,
          couponCode: couponCode,
          paymentDetails: paymentDetails,
        );
        return Right(payment);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Coupon>> verifyCoupon(String couponCode, double orderAmount) async {
    if (await networkInfo.isConnected) {
      try {
        final coupon = await remoteDataSource.verifyCoupon(couponCode, orderAmount);
        return Right(coupon);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getPaymentHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final payments = await remoteDataSource.getPaymentHistory(
          startDate: startDate,
          endDate: endDate,
          page: page,
          limit: limit,
        );
        return Right(payments);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Payment>> getPaymentById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        // Since our mock data source doesn't have this method, we'll use a workaround
        final payments = await remoteDataSource.getPaymentHistory();
        final payment = payments.where((payment) => payment.id == id).firstOrNull;
        
        if (payment == null) {
          return Left(ServerFailure());
        }
        
        return Right(payment);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Payment>> requestRefund(
    String paymentId,
    double amount,
    String reason,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        // Since our mock data source doesn't have this method, we'll simulate it
        // Get the payment
        final payments = await remoteDataSource.getPaymentHistory();
        final payment = payments.where((payment) => payment.id == paymentId).firstOrNull;
        
        if (payment == null) {
          return Left(ServerFailure());
        }
        
        // Create refunded payment
        final refundedPayment = Payment(
          id: payment.id,
          orderId: payment.orderId,
          userId: payment.userId,
          amount: payment.amount,
          currency: payment.currency,
          paymentMethod: payment.paymentMethod,
          status: PaymentStatus.refunded,
          transactionId: payment.transactionId,
          paymentGatewayResponse: {
            'status': 'refunded',
            'refundAmount': amount,
            'reason': reason,
            'refundDate': DateTime.now().toIso8601String(),
          },
          createdAt: payment.createdAt,
          updatedAt: DateTime.now(),
        );
        
        return Right(refundedPayment);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}