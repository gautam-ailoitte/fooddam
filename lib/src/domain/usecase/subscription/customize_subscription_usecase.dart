// lib/src/domain/usecase/subscription/customize_subscription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class CustomizeSubscriptionParams {
  final String subscriptionId;
  final List<MealPreference>? mealPreferences;
  final DeliverySchedule? deliverySchedule;
  final Address? deliveryAddress;

  CustomizeSubscriptionParams({
    required this.subscriptionId,
    this.mealPreferences,
    this.deliverySchedule,
    this.deliveryAddress,
  });
}

class CustomizeSubscriptionUseCase
    extends UseCaseWithParams<Subscription, CustomizeSubscriptionParams> {
  final SubscriptionRepository repository;

  CustomizeSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(CustomizeSubscriptionParams params) {
    return repository.customizeSubscription(
      params.subscriptionId,
      mealPreferences: params.mealPreferences,
      deliverySchedule: params.deliverySchedule,
      deliveryAddress: params.deliveryAddress,
    );
  }
}