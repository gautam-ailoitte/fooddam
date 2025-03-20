import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class GetSubscriptionDetailsUseCase implements UseCaseWithParams<Subscription, String> {
  final SubscriptionRepository repository;

  GetSubscriptionDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(String params) {
    return repository.getSubscriptionDetails(params);
  }
}