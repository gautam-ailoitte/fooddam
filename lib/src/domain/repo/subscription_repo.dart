// lib/src/domain/repo/subscription_repo.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order_entity;
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

import '../entities/pagination_entity.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions();
  Future<Either<Failure, Subscription>> getSubscriptionById(
    String subscriptionId,
  );

  // New methods for upcoming and past orders
  Future<Either<Failure, PaginatedOrders>> getUpcomingOrders({
    int? page,
    int? limit,
    String? dayContext,
  });

  Future<Either<Failure, PaginatedOrders>> getPastOrders({
    int? page,
    int? limit,
    String? dayContext,
  });

  // Original methods remain unchanged
  Future<Either<Failure, List<String>>> createSubscription({
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required int personCount,
    required List<Map<String, String>> slots,
  });
  Future<Either<Failure, void>> updateSubscription(
    String subscriptionId,
    List<Map<String, String>> slots,
  );
  Future<Either<Failure, void>> cancelSubscription(String subscriptionId);
  Future<Either<Failure, void>> pauseSubscription(String subscriptionId);
  Future<Either<Failure, void>> resumeSubscription(String subscriptionId);
}

class PaginatedOrders {
  final List<order_entity.Order> orders;
  final Pagination pagination;

  PaginatedOrders({required this.orders, required this.pagination});
}
