// lib/src/data/repositories/meal_planning_repository_conv.dart
import 'package:foodam/src/domain/entities/meal_planning/calculated_plan_entity.dart';
import 'package:foodam/src/domain/entities/meal_planning/subscription_request_entity.dart';

import '../model/meal_planning/calculated_plan_model.dart';
import '../model/meal_planning/subscription_request_model.dart';

class MealPlanningRepositoryConv {
  // Convert CalculatedPlanModel to CalculatedPlan entity
  static CalculatedPlan convertCalculatedPlanModelToEntity(
    CalculatedPlanModel model,
  ) {
    return CalculatedPlan(
      dietaryPreference: model.dietaryPreference,
      requestedWeek: model.requestedWeek,
      actualSystemWeek: model.actualSystemWeek,
      startDate: model.startDate,
      endDate: model.endDate,
      estimatedPrice: model.estimatedPrice,
      package: model.package?.toEntity(),
      dailyMeals:
          model.dailyMeals
              ?.map((dailyMeal) => _convertDailyMealModelToEntity(dailyMeal))
              .toList(),
    );
  }

  // Convert SubscriptionRequest entity to SubscriptionRequestModel
  static SubscriptionRequestModel convertSubscriptionRequestEntityToModel(
    SubscriptionRequest entity,
  ) {
    return SubscriptionRequestModel(
      startDate: entity.startDate,
      address: entity.address,
      instructions: entity.instructions,
      noOfPersons: entity.noOfPersons,
      weeks:
          entity.weeks
              .map((week) => _convertWeekRequestDataEntityToModel(week))
              .toList(),
    );
  }

  // Convert SubscriptionResponseModel to SubscriptionResponse entity
  static SubscriptionResponse convertSubscriptionResponseModelToEntity(
    SubscriptionResponseModel model,
  ) {
    return SubscriptionResponse(
      id: model.id,
      status: model.status,
      message: model.message,
      createdAt: model.createdAt,
      totalAmount: model.totalAmount,
      additionalData: model.additionalData,
    );
  }

  // Private helper methods
  static DailyMeal _convertDailyMealModelToEntity(DailyMealModel model) {
    return DailyMeal(
      date: model.date,
      day: model.day,
      meal:
          model.meal != null ? _convertDayMealModelToEntity(model.meal!) : null,
    );
  }

  static DayMeal _convertDayMealModelToEntity(DayMealModel model) {
    return DayMeal(
      id: model.id,
      name: model.name,
      description: model.description,
      dietaryPreference: model.dietaryPreference,
      price: model.price,
      dishes: model.dishes?.map(
        (key, dish) => MapEntry(key, _convertMealDishModelToEntity(dish)),
      ),
      image:
          model.image != null
              ? _convertMealImageModelToEntity(model.image!)
              : null,
      isAvailable: model.isAvailable,
    );
  }

  static MealDish _convertMealDishModelToEntity(MealDishModel model) {
    return MealDish(
      id: model.id,
      name: model.name,
      description: model.description,
      price: model.price,
      dietaryPreference: model.dietaryPreference,
      isAvailable: model.isAvailable,
      image:
          model.image != null
              ? _convertMealImageModelToEntity(model.image!)
              : null,
      key: model.key,
    );
  }

  static MealImage _convertMealImageModelToEntity(MealImageModel model) {
    return MealImage(
      id: model.id,
      url: model.url,
      key: model.key,
      fileName: model.fileName,
    );
  }

  static WeekRequestDataModel _convertWeekRequestDataEntityToModel(
    WeekRequestData entity,
  ) {
    return WeekRequestDataModel(
      dietaryPreference: entity.dietaryPreference,
      slots: entity.slots,
    );
  }
}
