

import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/network/api_client.dart';
import 'package:foodam/src/data/model/address_model.dart';
import 'package:foodam/src/data/model/dish_model.dart';
import 'package:foodam/src/data/model/meal_model.dart';
import 'package:foodam/src/data/model/package_model.dart';
import 'package:foodam/src/data/model/subscription_model.dart';
import 'package:foodam/src/data/model/user_model.dart';

abstract class RemoteDataSource {
  // Auth
  Future<String> login(String email, String password);
  Future<String> register(String email, String password, String phone);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  
  // User
  Future<List<AddressModel>> getUserAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<void> updateAddress(AddressModel address);
  Future<void> deleteAddress(String addressId);
  
  // Meals
  Future<MealModel> getMealById(String mealId);
  Future<List<MealModel>> getMealsByPreference(String preference);
  Future<DishModel> getDishById(String dishId);
  
  // Packages
  Future<List<PackageModel>> getAllPackages();
  Future<PackageModel> getPackageById(String packageId);
  
  // Subscriptions
  Future<List<SubscriptionModel>> getActiveSubscriptions();
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId);
  Future<SubscriptionModel> createSubscription({
    required String packageId,
    required DateTime startDate,
    required int durationDays,
    required String addressId,
    String? instructions,
    required List<Map<String, String>> slots,
  });
  Future<void> updateSubscription(String subscriptionId, List<Map<String, String>> slots);
  Future<void> cancelSubscription(String subscriptionId);
  Future<void> pauseSubscription(String subscriptionId, DateTime untilDate);
  Future<void> resumeSubscription(String subscriptionId);
}



class RemoteDataSourceImpl implements RemoteDataSource {
  final ApiClient client;
  
  RemoteDataSourceImpl({required this.client});

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await client.post(
        '/api/auth/login', 
        body: {'email': email, 'password': password}
      );
      
      if (response['status'] == 'success' || response['success'] == true) {
        return response['data']['token'] ?? response['token'];
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
      final response = await client.post(
        '/api/auth/register', 
        body: {'email': email, 'password': password, 'phone': phone}
      );
      
      if (response['success'] == true) {
        return response['token'];
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.post('/api/auth/logout');
      return;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await client.get('/api/users/me');
      
      if (response['success'] == true) {
        return UserModel.fromJson(response['data']);
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<AddressModel>> getUserAddresses() async {
    try {
      final response = await client.get('/api/users/addresses');
      
      if (response['success'] == true) {
        return (response['data'] as List)
            .map((address) => AddressModel.fromJson(address))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final response = await client.post(
        '/api/users/addresses',
        body: address.toJson(),
      );
      
      if (response['success'] == true) {
        return AddressModel.fromJson(response['data']);
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    try {
      final response = await client.put(
        '/api/users/addresses/${address.id}',
        body: address.toJson(),
      );
      
      if (response['success'] != true) {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      final response = await client.delete('/api/users/addresses/$addressId');
      
      if (response['success'] != true) {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<MealModel> getMealById(String mealId) async {
    try {
      final response = await client.get('/api/meals/$mealId');
      
      if (response['status'] == 'success' || response['success'] == true) {
        return MealModel.fromJson(response['data']);
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<MealModel>> getMealsByPreference(String preference) async {
    try {
      final response = await client.get('/api/meals?preference=$preference');
      
      if (response['status'] == 'success' || response['success'] == true) {
        return (response['data'] as List)
            .map((meal) => MealModel.fromJson(meal))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<DishModel> getDishById(String dishId) async {
    try {
      final response = await client.get('/api/dishes/$dishId');
      
      if (response['status'] == 'success' || response['success'] == true) {
        return DishModel.fromJson(response['data']);
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<PackageModel>> getAllPackages() async {
    try {
      final response = await client.get('/api/subscriptions/packages');
      
      if (response['success'] == true) {
        return (response['data'] as List)
            .map((package) => PackageModel.fromJson(package))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<PackageModel> getPackageById(String packageId) async {
    try {
      final response = await client.get('/api/subscriptions/packages/$packageId');
      
      if (response['success'] == true) {
        return PackageModel.fromJson(response['data']);
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<SubscriptionModel>> getActiveSubscriptions() async {
    try {
      final response = await client.get('/api/subscriptions');
      
      if (response['success'] == true) {
        return (response['data'] as List)
            .map((subscription) => SubscriptionModel.fromJson(subscription))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionById(String subscriptionId) async {
    try {
      final response = await client.get('/api/subscriptions/$subscriptionId');
      
      if (response['success'] == true) {
        return SubscriptionModel.fromJson(response['data']);
      } else {
        throw ServerException();
      }
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
      final response = await client.post(
        '/api/subscriptions/subscribe',
        body: {
          'startDate': startDate.toIso8601String(),
          'durationDays': durationDays.toString(),
          'address': addressId,
          'instructions': instructions,
          'package': packageId,
          'slots': slots,
        },
      );
      
      if (response['success'] == true) {
        return SubscriptionModel.fromJson(response['data']);
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateSubscription(String subscriptionId, List<Map<String, String>> slots) async {
    try {
      final response = await client.put(
        '/api/subscriptions/$subscriptionId',
        body: {'slots': slots},
      );
      
      if (response['success'] != true) {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      final response = await client.delete('/api/subscriptions/$subscriptionId');
      
      if (response['success'] != true) {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> pauseSubscription(String subscriptionId, DateTime untilDate) async {
    try {
      final response = await client.put(
        '/api/subscriptions/$subscriptionId/pause',
        body: {'untilDate': untilDate.toIso8601String()},
      );
      
      if (response['success'] != true) {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> resumeSubscription(String subscriptionId) async {
    try {
      final response = await client.put('/api/subscriptions/$subscriptionId/resume', body: {});
      
      if (response['success'] != true) {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}