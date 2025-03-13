// lib/data/datasource/remote_data_source.dart


import 'dart:convert';

import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/core/network/api_client.dart';
import 'package:foodam/mock_data.dart';
import 'package:foodam/src/data/models/user_model.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

// lib/src/data/datasource/remote_data_source.dart

abstract class RemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<bool> checkSubscriptionStatus();
  Future<List<MealModel>> getMealOptions(MealType type);
  Future<List<ThaliModel>> getThaliOptions(MealType type);
  Future<List<PlanModel>> getAvailablePlans();
  Future<PlanModel?> getActivePlan();
  Future<PlanModel> createPlan(PlanModel plan);
  Future<String> savePlanAndGetPaymentUrl(PlanModel plan);
  
  // New methods
  Future<PlanModel> resetPlanToDefaults(String planId);
  Future<Map<MealType, ThaliModel>> getDefaultThaliConfiguration();
  Future<void> synchronizeDraftPlan(PlanModel plan);
  Future<List<PlanModel>> getRecommendedPlans(UserModel user);
  Future<ThaliModel> getDefaultThali(MealType type, ThaliType preferredType);
  Future<void> createPlanFromTemplate(PlanModel template, bool setAsDraft);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final ApiClient client;

  RemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));
      
      // For demo purposes: simple credentials check
      if (email == 'user@example.com' && password == 'password123') {
        return MockData.getMockUser();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<bool> checkSubscriptionStatus() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 600));
      
      // In a real app, this would check with the server
      // For demo purposes, return the mock user's subscription status
      final user = MockData.getMockUser();
      return user.hasActivePlan;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<MealModel>> getMealOptions(MealType type) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 700));
      
      // Return mock meals based on meal type
      switch (type) {
        case MealType.breakfast:
          return MockData.getMockBreakfastMeals();
        case MealType.lunch:
          return MockData.getMockLunchMeals();
        case MealType.dinner:
          return MockData.getMockDinnerMeals();
        }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<ThaliModel>> getThaliOptions(MealType type) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 700));
      
      // Return mock thalis based on meal type
      switch (type) {
        case MealType.breakfast:
          return MockData.getMockBreakfastThalis();
        case MealType.lunch:
          return MockData.getMockLunchThalis();
        case MealType.dinner:
          return MockData.getMockDinnerThalis();
        }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<PlanModel>> getAvailablePlans() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));
      
      return MockData.getMockPlanTemplates();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<PlanModel?> getActivePlan() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 700));
      
      return MockData.getMockActivePlan();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<PlanModel> createPlan(PlanModel plan) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 900));
      
      // In a real app, this would send the plan to the server
      // For demo purposes, just return the plan with a new ID
      return PlanModel.fromJson(plan.toJson()).copyWith(
        id: 'new_${plan.id}',
      );
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> savePlanAndGetPaymentUrl(PlanModel plan) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 1000));
      
      // In a real app, this would send the plan to the server and get a payment URL
      // For demo purposes, return a fake payment URL
      return 'https://payment-gateway.example.com/checkout/${plan.id}';
    } catch (e) {
      throw ServerException();
    }
  }
  
  // New method implementations
  
  @override
  Future<PlanModel> resetPlanToDefaults(String planId) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));
      
      // First get the plan
      final plans = await getAvailablePlans();
      final planToReset = plans.firstWhere(
        (p) => p.id == planId,
        orElse: () => plans.first,
      );
      
      // Use MockData helper to reset
      return MockData.resetPlanToDefaults(planToReset);
    } catch (e) {
      throw ServerException();
    }
  }
  
  @override
  Future<Map<MealType, ThaliModel>> getDefaultThaliConfiguration() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 700));
      
      // Get default thalis for each meal type
      final breakfast = (await getThaliOptions(MealType.breakfast))[0];
      final lunch = (await getThaliOptions(MealType.lunch))[0];
      final dinner = (await getThaliOptions(MealType.dinner))[0];
      
      return {
        MealType.breakfast: breakfast,
        MealType.lunch: lunch,
        MealType.dinner: dinner,
      };
    } catch (e) {
      throw ServerException();
    }
  }
  
  @override
  Future<void> synchronizeDraftPlan(PlanModel plan) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));
      
      // In a real app, this would sync the draft plan with the server
      // For demo purposes, we'll just wait
      return;
    } catch (e) {
      throw ServerException();
    }
  }
  
  @override
  Future<List<PlanModel>> getRecommendedPlans(UserModel user) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 900));
      
      // Use MockData to get recommendations
      return MockData.getRecommendedPlans(user);
    } catch (e) {
      throw ServerException();
    }
  }
  
  @override
  Future<ThaliModel> getDefaultThali(MealType type, ThaliType preferredType) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 600));
      
      // Get all thali options for this meal type
      final thalis = await getThaliOptions(type);
      
      // Find the one matching the preferred type
      return thalis.firstWhere(
        (thali) => thali.type == preferredType,
        orElse: () => thalis.first, // Default to first if not found
      );
    } catch (e) {
      throw ServerException();
    }
  }
  
  @override
  Future<void> createPlanFromTemplate(PlanModel template, bool setAsDraft) async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 850));
      
      // In a real app, this would create a new plan from the template
      // For demo purposes, we'll just wait
      return;
    } catch (e) {
      throw ServerException();
    }
  }
}
// lib/data/datasource/local_data_source.dart

// lib/src/data/datasource/local_data_source.dart


abstract class LocalDataSource {
  // User related
  Future<UserModel> getLastUser();
  Future<void> cacheUser(UserModel user);
  Future<bool> hasToken();
  Future<void> clearUser();
  
  // Meal related
  Future<List<MealModel>> getLastMealOptions(MealType type);
  Future<void> cacheMealOptions(MealType type, List<MealModel> meals);
  
  // Thali related
  Future<List<ThaliModel>> getLastThaliOptions(MealType type);
  Future<void> cacheThaliOptions(MealType type, List<ThaliModel> thalis);
  Future<void> cacheCustomizedThali(ThaliModel thali);
  Future<ThaliModel?> getCustomizedThali(String thaliId);
  
  // Plan related
  Future<List<PlanModel>> getLastPlans();
  Future<void> cachePlans(List<PlanModel> plans);
  
  Future<PlanModel?> getLastActivePlan();
  Future<void> cacheActivePlan(PlanModel plan);
  
  Future<PlanModel?> getDraftPlan();
  Future<void> cacheDraftPlan(PlanModel plan);
  Future<void> clearDraftPlan();
  
  // Customization state tracking
  Future<void> cacheCustomizationState(String planId, DayOfWeek day, MealType type, ThaliModel thali);
  Future<ThaliModel?> getCustomizationState(String planId, DayOfWeek day, MealType type);
  Future<void> clearCustomizationState(String planId);
  
  // Default configurations
  Future<Map<MealType, ThaliModel>?> getDefaultThalis();
  Future<Map<MealType, ThaliModel>> cacheDefaultThalis(Map<MealType, ThaliModel> defaults);
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel> getLastUser() async {
    final jsonString = sharedPreferences.getString('CACHED_USER');
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(
      'CACHED_USER',
      json.encode(user.toJson()),
    );
  }

  @override
  Future<bool> hasToken() async {
    return sharedPreferences.containsKey('CACHED_TOKEN');
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove('CACHED_USER');
    await sharedPreferences.remove('CACHED_TOKEN');
  }
  
  @override
  Future<List<MealModel>> getLastMealOptions(MealType type) async {
    final key = 'CACHED_MEALS_${type.toString().split('.').last}';
    final jsonString = sharedPreferences.getString(key);
    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((meal) => MealModel.fromJson(meal)).toList();
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheMealOptions(MealType type, List<MealModel> meals) async {
    final key = 'CACHED_MEALS_${type.toString().split('.').last}';
    final jsonString = json.encode(
      meals.map((meal) => meal.toJson()).toList(),
    );
    await sharedPreferences.setString(key, jsonString);
  }

  @override
  Future<List<ThaliModel>> getLastThaliOptions(MealType type) async {
    final key = 'CACHED_THALIS_${type.toString().split('.').last}';
    final jsonString = sharedPreferences.getString(key);
    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((thali) => ThaliModel.fromJson(thali)).toList();
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheThaliOptions(MealType type, List<ThaliModel> thalis) async {
    final key = 'CACHED_THALIS_${type.toString().split('.').last}';
    final jsonString = json.encode(
      thalis.map((thali) => thali.toJson()).toList(),
    );
    await sharedPreferences.setString(key, jsonString);
  }

  @override
  Future<List<PlanModel>> getLastPlans() async {
    final jsonString = sharedPreferences.getString('CACHED_PLANS');
    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((plan) => PlanModel.fromJson(plan)).toList();
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cachePlans(List<PlanModel> plans) async {
    final jsonString = json.encode(
      plans.map((plan) => plan.toJson()).toList(),
    );
    await sharedPreferences.setString('CACHED_PLANS', jsonString);
  }

  @override
  Future<PlanModel?> getLastActivePlan() async {
    final jsonString = sharedPreferences.getString('CACHED_ACTIVE_PLAN');
    if (jsonString != null) {
      return PlanModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheActivePlan(PlanModel plan) async {
    await sharedPreferences.setString(
      'CACHED_ACTIVE_PLAN',
      json.encode(plan.toJson()),
    );
  }

  @override
  Future<PlanModel?> getDraftPlan() async {
    final jsonString = sharedPreferences.getString('CACHED_DRAFT_PLAN');
    if (jsonString != null) {
      return PlanModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheDraftPlan(PlanModel plan) async {
    await sharedPreferences.setString(
      'CACHED_DRAFT_PLAN',
      json.encode(plan.toJson()),
    );
  }
  
  @override
  Future<void> clearDraftPlan() async {
    await sharedPreferences.remove('CACHED_DRAFT_PLAN');
  }
  
  // New method implementations
  
  @override
  Future<void> cacheCustomizedThali(ThaliModel thali) async {
    final key = 'CUSTOMIZED_THALI_${thali.id}';
    final jsonString = json.encode(thali.toJson());
    await sharedPreferences.setString(key, jsonString);
  }
  
  @override
  Future<ThaliModel?> getCustomizedThali(String thaliId) async {
    final key = 'CUSTOMIZED_THALI_$thaliId';
    final jsonString = sharedPreferences.getString(key);
    if (jsonString != null) {
      return ThaliModel.fromJson(json.decode(jsonString));
    }
    return null;
  }
  
  @override
  Future<void> cacheCustomizationState(String planId, DayOfWeek day, MealType type, ThaliModel thali) async {
    final key = 'CUSTOMIZATION_${planId}_${day.toString()}_${type.toString()}';
    final jsonString = json.encode(thali.toJson());
    await sharedPreferences.setString(key, jsonString);
  }
  
  @override
  Future<ThaliModel?> getCustomizationState(String planId, DayOfWeek day, MealType type) async {
    final key = 'CUSTOMIZATION_${planId}_${day.toString()}_${type.toString()}';
    final jsonString = sharedPreferences.getString(key);
    if (jsonString != null) {
      return ThaliModel.fromJson(json.decode(jsonString));
    }
    return null;
  }
  
  @override
  Future<void> clearCustomizationState(String planId) async {
    // Find all keys related to this plan
    final keys = sharedPreferences.getKeys()
      .where((key) => key.startsWith('CUSTOMIZATION_$planId'))
      .toList();
    
    // Remove all keys
    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }
  
  @override
  Future<Map<MealType, ThaliModel>?> getDefaultThalis() async {
    final jsonString = sharedPreferences.getString('DEFAULT_THALI_CONFIG');
    if (jsonString != null) {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      
      // Convert the decoded map to MealType keys
      final Map<MealType, ThaliModel> result = {};
      decoded.forEach((key, value) {
        // Convert string key to MealType enum
        final mealType = MealType.values.firstWhere(
          (e) => e.toString().split('.').last == key,
          orElse: () => MealType.lunch, // Default to lunch if not found
        );
        
        // Convert value to ThaliModel
        final thali = ThaliModel.fromJson(value);
        
        result[mealType] = thali;
      });
      
      return result;
    }
    return null;
  }
  
  @override
  Future<Map<MealType, ThaliModel>> cacheDefaultThalis(Map<MealType, ThaliModel> defaults) async {
    // Convert the map to a serializable format
    final Map<String, dynamic> serializableMap = {};
    defaults.forEach((key, value) {
      // Use the enum name as the key
      serializableMap[key.toString().split('.').last] = value.toJson();
    });
    
    // Save to SharedPreferences
    final jsonString = json.encode(serializableMap);
    await sharedPreferences.setString('DEFAULT_THALI_CONFIG', jsonString);
    
    return defaults;
  }
}

///