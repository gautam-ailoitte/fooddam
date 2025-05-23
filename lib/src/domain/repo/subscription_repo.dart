// lib/src/domain/repo/subscription_repo.dart (UPDATE)
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order_entity;
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

import '../../data/datasource/remote_data_source.dart';
import '../entities/pagination_entity.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, PaginatedSubscriptions>> getSubscriptions({
    int? page,
    int? limit,
  });

  // NEW: Specific method for active subscriptions (returns List, not paginated)
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions();

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

  Future<Either<Failure, Subscription>> getSubscriptionById(
    String subscriptionId,
  );
  Future<Either<Failure, Subscription>> createSubscription({
    required DateTime startDate,
    required DateTime endDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required int noOfPersons,
    required List<WeekSubscription> weeks,
  });

  Future<Either<Failure, void>> cancelSubscription(String subscriptionId);
  Future<Either<Failure, void>> pauseSubscription(String subscriptionId);
  Future<Either<Failure, void>> resumeSubscription(String subscriptionId);
}

class PaginatedOrders {
  final List<order_entity.Order> orders;
  final Pagination pagination;

  PaginatedOrders({required this.orders, required this.pagination});
}

class PaginatedSubscriptions {
  final List<Subscription> subscriptions;
  final Pagination pagination;

  PaginatedSubscriptions({
    required this.subscriptions,
    required this.pagination,
  });
}

class WeekSubscription {
  final String packageId;
  final List<MealSlotRequest> slots;

  WeekSubscription({required this.packageId, required this.slots});
}
