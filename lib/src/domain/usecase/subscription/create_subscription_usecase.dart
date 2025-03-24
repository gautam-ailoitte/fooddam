
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class CreateSubscriptionUseCase implements UseCaseWithParams<Subscription, CreateSubscriptionParams> {
  final SubscriptionRepository repository;

  CreateSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(CreateSubscriptionParams params) {
    return repository.createSubscription(
      packageId: params.packageId,
      startDate: params.startDate,
      durationDays: params.durationDays,
      addressId: params.addressId,
      instructions: params.instructions,
      slots: params.slots,
    );
  }
}

class CreateSubscriptionParams {
  final String packageId;
  final DateTime startDate;
  final int durationDays;
  final String addressId;
  final String? instructions;
  final List<Map<String, String>> slots;

  CreateSubscriptionParams({
    required this.packageId,
    required this.startDate,
    required this.durationDays,
    required this.addressId,
    this.instructions,
    required this.slots,
  });
}

