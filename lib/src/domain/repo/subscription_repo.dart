// lib/src/domain/repo/subscription_repo.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions();
  Future<Either<Failure, Subscription>> getSubscriptionById(String subscriptionId);
  Future<Either<Failure, Subscription>> createSubscription({
    required String packageId, 
    required DateTime startDate, 
    required int durationDays, 
    required String addressId,
    String? instructions,
    required List<Map<String, String>> slots, // List of {day, timing, meal}
  });
  Future<Either<Failure, void>> updateSubscription(String subscriptionId, List<Map<String, String>> slots);
  Future<Either<Failure, void>> cancelSubscription(String subscriptionId);
  Future<Either<Failure, void>> pauseSubscription(String subscriptionId);
  Future<Either<Failure, void>> resumeSubscription(String subscriptionId);
}