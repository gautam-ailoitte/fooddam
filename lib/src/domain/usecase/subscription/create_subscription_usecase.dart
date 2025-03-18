// lib/src/domain/usecase/subscription/create_subscription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/usecases/usecase.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/susbcription_repo.dart';

class CreateSubscriptionParams {
  final SubscriptionDuration duration;
  final DateTime startDate;
  final List<MealPreference> mealPreferences;
  final DeliverySchedule deliverySchedule;
  final Address deliveryAddress;
  final String? paymentMethodId;

  CreateSubscriptionParams({
    required this.duration,
    required this.startDate,
    required this.mealPreferences,
    required this.deliverySchedule,
    required this.deliveryAddress,
    this.paymentMethodId,
  });
}

class CreateSubscriptionUseCase
    extends UseCaseWithParams<Subscription, CreateSubscriptionParams> {
  final SubscriptionRepository repository;

  CreateSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, Subscription>> call(CreateSubscriptionParams params) {
    return repository.createSubscription(
      duration: params.duration,
      startDate: params.startDate,
      mealPreferences: params.mealPreferences,
      deliverySchedule: params.deliverySchedule,
      deliveryAddress: params.deliveryAddress,
      paymentMethodId: params.paymentMethodId,
    );
  }
}