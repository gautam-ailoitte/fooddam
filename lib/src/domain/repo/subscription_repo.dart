// lib/src/domain/repo/subscription_repository.dart
import 'package:dartz/dartz.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/domain/entities/meal_plan_selection.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<Subscription>>> getActiveSubscriptions();
  Future<Either<Failure, List<SubscriptionPlan>>> getSubscriptionPlans();
  Future<Either<Failure, Subscription>> getSubscriptionDetails(String subscriptionId);
  Future<Either<Failure, Subscription>> createSubscription(MealPlanSelection selection);
  Future<Either<Failure, void>> cancelSubscription(String subscriptionId);
  Future<Either<Failure, void>> pauseSubscription(String subscriptionId, DateTime until);
  Future<Either<Failure, void>> resumeSubscription(String subscriptionId);
  Future<Either<Failure, List<MealOrder>>> getTodayMealOrders();
  Future<Either<Failure, List<MealOrder>>> getMealOrdersByDate(DateTime date);
  Future<Either<Failure, List<MealOrder>>> getMealOrdersBySubscription(String subscriptionId);
}