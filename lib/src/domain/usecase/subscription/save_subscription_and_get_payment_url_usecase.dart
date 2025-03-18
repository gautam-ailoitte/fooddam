// lib/src/domain/usecase/subscription/save_subscription_and_get_payment_url_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class SaveSubscriptionAndGetPaymentUrlUseCase extends UseCaseWithParams<String, Subscription> {
  final SubscriptionRepository repository;

  SaveSubscriptionAndGetPaymentUrlUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(Subscription subscription) {
    return repository.saveSubscriptionAndGetPaymentUrl(subscription);
  }
}