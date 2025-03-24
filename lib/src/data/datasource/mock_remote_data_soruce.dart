// lib/src/data/datasources/mock_remote_data_source.dart
import 'dart:math';

import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/mock_data.dart';
import 'package:foodam/src/data/datasource/remote_data_source.dart';
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/package_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

class MockRemoteDataSource implements RemoteDataSource {
  // For simulating network delays in development
  final bool _simulateDelay = true;
  final int _minDelayMs = 300;
  final int _maxDelayMs = 1200;
  
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
      
      // Very basic mock authentication
      if (email == 'johndoe@example.com' && password == 'password') {
        return MockData.mockToken;
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> register(String email, String password, String phone) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      return MockData.mockToken;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _delay();
      return;
    } catch (e) {
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
      throw ServerException();
    }
  }

  @override
  Future<List<AddressModel>> getUserAddresses() async {
    try {
      await _delay();
      await _occasionallyFail();
      
      return MockData.addresses
          .map((address) => AddressModel.fromJson(address))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // Create a mock ID for the new address
      final newAddress = address.toJson();
      newAddress['id'] = 'addr_${DateTime.now().millisecondsSinceEpoch}';
      
      return AddressModel.fromJson(newAddress);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // In a real implementation, this would update the address on the server
      return;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // In a real implementation, this would delete the address on the server
      return;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<MealModel> getMealById(String mealId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final meal = MockData.getMealById(mealId);
      return MealModel.fromJson(meal);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<MealModel>> getMealsByPreference(String preference) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final meals = MockData.getMealsByPreference(preference);
      return meals.map((meal) => MealModel.fromJson(meal)).toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<DishModel> getDishById(String dishId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final dish = MockData.getDishById(dishId);
      return DishModel.fromJson(dish);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<PackageModel>> getAllPackages() async {
    try {
      await _delay();
      await _occasionallyFail();
      
      return MockData.packages
          .map((package) => PackageModel.fromJson(package))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<PackageModel> getPackageById(String packageId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final package = MockData.getPackageById(packageId);
      return PackageModel.fromJson(package);
    } catch (e) {
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
      throw ServerException();
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      final subscription = MockData.getSubscriptionById(subscriptionId);
      return SubscriptionModel.fromJson(subscription);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<SubscriptionModel> createSubscription({
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required List<Map<String, String>> slots,
  }) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // Create a mock subscription with the provided data
      final mockSlots = slots.map((slot) => {
        'day': slot['day'],
        'timing': slot['timing'],
        'meal': MockData.meals[0]['id'], // Default meal
      }).toList();
      
      final mockSubscription = {
        'id': 'sub_${DateTime.now().millisecondsSinceEpoch}',
        'startDate': startDate.toIso8601String(),
        'durationDays': durationDays,
        'package': packageId,
        'slots': mockSlots,
        'address': MockData.addresses.firstWhere(
          (address) => address['id'] == addressId,
          orElse: () => MockData.addresses[0],
        ),
        'instructions': instructions ?? '',
        'paymentDetails': {
          'paymentStatus': 'pending'
        },
        'pauseDetails': {
          'isPaused': false
        },
        'subscriptionStatus': 'pending',
        'cloudKitchen': ''
      };
      
      return SubscriptionModel.fromJson(mockSubscription);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateSubscription(String subscriptionId, List<Map<String, String>> slots) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // In a real implementation, this would update the subscription on the server
      return;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // In a real implementation, this would cancel the subscription on the server
      return;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> pauseSubscription(String subscriptionId, DateTime untilDate) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // In a real implementation, this would pause the subscription on the server
      return;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> resumeSubscription(String subscriptionId) async {
    try {
      await _delay();
      await _occasionallyFail();
      
      // In a real implementation, this would resume the subscription on the server
      return;
    } catch (e) {
      throw ServerException();
    }
  }
}
