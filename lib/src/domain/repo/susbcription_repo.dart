// lib/src/domain/repositories/subscription_repository.dart
// Previously plan_repo.dart

import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

abstract class SubscriptionRepository {
  /// Get all available subscription templates
  Future<Either<Failure, List<Subscription>>> getAvailableSubscriptions();

  /// Get user's active subscription if exists
  Future<Either<Failure, Subscription?>> getActiveSubscription();

  /// Create a new subscription
  Future<Either<Failure, Subscription>> createSubscription({
    required SubscriptionDuration duration,
    required DateTime startDate,
    required List<MealPreference> mealPreferences,
    required DeliverySchedule deliverySchedule,
    required Address deliveryAddress,
    String? paymentMethodId,
  });

  /// Customize a subscription
  Future<Either<Failure, Subscription>> customizeSubscription(
    String subscriptionId, {
    List<MealPreference>? mealPreferences,
    DeliverySchedule? deliverySchedule,
    Address? deliveryAddress,
  });

  /// Save a draft subscription
  Future<Either<Failure, Subscription>> saveDraftSubscription(Subscription subscription);

  /// Get draft subscription
  Future<Either<Failure, Subscription?>> getDraftSubscription();

  /// Clear draft subscription
  Future<Either<Failure, void>> clearDraftSubscription();

  /// Save subscription and get payment URL
  Future<Either<Failure, String>> saveSubscriptionAndGetPaymentUrl(Subscription subscription);
  
  /// Pause a subscription
  Future<Either<Failure, Subscription>> pauseSubscription(
    String subscriptionId,
    DateTime resumeDate,
  );
  
  /// Resume a paused subscription
  Future<Either<Failure, Subscription>> resumeSubscription(String subscriptionId);
  
  /// Cancel a subscription
  Future<Either<Failure, Subscription>> cancelSubscription(String subscriptionId, String reason);
  
  /// Renew a subscription
  Future<Either<Failure, Subscription>> renewSubscription(String subscriptionId);
  
  /// Get subscription details
  Future<Either<Failure, Subscription>> getSubscriptionById(String subscriptionId);
  
  /// Get subscription history
  Future<Either<Failure, List<Subscription>>> getSubscriptionHistory();
  
  /// Update subscription payment method
  Future<Either<Failure, Subscription>> updatePaymentMethod(
    String subscriptionId,
    String paymentMethodId,
  );
}