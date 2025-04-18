// lib/src/domain/usecase/susbcription_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/repo/subscription_repo.dart';

/// Subscription action enum for managing subscriptions
enum SubscriptionAction { pause, resume, cancel }

/// Consolidated Subscription Use Case
///
/// This class combines multiple previously separate use cases related to subscriptions:
/// - GetActiveSubscriptionsUseCase
/// - GetSubscriptionByIdUseCase
/// - CreateSubscriptionUseCase
/// - PauseSubscriptionUseCase
/// - ResumeSubscriptionUseCase
/// - CancelSubscriptionUseCase
class SubscriptionUseCase {
  final SubscriptionRepository repository;

  SubscriptionUseCase(this.repository);

  /// Get all active subscriptions for the current user
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions() {
    return repository.getActiveSubscriptions();
  }

  /// Get details of a specific subscription by ID
  Future<Either<Failure, Subscription>> getSubscriptionById(
    String subscriptionId,
  ) {
    return repository.getSubscriptionById(subscriptionId);
  }

  /// Create a new subscription
  Future<Either<Failure, String>> createSubscription(
    SubscriptionParams params,
  ) async {
    // Convert slots to the format expected by the repository
    final slots =
        params.slots
            .map(
              (slot) => {
                'day': slot.day.toLowerCase(),
                'timing': slot.timing.toLowerCase(),
                'meal': slot.mealId ?? '',
              },
            )
            .toList();

    return await repository.createSubscription(
      packageId: params.packageId,
      startDate: params.startDate,
      durationDays: params.durationDays,
      addressId: params.addressId,
      instructions: params.instructions,
      slots: slots,
      personCount: params.personCount,
    );
  }

  /// Manage subscription (pause, resume, cancel)
  Future<Either<Failure, void>> manageSubscription(
    String subscriptionId,
    SubscriptionAction action, {
    DateTime? untilDate,
  }) async {
    switch (action) {
      case SubscriptionAction.pause:
        return repository.pauseSubscription(subscriptionId);

      case SubscriptionAction.resume:
        return repository.resumeSubscription(subscriptionId);

      case SubscriptionAction.cancel:
        return repository.cancelSubscription(subscriptionId);
    }
  }

  /// Calculate remaining days for a subscription
  int calculateRemainingDays(Subscription subscription) {
    final now = DateTime.now();
    final endDate = subscription.startDate.add(
      Duration(days: subscription.durationDays),
    );

    if (now.isAfter(endDate)) {
      return 0;
    }

    return endDate.difference(now).inDays;
  }

  /// Calculate total meals in a subscription
  int calculateTotalMeals(Subscription subscription) {
    // If slots are provided, count them
    if (subscription.slots.isNotEmpty) {
      return subscription.slots.length;
    }

    // Use noOfSlots if available
    if (subscription.noOfSlots > 0) {
      return subscription.noOfSlots;
    }

    // Default: 21 meals (7 days x 3 meals)
    return 21;
  }
}

/// Parameters for creating a subscription
class SubscriptionParams {
  final String packageId;
  final DateTime startDate;
  final int durationDays;
  final String addressId;
  final String? instructions;
  final List<MealSlot> slots;
  final int personCount;

  SubscriptionParams({
    required this.packageId,
    required this.startDate,
    required this.durationDays,
    required this.addressId,
    this.instructions,
    required this.slots,
    this.personCount = 1,
  });
}

/// Parameters for pausing a subscription
class PauseSubscriptionParams {
  final String subscriptionId;
  final DateTime until;

  PauseSubscriptionParams({required this.subscriptionId, required this.until});
}
