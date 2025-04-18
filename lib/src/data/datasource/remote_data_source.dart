// lib/src/data/datasource/remote_data_source.dart
import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/meal_slot_model.dart';
import 'package:foodam/src/data/model/order_model.dart';
import 'package:foodam/src/data/model/package_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

abstract class RemoteDataSource {
  // Auth
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String phone,
  );
  Future<Map<String, dynamic>> registerWithMobile(String mobile);
  Future<Map<String, dynamic>> requestLoginOTP(String mobile);
  Future<Map<String, dynamic>> verifyLoginOTP(String mobile, String otp);
  Future<Map<String, dynamic>> verifyMobileOTP(String mobile, String otp);
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
  Future<Map<String, dynamic>> validateToken(String token);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);

  // User
  Future<UserModel> updateUserDetails(Map<String, dynamic> data);

  // Subscriptions
  Future<List<PackageModel>> getAllPackages();
  Future<PackageModel> getPackageById(String packageId);
  Future<List<SubscriptionModel>> getActiveSubscriptions();
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId);
  Future<String> createSubscription({
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required int personCount,
    required List<MealSlotModel> slots,
  });
  Future<void> updateSubscription(
    String subscriptionId,
    List<MealSlotModel> slots,
  );
  Future<void> cancelSubscription(String subscriptionId);
  Future<void> pauseSubscription(String subscriptionId);
  Future<void> resumeSubscription(String subscriptionId);

  // Meals
  Future<MealModel> getMealById(String mealId);
  Future<DishModel> getDishById(String dishId);

  // Orders
  Future<List<OrderModel>> getUpcomingOrders();
  Future<List<OrderModel>> getPastOrders();
}
