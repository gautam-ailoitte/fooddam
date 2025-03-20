import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/meal_order_model.dart';
import 'package:foodam/src/data/model/plan_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

abstract class LocalDataSource {
  // Auth
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getUser();

  // Subscriptions
  Future<void> cacheActiveSubscriptions(List<SubscriptionModel> subscriptions);
  Future<List<SubscriptionModel>?> getActiveSubscriptions();
  Future<void> cacheSubscriptionPlans(List<SubscriptionPlanModel> plans);
  Future<List<SubscriptionPlanModel>?> getSubscriptionPlans();

  // Meals
  Future<void> cacheAvailableMeals(List<MealModel> meals);
  Future<List<MealModel>?> getAvailableMeals();
  Future<void> cacheMeal(MealModel meal);
  Future<MealModel?> getMeal(String mealId);

  // Meal Orders
  Future<void> cacheTodayMealOrders(List<MealOrderModel> orders);
  Future<List<MealOrderModel>?> getTodayMealOrders();

  // Draft Plan
  Future<void> cacheDraftMealPlanSelection(Map<String, dynamic> selection);
  Future<Map<String, dynamic>?> getDraftMealPlanSelection();
  Future<void> clearDraftMealPlanSelection();
}
