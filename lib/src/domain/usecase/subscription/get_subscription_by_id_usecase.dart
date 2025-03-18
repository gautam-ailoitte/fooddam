// lib/src/domain/usecase/subscription/get_subscription_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class GetSubscriptionByIdUseCase extends UseCaseWithParams<Subscription, String> {
  final SubscriptionRepository repository;

  GetSubscriptionByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(String subscriptionId) {
    return repository.getSubscriptionById(subscriptionId);
  }
}