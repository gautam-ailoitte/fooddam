// lib/src/domain/entities/subscription_plan.dart
import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<MealTemplate> weeklyMealTemplate;
  final List<PriceBreakdown> breakdown;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.weeklyMealTemplate,
    required this.breakdown,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        weeklyMealTemplate,
        breakdown,
      ];
}

class MealTemplate extends Equatable {
  final String day;
  final String timing;
  final String meal;

  const MealTemplate({
    required this.day,
    required this.timing,
    required this.meal,
  });

  @override
  List<Object?> get props => [day, timing, meal];
}

class PriceBreakdown extends Equatable {
  final String day;
  final String timing;
  final double price;

  const PriceBreakdown({
    required this.day,
    required this.timing,
    required this.price,
  });

  @override
  List<Object?> get props => [day, timing, price];
}