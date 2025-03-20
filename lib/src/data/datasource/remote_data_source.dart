import 'dart:math';

import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/network/api_client.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/mock_data.dart';
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
class RemoteDataSourceImpl implements RemoteDataSource {
  final ApiClient client;
  final LoggerService _logger = LoggerService();
  
  // For simulating network delays in development
  final bool _simulateDelay = true;
  final int _minDelayMs = 300;
  final int _maxDelayMs = 1200;
  
  RemoteDataSourceImpl({required this.client});
  
  // Helper method to simulate network delay
  Future<void> _delay() async {
    if (_simulateDelay) {
      final random = Random();
      final delay = _minDelayMs + random.nextInt(_maxDelayMs - _minDelayMs);
      await Future.delayed(Duration(milliseconds: delay));
    }
  }
  
  // Helper to simulate occasional errors for testing error handling
  Future<void> _occasionallyFail({double failProbability = 0.05}) async {
    if (Random().nextDouble() < failProbability) {
      throw ServerException();
    }
  }

  @override
  Future<String> login(String email, String password) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // Very basic mock authentication - in real implementation would validate against API
      if (email == 'johndoe@example.com' && password == 'password') {
        return MockData.mockToken;
      } else {
        throw ServerException();
      }
    } catch (e) {
      _logger.e('Login error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _delay();
      // Simulate successful logout
      return;
    } catch (e) {
      _logger.e('Logout error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      await _delay();
      await _occasionallyFail();
      
      return UserModel.fromJson(MockData.currentUser);
    } catch (e) {
      _logger.e('Get current user error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<UserModel> getUserDetails() async {
    try {
      await _delay();
      await _occasionallyFail();
      
      return UserModel.fromJson(MockData.currentUser);
    } catch (e) {
      _logger.e('Get user details error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<void> updateUserDetails(UserModel user) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // In a real implementation, this would update the user on the server
      // For now, we just simulate a successful update
      _logger.d('Updated user: ${user.id}', tag: 'MOCK');
      return;
    } catch (e) {
      _logger.e('Update user details error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<void> updateDietaryPreferences(List<String> preferences) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      _logger.d('Updated dietary preferences: $preferences', tag: 'MOCK');
      return;
    } catch (e) {
      _logger.e('Update dietary preferences error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<void> updateAllergies(List<String> allergies) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      _logger.d('Updated allergies: $allergies', tag: 'MOCK');
      return;
    } catch (e) {
      _logger.e('Update allergies error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<List<SubscriptionModel>> getActiveSubscriptions() async {
    try {
      await _delay();
      await _occasionallyFail();
      
      return MockData.activeSubscriptions
          .map((subscription) => SubscriptionModel.fromJson(subscription))
          .toList();
    } catch (e) {
      _logger.e('Get active subscriptions error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    try {
      await _delay();
      await _occasionallyFail();
      
      return MockData.subscriptionPlans
          .map((plan) => SubscriptionPlanModel.fromJson(plan))
          .toList();
    } catch (e) {
      _logger.e('Get subscription plans error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionDetails(String subscriptionId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final subscription = MockData.activeSubscriptions.firstWhere(
        (sub) => sub['id'] == subscriptionId,
        orElse: () => throw ServerException(),
      );
      
      return SubscriptionModel.fromJson(subscription);
    } catch (e) {
      _logger.e('Get subscription details error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<SubscriptionModel> createSubscription(Map<String, dynamic> subscriptionData) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // Simulate creating a new subscription by cloning an existing one
      // with modified data
      final mockSubscription = Map<String, dynamic>.from(MockData.activeSubscriptions[0]);
      
      // Update with new data
      mockSubscription['id'] = 'sub_${DateTime.now().millisecondsSinceEpoch}';
      mockSubscription['startDate'] = subscriptionData['startDate'] ?? DateTime.now().toIso8601String();
      mockSubscription['endDate'] = subscriptionData['endDate'] ?? 
          DateTime.now().add(Duration(days: 30)).toIso8601String();
      
      if (subscriptionData['planId'] != null) {
        mockSubscription['planId'] = subscriptionData['planId'];
        
        // Find the matching plan
        final selectedPlan = MockData.subscriptionPlans.firstWhere(
          (plan) => plan['id'] == subscriptionData['planId'],
          orElse: () => MockData.subscriptionPlans[0],
        );
        
        mockSubscription['subscriptionPlan'] = selectedPlan;
      }
      
      if (subscriptionData['deliveryAddress'] != null) {
        mockSubscription['deliveryAddress'] = subscriptionData['deliveryAddress'];
      }
      
      if (subscriptionData['deliveryInstructions'] != null) {
        mockSubscription['deliveryInstructions'] = subscriptionData['deliveryInstructions'];
      }
      
      return SubscriptionModel.fromJson(mockSubscription);
    } catch (e) {
      _logger.e('Create subscription error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      _logger.d('Canceled subscription: $subscriptionId', tag: 'MOCK');
      return;
    } catch (e) {
      _logger.e('Cancel subscription error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<void> pauseSubscription(String subscriptionId, DateTime until) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      _logger.d('Paused subscription: $subscriptionId until ${until.toIso8601String()}', tag: 'MOCK');
      return;
    } catch (e) {
      _logger.e('Pause subscription error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<void> resumeSubscription(String subscriptionId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      _logger.d('Resumed subscription: $subscriptionId', tag: 'MOCK');
      return;
    } catch (e) {
      _logger.e('Resume subscription error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<List<MealOrderModel>> getTodayMealOrders() async {
    try {
      await _delay();
      await _occasionallyFail();
      
      return MockData.todayMealOrders
          .map((order) => MealOrderModel.fromJson(order))
          .toList();
    } catch (e) {
      _logger.e('Get today meal orders error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<List<MealOrderModel>> getMealOrdersByDate(DateTime date) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final orders = MockData.getMealOrdersByDate(date);
      return orders.map((order) => MealOrderModel.fromJson(order)).toList();
    } catch (e) {
      _logger.e('Get meal orders by date error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<List<MealOrderModel>> getMealOrdersBySubscription(String subscriptionId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final filteredOrders = MockData.todayMealOrders
          .where((order) => order['subscriptionId'] == subscriptionId)
          .toList();
      
      return filteredOrders
          .map((order) => MealOrderModel.fromJson(order))
          .toList();
    } catch (e) {
      _logger.e('Get meal orders by subscription error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<List<MealModel>> getAvailableMeals() async {
    try {
      await _delay();
      await _occasionallyFail();
      
      return MockData.meals
          .map((meal) => MealModel.fromJson(meal))
          .toList();
    } catch (e) {
      _logger.e('Get available meals error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<MealModel> getMealDetails(String mealId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final meal = MockData.getMeal(mealId);
      return MealModel.fromJson(meal);
    } catch (e) {
      _logger.e('Get meal details error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<List<MealModel>> getMealsByType(String type) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final filteredMeals = MockData.getMealsByType(type);
      return filteredMeals
          .map((meal) => MealModel.fromJson(meal))
          .toList();
    } catch (e) {
      _logger.e('Get meals by type error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<List<MealModel>> getMealsByDietaryPreference(String preference) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final filteredMeals = MockData.meals
          .where((meal) => 
            meal['dietaryPreferences'] != null && 
            meal['dietaryPreferences'].contains(preference))
          .toList();
      
      return filteredMeals
          .map((meal) => MealModel.fromJson(meal))
          .toList();
    } catch (e) {
      _logger.e('Get meals by dietary preference error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<List<DishModel>> getDishes() async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // Extract all unique dishes from the meals
      final dishes = <Map<String, dynamic>>[];
      final dishIds = <String>{};
      
      for (var meal in MockData.meals) {
        for (var dish in meal['dishes']) {
          if (!dishIds.contains(dish['id'])) {
            dishes.add(dish);
            dishIds.add(dish['id']);
          }
        }
      }
      
      return dishes
          .map((dish) => DishModel.fromJson(dish))
          .toList();
    } catch (e) {
      _logger.e('Get dishes error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<DishModel> getDishDetails(String dishId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final dish = MockData.getDishDetail(dishId);
      return DishModel.fromJson(dish);
    } catch (e) {
      _logger.e('Get dish details error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<PaymentModel> processPayment(String subscriptionId, double amount, String method) async {
    try {
      await _delay();
      await _occasionallyFail(failProbability: 0.1); // Slightly higher failure rate for payments
      
      // Create a new payment record
      final payment = {
        'id': 'payment_${DateTime.now().millisecondsSinceEpoch}',
        'subscriptionId': subscriptionId,
        'amount': amount,
        'method': method,
        'status': 'paid',
        'timestamp': DateTime.now().toIso8601String(),
        'transactionId': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      };
      
      return PaymentModel.fromJson(payment);
    } catch (e) {
      _logger.e('Process payment error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentHistory() async {
    try {
      await _delay();
      await _occasionallyFail();
      
      return MockData.paymentHistory
          .map((payment) => PaymentModel.fromJson(payment))
          .toList();
    } catch (e) {
      _logger.e('Get payment history error', error: e);
      throw ServerException();
    }
  }

  @override
  Future<PaymentModel> getPaymentDetails(String paymentId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final payment = MockData.paymentHistory.firstWhere(
        (payment) => payment['id'] == paymentId,
        orElse: () => throw ServerException(),
      );
      
      return PaymentModel.fromJson(payment);
    } catch (e) {
      _logger.e('Get payment details error', error: e);
      throw ServerException();
    }
  }
}



