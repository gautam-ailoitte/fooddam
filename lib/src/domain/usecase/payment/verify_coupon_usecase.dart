// lib/src/domain/usecase/payment/verify_coupon_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/repo/payment_repo.dart';

class VerifyCouponParams {
  final String couponCode;
  final double orderAmount;

  VerifyCouponParams({
    required this.couponCode,
    required this.orderAmount,
  });
}

class VerifyCouponUseCase extends UseCaseWithParams<Coupon, VerifyCouponParams> {
  final PaymentRepository repository;

  VerifyCouponUseCase(this.repository);

  @override
  Future<Either<Failure, Coupon>> call(VerifyCouponParams params) {
    return repository.verifyCoupon(params.couponCode, params.orderAmount);
  }
}