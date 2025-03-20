
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

class ResumeSubscriptionUseCase implements UseCaseWithParams<void, String> {
  final SubscriptionRepository repository;

  ResumeSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.resumeSubscription(params);
  }
}