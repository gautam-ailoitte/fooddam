import 'dart:convert';

import 'package:foodam/core/errors/execption.dart';
import 'package:foodam/src/data/models/meal_model.dart';
import 'package:foodam/src/data/models/plan_model.dart';
import 'package:foodam/src/data/models/thali_model.dart';
import 'package:foodam/src/data/models/user_model.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

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