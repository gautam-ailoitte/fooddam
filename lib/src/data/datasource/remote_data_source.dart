// lib/src/data/datasource/remote_data_source.dart (UPDATE)
import 'package:foodam/src/data/model/banner_model.dart' show BannerModel;
import 'package:foodam/src/data/model/calculated_plan_model.dart';
import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/meal_slot_model.dart';
import 'package:foodam/src/data/model/order_model.dart';
import 'package:foodam/src/data/model/package_model.dart';
import 'package:foodam/src/data/model/subscription_detail_model.dart';
import 'package:foodam/src/data/model/subscription_list_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

import '../model/pagination_model.dart';

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
  Future<Map<String, dynamic>> resendOTP(String mobile, bool isRegistration);
  Future<Map<String, dynamic>> forgotPassword(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);

  // User
  Future<UserModel> updateUserDetails(Map<String, dynamic> data);

  // Subscriptions - UPDATED with separate methods
  Future<PaginatedResponse<SubscriptionListModel>> getSubscriptions({
    int? page,
    int? limit,
  });
  Future<List<SubscriptionListModel>>
  getActiveSubscriptions(); // Updated return type
  Future<SubscriptionDetailModel> getSubscriptionById(
    String subscriptionId,
  ); // Updated return type

  // Packages
  Future<List<PackageModel>> getAllPackages({String? dietaryPreference});
  Future<PackageModel> getPackageById(String packageId);

  // Subscription Creation
  Future<SubscriptionDetailModel> createSubscription({
    required DateTime startDate,
    required DateTime endDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required int noOfPersons,
    required List<WeekSubscriptionRequest> weeks,
  });

  Future<void> updateSubscription(
    String subscriptionId,
    List<MealSlotModel> slots,
  );
  Future<CalculatedPlanModel> getCalculatedPlan({
    required String dietaryPreference,
    required int week,
    required DateTime startDate,
  });
  Future<void> cancelSubscription(String subscriptionId);
  Future<void> pauseSubscription(String subscriptionId);
  Future<void> resumeSubscription(String subscriptionId);

  // Meals
  Future<MealModel> getMealById(String mealId);
  Future<DishModel> getDishById(String dishId);

  // Orders
  Future<PaginatedResponse<OrderModel>> getUpcomingOrders({
    int? page,
    int? limit,
    String? dayContext,
  });

  Future<PaginatedResponse<OrderModel>> getPastOrders({
    int? page,
    int? limit,
    String? dayContext,
  });

  Future<List<BannerModel>> getBanners({String? category});
}

class WeekSubscriptionRequest {
  final String packageId;
  final List<MealSlotRequest> slots;

  WeekSubscriptionRequest({required this.packageId, required this.slots});

  Map<String, dynamic> toJson() {
    return {
      'package': packageId,
      'slots': slots.map((slot) => slot.toJson()).toList(),
    };
  }
}

class MealSlotRequest {
  final String day;
  final DateTime date;
  final String timing;
  final String mealId;

  MealSlotRequest({
    required this.day,
    required this.date,
    required this.timing,
    required this.mealId,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date.toIso8601String(),
      'timing': timing,
      'meal': mealId,
    };
  }

  static MealSlotRequest fromMap(Map<String, dynamic> map) {
    return MealSlotRequest(
      day: map['day'] as String,
      date:
          map['date'] is String
              ? DateTime.parse(map['date'] as String)
              : map['date'] as DateTime,
      timing: map['timing'] as String,
      mealId: map['meal'] as String,
    );
  }
}
