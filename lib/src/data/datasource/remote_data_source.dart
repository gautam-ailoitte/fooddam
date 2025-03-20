import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/meal_order_model.dart';
import 'package:foodam/src/data/model/payment_model.dart';
import 'package:foodam/src/data/model/plan_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

abstract class RemoteDataSource {
  // Auth
  Future<String> login(String email, String password);
  Future<void> logout();
  Future<UserModel> getCurrentUser();

  // User
  Future<UserModel> getUserDetails();
  Future<void> updateUserDetails(UserModel user);
  Future<void> updateDietaryPreferences(List<String> preferences);
  Future<void> updateAllergies(List<String> allergies);

  // Subscription
  Future<List<SubscriptionModel>> getActiveSubscriptions();
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans();
  Future<SubscriptionModel> getSubscriptionDetails(String subscriptionId);
  Future<SubscriptionModel> createSubscription(Map<String, dynamic> subscriptionData);
  Future<void> cancelSubscription(String subscriptionId);
  Future<void> pauseSubscription(String subscriptionId, DateTime until);
  Future<void> resumeSubscription(String subscriptionId);

  // Meal Orders
  Future<List<MealOrderModel>> getTodayMealOrders();
  Future<List<MealOrderModel>> getMealOrdersByDate(DateTime date);
  Future<List<MealOrderModel>> getMealOrdersBySubscription(String subscriptionId);

  // Meals
  Future<List<MealModel>> getAvailableMeals();
  Future<MealModel> getMealDetails(String mealId);
  Future<List<MealModel>> getMealsByType(String type);
  Future<List<MealModel>> getMealsByDietaryPreference(String preference);
  Future<List<DishModel>> getDishes();
  Future<DishModel> getDishDetails(String dishId);

  // Payment
  Future<PaymentModel> processPayment(String subscriptionId, double amount, String method);
  Future<List<PaymentModel>> getPaymentHistory();
  Future<PaymentModel> getPaymentDetails(String paymentId);
}
