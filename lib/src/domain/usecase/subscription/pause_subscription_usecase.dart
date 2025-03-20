import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class PauseSubscriptionUseCase implements UseCaseWithParams<void, PauseSubscriptionParams> {
  final SubscriptionRepository repository;

  PauseSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PauseSubscriptionParams params) {
    return repository.pauseSubscription(params.subscriptionId, params.until);
  }
}

class PauseSubscriptionParams {
  final String subscriptionId;
  final DateTime until;

  PauseSubscriptionParams({required this.subscriptionId, required this.until});
}