// lib/src/domain/usecases/meal_planning/create_subscription_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/meal_planning/subscription_request_entity.dart';
import 'package:foodam/src/domain/repo/meal_planning_repository.dart';

class CreateSubscriptionUseCase
    implements
        UseCaseWithParams<SubscriptionResponse, CreateSubscriptionParams> {
  final MealPlanningRepository repository;

  const CreateSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionResponse>> call(
    CreateSubscriptionParams params,
  ) async {
    return await repository.createSubscription(request: params.request);
  }
}

class CreateSubscriptionParams extends Equatable {
  final SubscriptionRequest request;

  const CreateSubscriptionParams({required this.request});

  @override
  List<Object> get props => [request];
}
