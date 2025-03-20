
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';

class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required List<MealTemplateModel> super.weeklyMealTemplate,
    required List<PriceBreakdownModel> super.breakdown,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      weeklyMealTemplate: (json['weeklyMealTemplate'] as List)
          .map((template) => MealTemplateModel.fromJson(template))
          .toList(),
      breakdown: (json['breakdown'] as List)
          .map((item) => PriceBreakdownModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'weeklyMealTemplate': (weeklyMealTemplate as List<MealTemplateModel>)
          .map((template) => template.toJson())
          .toList(),
      'breakdown': (breakdown as List<PriceBreakdownModel>)
          .map((item) => item.toJson())
          .toList(),
    };
  }
}

class MealTemplateModel extends MealTemplate {
  const MealTemplateModel({
    required super.day,
    required super.timing,
    required super.meal,
  });

  factory MealTemplateModel.fromJson(Map<String, dynamic> json) {
    return MealTemplateModel(
      day: json['day'],
      timing: json['timing'],
      meal: json['meal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'timing': timing,
      'meal': meal,
    };
  }
}

class PriceBreakdownModel extends PriceBreakdown {
  const PriceBreakdownModel({
    required super.day,
    required super.timing,
    required super.price,
  });

  factory PriceBreakdownModel.fromJson(Map<String, dynamic> json) {
    return PriceBreakdownModel(
      day: json['day'],
      timing: json['timing'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'timing': timing,
      'price': price,
    };
  }
}
